SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreOrdApplySnd]
(
  @num varchar(14),
  @cls varchar(10),
  @oper varchar(20),
  @toStat int,
  @msg varchar(50) OUTPUT
) AS
BEGIN
  DECLARE
    -- 门店代码
    @userGid int,
    -- 单据目前的状态
    @currentStat int,
    -- 最大 ID
    @maxID int,
    -- 是否总部标识
    @userProperty int;
    -- 默认发送目标
    --@defaultSendStore int;

  SELECT @userGid = UserGid FROM System;
  SELECT @currentStat = Stat FROM StoreOrdApply WHERE Num = @num;
  SELECT @userProperty = UserProperty FROM System;
  --EXECUTE OptReadInt 700, 'DefaultSendStore', NULL, @defaultSendStore output;

   -- 发送时，如果本店是总部，则不能发送。
  IF @userProperty & 16 = 16 AND NOT (@currentStat IN  (300, 410, 400))
  BEGIN
    SET @msg = '本店是总部，不能发送没有生成定货单的单据。';
    RETURN 1;
  END;

  -- 如果是门店，则不能发送非请求总部批准的单据。
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND @currentStat <> 401
  BEGIN
    SET @msg = '本店是门店，但是不能发送非请求总部批准的单据。';
    RETURN 1;
  END; 

  -- 不是本单位生成的单据不能发送
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND
    (NOT EXISTS (SELECT Num FROM StoreOrdApply WHERE Num = @num AND StoreGid = @userGid))
  BEGIN
    SET @msg = '本店是门店，但试图发送非本单位生成的单据。';
    RETURN 1;
  END

  -- 不是请求总部批准和已完成的单据不能发送
  IF NOT (@currentStat IN (401, 410, 300, 400)) 
  BEGIN
    SET @msg = '非请求总部批准和/或已完成单据不能发送。';
    RETURN 1;
  END;

  -- 存在的单据不能重复发送
  IF @userProperty & 16 = 16
  BEGIN
    DELETE NStoreOrdApply WHERE Num = @num;
    DELETE NStoreOrdApplyDtl WHERE Num = @num;
  END;

  IF @userProperty & 4 = 4 OR @userProperty & 2 = 2 
  BEGIN
    IF EXISTS(SELECT 1 FROM NStoreOrdApply WHERE Num = @num)
    BEGIN
      SET @msg = '该单据已被发送，不能重复发送。';
      RETURN 1;
    END;
  END;

  -- 准备发送。有两种情况：
  -- 1、门店将请求总部批准的单据发送给总部，
  -- 2、总部将已完成的单据发送回门店。
  IF (@userProperty & 4 = 4 OR @userProperty & 2 = 2) AND @currentStat = 401
  BEGIN
    EXECUTE GetNetBillID @maxID OUTPUT;
    IF @maxID IS NULL SET @maxID = 1;

    -- 插入汇总
    INSERT NStoreOrdApply(ID, Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, OpDate, GenNum, Memo, Type, TaxRateLmt, DeptLmt, Src, Checker, GenNum2, SettleNo, ApplyDGid) 
    SELECT @maxID, Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, GETDATE(), GenNum, Memo, Type, TaxRateLmt, DeptLmt, StoreGid, Checker, GenNum2, SettleNo, ApplyDGid
    FROM StoreOrdApply
    WHERE Num = @num AND StoreGid = @userGid AND Stat = 401;

    -- 插入明细
    INSERT NStoreOrdApplyDtl(ID, Num, Src, Line, GDGid, GDCode, QPC, QpcStr, Qty, ApplyQty, Note, ExcgQty)
    SELECT @maxID, d.Num, @userGid, d.Line, d.GDGid, d.GDCode, d.Qpc, d.QpcStr, d.Qty, d.Qty, d.Note, d.ExcgQty
    FROM StoreOrdApplyDtl d, StoreOrdApply m
    WHERE d.Num = @num AND m.Num = d.Num AND m.StoreGid = @userGid AND m.Stat = 401;

    -- 更新
    UPDATE StoreOrdApply
    SET OpDate = GETDATE()
    WHERE Num = @num AND Stat = 401 AND StoreGid = @userGid; 

    UPdATE NStoreOrdApply
    SET Rcv = ApplyDGid
    WHERE Num = @num;

    RETURN 0;
  END;

  -- 总部回发
  IF @userProperty & 16 = 16 AND @currentStat IN (300, 410, 400)
  BEGIN
    EXECUTE GetNetBillID @maxID OUTPUT;
    IF @maxID IS NULL SET @maxID = 1;

    -- 插入汇总
    INSERT NStoreOrdApply(ID, Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, OpDate, GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid) 
    SELECT @maxID, Num, StoreGid, VendorGid, RecCnt, Stat, Filler, FillDate, GETDATE(), GenNum, Memo, Type, TaxRateLmt, DeptLmt, Checker, GenNum2, SettleNo, ApplyDGid
    FROM StoreOrdApply
    WHERE Num = @num AND StoreGid <> @userGid AND Stat IN (300, 410, 400);

    -- 插入明细
    INSERT NStoreOrdApplyDtl(ID, Num, Src, Line, GDGid, GDCode, QPC, QpcStr, Qty, Applyqty, Note, ExcgQty)
    SELECT @maxID, d.Num, m.StoreGid, d.Line, d.GDGid, d.GDCode, d.Qpc, d.QpcStr, d.Qty, d.ApplyQty, d.Note, d.ExcgQty
    FROM StoreOrdApplyDtl d, StoreOrdApply m
    WHERE d.Num = @num AND m.Stat IN (300, 410, 400) AND m.Num = d.Num AND m.StoreGid <> @userGid;

    -- 更新
    UPDATE StoreOrdApply
    SET OpDate = GETDATE()
    WHERE Num = @num AND Stat IN (300, 410, 400) AND StoreGid <> @userGid; 

    UPdATE NStoreOrdApply
    SET Rcv = StoreGid, SndTime = GETDATE()
    WHERE Num = @num;

    RETURN 0;
  END;
  
  SET @msg = '未知错误，请联系您的系统管理员。';
  RETURN 1;
END;
GO
