SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ProcessGoodsListGenBill]
(
    @jobID int,                                           -- 作业序号
    @oper int,                                            -- 操作人
    @src int,                                               -- 来源单位
    @errorMessage varchar(256) OUTPUT   -- 消息
) AS
BEGIN
    -- JobID 不存在，退出。
    IF NOT EXISTS(SELECT 1 FROM ProcessGoodsJob WHERE ID = @jobID)
    BEGIN
        SET @errorMessage = '当前作业 %d 不存在。';
        RAISERROR(@errorMessage, 16, 1, @jobID);
    END;

    IF NOT EXISTS (SELECT 1 FROM ProcessGoodsList WHERE JobID = @jobID)
    BEGIN
        SET @errorMessage = '当前作业 %d 不存在任何加工商品。';
        RAISERROR(@errorMessage, 16, 1, @jobID);
    END;

    -- 门店游标，该作业中的门店
    DECLARE c_store CURSOR FOR SELECT StoreGid, GenBillType FROM ProcessGoodsJobLac WHERE JobID = @jobID;
    DECLARE
        --  生成单据类型
        @generateBillType int, @moduleID int;
    DECLARE
        -- 游标中的 StoreGid, JobID 和 GenBillType
        @c_storeGid int, @c_genBillType int;
    -- 自动发送、默认仓位信息
    DECLARE @autoSend int, @defaultWrh int, @defaultGenerateBillStat int, @checkStatus int;
    -- 声明明细游标
    DECLARE @c_gdGid int, @c_qty decimal(24, 4), @c_total decimal(24, 4), @c_qpcStr varchar(10);
    DECLARE @i int, @num varchar(10);
    DECLARE @settleNo int;
    DECLARE @invQty decimal(24, 4);
    -- 合计
    DECLARE @sumTotal decimal(24, 4), @sumTax decimal(24, 4);

    SET @moduleID = 715;
    EXECUTE OptReadInt @moduleID, 'AutoSend', 0, @autoSend OUTPUT;
    EXECUTE OptReadInt @moduleID, 'DefaultWrh', 1, @defaultWrh OUTPUT;
    EXECUTE OptReadInt @moduleID, 'GenBillDefaultStat', 0, @defaultGenerateBillStat OUTPUT;

    OPEN c_store;
    fETCH NEXT FROM c_store INTO @c_storeGid, @c_genBillType;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        DECLARE c_goods CURSOR FOR SELECT GDGid, Qty, Total, QpcStr FROM ProcessGoodsList WHERE JobID = @jobID AND StoreGid = @c_storeGid AND IsGenerate = 1;

        SET @i = 0;
        SELECT @settleNo = MAX(No) FROM MonthSettle;
        -- 新单号
        IF @c_genBillType = 0
            EXECUTE GenNextBillNumOld '配货', 'StkOut', @num OUTPUT;
        ELSE IF @c_genBillType = 1
            EXECUTE GenNextBillNumOld '配货', 'StkOutBck', @num OUTPUT;

        OPEN c_goods;
        FETCH NEXT FROM c_goods INTO @c_gdGid, @c_qty, @c_total, @c_qpcStr;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            -- 生成明细
            SET @i = @i + 1;
            -- 取库存
            SELECT @invQty = ISNULL(SUM(Qty), 0) FROM Inv WHERE Store = @c_storeGid AND GDGid = @c_gdGid

            IF @c_genBillType = 0    -- 配货出货单
            BEGIN
                InSERT INTO StkOutDtl
                (
                    Cls, Num, Line, SettleNo, GdGid, Cases, Qty, WsPrc, Price, Total, Tax, InPrc, RtlPrc,
                    ValidDate, Wrh, InvQty, SubWrh, SubQty, RcpQty, RcpAmt, Note, Cost, GftLine, GftID,
                    GftFlag, SrcAgaNum, RsvAlcQty, BckQty
                )
                SELECT
                    '配货', @num, @i, @settleNo, @c_gdGid, NULL, @c_qty, g.WhsPrc, ISNULL(w.InvPrc, g.InPrc), ISNULL(w.InvPrc, g.InPrc) * @c_qty, g.TaxRate / (100 + g.TaxRate) * ISNULL(w.InvPrc, g.InPrc) * @c_qty, g.InPrc, g.RtlPrc,
                    NULL, @defaultWrh, @invQty, NULL, NULL, 0, 0, NULL, g.RtlPrc, NULL, NULL,
                    NULL, NULL, NULL, @c_qty
                FROM Goods AS g, GDWrh AS w
                WHERE g.GID = @c_gdGid AND g.Gid *= w.GDGid AND w.Wrh = @defaultWrh;
            END;

            IF @c_genBillType = 1    -- 配货出货退货单
            BEGIN
                InSERT INTO StkOutBckDtl
                (
                    Cls, Num, Line, SettleNo, GdGid, Cases, Qty, WsPrc, Price, Total, Tax, InPrc, RtlPrc,
                    ValidDate, Wrh, SubWrh, RcpQty, RcpAmt, Note, ItemNo, QpcGid, QpcQty, Cost, CostPrc
                )
                SELECT
                    '配货', @num, @i, @settleNo, @c_gdGid, NULL, @c_qty, g.WhsPrc, ISNULL(w.InvPrc, g.InPrc), ISNULL(w.InvPrc, g.InPrc) * @c_qty, g.TaxRate / (100 + g.TaxRate) * ISNULL(w.InvPrc, g.InPrc) * @c_qty, g.InPrc, g.RtlPrc,
                    NULL, @defaultWrh, NULL, 0, 0, NULL, NULL, NULL, NULL, g.RtlPrc, g.RtlPrc * @c_qty
                FROM Goods AS g, GDWrh AS w
                WHERE g.GID = @c_gdGid AND g.Gid *= w.GDGid AND w.Wrh = @defaultWrh;
            END;

            FETCH NEXT FROM c_goods INTO @c_gdGid, @c_qty, @c_total, @c_qpcStr;
        END;

        CLOSE c_goods;
        DEALLOCATE c_goods;

        -- 如果发现明细数据为 0，则报错退出。
        -- 由应用程序回滚事务。
        IF NOT EXISTS(SELECT 1 FROM StkOutDtl WHERE Cls = '配货' AND Num = @num)
        BEGIN
            CLOSE c_store;
            DEALLOCATE c_store;
            SET @errorMessage = '发生内部错误: 生成的单据明细记录为空，操作被终止。';
            RAISERROR(@errorMessage, 16, 1);
            RETURN 1;
        END;

        -- 生成汇总
        IF @c_genBillType = 0    -- 配货出货单
        BEGIN
            SELECT @sumTotal = ISNULL(SUM(Total), 0), @sumTax = ISNULL(SUM(Tax), 0)
            FROM StkOutDtl
            WHERE Cls = '配货' AND Num = @num AND SettleNo = @settleNo;

            INSERT INTO StkOut
            (
                Cls, Num, SettleNo, OrdNum, Client, BillTo, OcrDate, Total, Tax, Wrh, FilDate, Filler, Checker,
                Stat, ModNum, Slr, Note, PreRcp, RcpTotal, RecCnt, Src, SrcNum, SrcOrdNum, SndTime,
                PayDate, PayMode, PrnTime, Gen, GenBill, GenCls, GenNum, Ready, PreChecker, PreChkDate, Finished,
                OtherSideNum, SaleType, RecheckDate
            )
            VALUES
            (
                '配货', @num, @settleNo, NULL, @c_storeGid, @c_storeGid, GETDATE(), @sumTotal, @sumTax, @defaultWrh, GETDATE(), @oper, @oper,
                0, NULL, 1, '由加工商品模块生成', 0, 0, @i, @src, NULL, NULL, NULL,
                NULL, '应付款', NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, 0, NULL, NULL, NULL
            );

            -- 审核
            IF @defaultGenerateBillStat = 1
            BEGIN
                EXECUTE @checkStatus = StkOutChk '配货', @num;
                IF @checkStatus <> 0 OR @@ERROR <> 0
                BEGIN
                    SET @errorMessage = '生成单据成功，但是在审核时发生了一个错误，将取消本次生成操作。';
                    RAISERROR(@errorMessage, 16, 1);
                END;
                -- 自动发送
                IF @autoSend = 1 EXECUTE @checkStatus = StkOutSnd '配货', @num, @c_storeGid, 1;
            END;
        END;

        IF @c_genBillType = 1    -- 配货出货退货单
        BEGIN
            SELECT @sumTotal = ISNULL(SUM(Total), 0), @sumTax = ISNULL(SUM(Tax), 0)
            FROM StkOutDtl
            WHERE Cls = '配货' AND Num = @num AND SettleNo = @settleNo;

            INSERT INTO StkOutBck
            (
                Cls, Num, SettleNo, Client, BillTo, OcrDate, Total, Tax, Wrh, FilDate, Filler, Checker,
                Stat, ModNum, Slr, Note, RecCnt, Src, SrcNum, SndTime, PrnTime, PayMode, Cause, PreChecker,
                PreChkDate, Gen, GenBill, GenCls, GenNum, Finished, BckType, PayDate, FromNum, Score, RecheckDate
            )
            VALUES
            (
                '配货', @num, @settleNo, @c_storeGid, @c_storeGid, GETDATE(), @sumTotal, @sumTax, @defaultWrh, GETDATE(), @oper, @oper,
                0, NULL, 1, '由加工商品模块生成', @i, @src, NULL, NULL, NULL, '应付款', NULL, NULL,
                NULL, NULL, NULL, NULL, NULL, 0, NULL, NULL, NULL, NULL, NULL
            );

            -- 审核
            IF @defaultGenerateBillStat = 1
            BEGIN
                EXECUTE @checkStatus = StkOutBckChk '配货', @num;
                IF @checkStatus <> 0 OR @@ERROR <> 0
                BEGIN
                    SET @errorMessage = '生成单据成功，但是在审核时发生了一个错误，将取消本次生成操作。';
                    RAISERROR(@errorMessage, 16, 1);
                END;
                -- 自动发送
                IF @autoSend = 1 EXECUTE @checkStatus = StkOutBckSnd '配货', @num, @c_storeGid, 1;
            END;
        END;

        fETCH NEXT FROM c_store INTO @c_storeGid, @c_genBillType;
    END;

    -- 关闭游标
    CLOSE c_store;
    DEALLOCATE c_store;

    -- 删除该已经生成单据的商品、门店和作业。
    DELETE FROM ProcessGoodsList WHERE JobID = @jobID AND IsGenerate = 1;
    DELETE FROM ProcessGoodsJobLac
    WHERE NOT StoreGid IN (SELECT a.StoreGid FROM ProcessGoodsJobLac AS a, ProcessGoodsList AS b WHERE a.StoreGid = b.StoreGid AND a.JobID = b.JobID AND a.JobID = @jobID) AND JobID = @jobID;
    DELETE FROM ProcessGoodsJob WHERE NOT ID IN (SELECT JobID FROM ProcessGoodsJobLac WHERE JobID = @jobID) AND ID = @jobID;

    -- 完成
    SET @errorMessage = '已经成功生成所需单据。';
    RETURN 0;
END;
GO
