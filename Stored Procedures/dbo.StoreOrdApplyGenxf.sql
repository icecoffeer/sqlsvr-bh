SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreOrdApplyGenxf]
(
  @num varchar(14),
  @cls varchar(10),
  @oper varchar(20),
  @toStat int,
  @msg varchar(50) OUTPUT
) AS
BEGIN
  DECLARE
    -- 单号
    @newNum varchar(10),
    -- 总金额
    @total money,
    -- 记录数
    @recordCount int,
    -- 备注
    @note varchar(256),
    -- 期号
    @settleNo int,
    -- 调入仓位
    @fromWrh int,
    -- 调出仓位
    @toWrh int,
    -- 税
    @tax int,
    -- 库存陈本
    @invCost decimal(24, 4);

  -- 非总部批准的单据不能生成
  IF EXISTS(SELECT 1 FROM StoreOrdApply WHERE Num = @num AND Stat <> 400)
  BEGIN
    SET @msg = '未经过总部批准的单据不能生成调拨单。';
    RETURN 1;
  END; 

  IF NOT EXISTS(SELECT 1 FROM StoreOrdApply a, StoreOrdApplyType t WHERE t.Type = a.Type AND t.TypeName = '门店补货' AND a.Num = @num)
  BEGIN
    SET @msg = '没有找到类型为门店补货的单据，无法生成调拨单。';
    RETURN 1;
  END;

  -- 准备生成
  EXEC GenNextBillNumOld '', 'Xf', @newNum OUTPUT; 
  SELECT @recordCount = RecCnt FROM StoreOrdApply WHERE Num = @num;
  SELECT @settleNo = MAX(No) FROM MonthSettle;
  SET @note = '由门店叫货申请单' + @num + ' 自动生成。';

  SELECT @fromWrh = Gid FROM Warehouse WHERE Code = '0';
  IF @@ROWCOUNT = 0 
  BEGIN
    SET @msg = '没有找到采购中心仓(代码为“0”，不能生成调拨单。)';
    RETURN 1;
  END;

  SELECT @toWrh = w.Gid FROM Warehouse w, StoreOrdApply a, Store s WHERE s.Gid = a.StoreGid AND s.Code = w.Code AND a.Num = @num;
  IF @@ROWCOUNT = 0
  BEGIN
    SET @msg = '没有门店默认仓位，不能生成调拨单';
    RETURN 1;
  END;
  
  -- 生成明细
  INSERT XfDtl
  (
    SettleNo, Num, Line, GDGid, ValidDate, Qty, Amt, InPrc, RtlPrc, InQty, OutQty, InTotal, 
    OutTotal, FromSubWrh, ToSubWrh, InvCost, InInPrc, InRtlPrc, Price, Tax, Cost
  )
  SELECT @settleNo, @newNum, sd.Line, sd.GDGid, NULL, sd.ExcgQty, ROUND(sd.ExcgQty * g.RtlPrc, 2), g.InPrc, g.RtlPrc, 0, sd.ExcgQty, 0,
  ROUND(g.RtlPrc * sd.ExcgQty, 2), NULL, NULL, ROUND(g.InvPrc * sd.ExcgQty, 2), 0, 0, ROUND(g.RtlPrc * sd.ExcgQty, 2), ROUND((g.RtlPrc * g.TaxRate) / (100 + g.TaxRate) * sd.ExcgQty, 2), ROUND(g.RtlPrc * sd.ExcgQty, 2)
  FROM StoreOrdApplyDtl sd, Goods g
  WHERE sd.GDGid = g.Gid AND sd.Num = @num;

  SELECT @tax = SUM(Tax), @total = SUM(Amt), @invCost = SUM(InvCost), @recordCount = COUNT(1) FROM Xf
  WHERE Num = @newNum;

  -- 汇总
  INSERT Xf
  (
    Num, SettleNo, Fildate, Filler, Checker, FromWrh, ToWrh, Amt, Stat, Reccnt, Note, AFlag, 
    PrnTime, InvCost, OutEmp, OutDate, InEmp, InDate, Tax, SrcStkinNum
  )
  VALUES
  (
    @num, @settleNo, GETDATE(), @oper, @oper, @fromWrh, @toWrh, @total, 0, @recordCount, @note, 0,
    NULL, @invCost, NULL, NULL, NULL, NULL, @tax, NULL
  )

  -- 更新
  UPDATE StoreOrdApply SET Stat = 300, GenNum2 = @newNum WHERE Num = @num AND Stat = 400;
  RETURN 0;
END;
GO
