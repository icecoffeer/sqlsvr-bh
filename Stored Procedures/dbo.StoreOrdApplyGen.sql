SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[StoreOrdApplyGen]
(
  @num varchar(14),
  @cls varchar(10),
  @oper varchar(20),
  @toStat int,
  @msg varchar(50) OUTPUT
) AS
BEGIN
  DECLARE
    -- 定货单单号
    @newNum varchar(10),
    -- 要货单位
    @receiver int,
    -- 总金额
    @total money,
    -- 税额
    @tax money,
    -- 记录数
    @recordCount int,
    -- 备注
    @note varchar(256),
    -- 期号
    @settleNo int,
    -- 默认总部
    --@defaultSendStore int,
    -- 有效期
    @validPeriod int;

  -- 非总部批准的单据不能生成
  IF EXISTS(SELECT 1 FROM StoreOrdApply WHERE Num = @num AND Stat <> 400)
  BEGIN
    SET @msg = '未经过总部批准的单据不能生成定货单。';
    RETURN 1;
  END; 

  -- 准备生成
  --EXECUTE OptReadInt 700, 'DefaultSendStore', NULL, @defaultSendStore output;
  EXECUTE OptReadInt 114, '有效期', 0, @validPeriod output;
  EXEC GenNextBillNumOld '', 'Ord', @newNum OUTPUT; 
  SELECT @recordCount = RecCnt, @receiver = StoreGid FROM StoreOrdApply WHERE Num = @num;
  SELECT @settleNo = MAX(No) FROM MonthSettle;
  SET @note = '由门店叫货申请单' + @num + ' 自动生成。';
  
  -- 生成明细
  INSERT OrdDtl(SettleNo, Num, Line, GDGid, Qty, Price, Total, Tax)
  SELECT @settleNo, @newNum, sd.Line, sd.GDGid, sd.ApplyQty, g.RtlPrc, ROUND(sd.ApplyQty * g.RtlPrc, 2), ROUND(sd.ApplyQty * g.RtlPrc / (1 + g.TaxRate / 100) * g.TaxRate / 100, 2)
  FROM StoreOrdApplyDtl sd, Goods g
  WHERE sd.GDGid = g.Gid AND sd.Num = @num;

  SELECT @tax = SUM(Tax), @total = SUM(Total) FROM OrdDtl
  WHERE Num = @newNum;

  -- 汇总
  INSERT Ord(SettleNo, Num, Vendor, Total, Tax, Note, RecCnt, Src, SrcNum, Receiver, AlcCls, TaxRateLmt, Dept, ExpDate)
  SELECT @settleNo, @newNum, VendorGid, @total, @tax, @note, @recordCount, ApplyDGid, @num, @receiver, '直配', TaxRateLmt, DeptLmt, DateAdd(DAY, @validPeriod, GETDATE())
  FROM StoreOrdApply
  WHERE Num = @num;

  -- 更新
  UPDATE StoreOrdApply SET Stat = 300, GenNum = @newNum WHERE Num = @num AND Stat = 400;

  -- 如果是门店补货单据，则自动生成调拨单
  IF EXISTS(SELECT 1 FROM StoreOrdApplyType t, StoreOrdApply m WHERE t.Type = m.Type AND t.TypeName = '门店补货' AND m.Num = @num)
  BEGIN
    DECLARE @result int;
    EXEC @result = StoreOrdApplyGenXf @num, @cls, @oper, @toStat, @msg OUTPUT;
    RETURN @result;
  END;
  RETURN 0;
END;
GO
