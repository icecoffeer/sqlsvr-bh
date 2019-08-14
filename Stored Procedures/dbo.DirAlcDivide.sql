SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DirAlcDivide]
(
  @num varchar(10),                -- 单号
  @cls varchar(10) = null,        -- 类型占位府
  @oper varchar(20) = null,     -- 操作人占位府
  @toStat int = -1,                   -- 状态占位府
  @msg varchar(256) output   -- 消息，输出
) AS
BEGIN
  DECLARE @c_billTo int
  DECLARE @enabled int
  DECLARE @i int, @j int
  DECLARE @newNum varchar(14)
  DECLARE @note varchar(256)
  DECLARE @d_gdgid int
  DECLARE @currentClass varchar(10)
  DECLARE @d_line int
  DECLARE
    @tax decimal(24, 4),
    @total decimal(24, 4),
    @alcTotal decimal(24, 4),
    @outTax decimal(24, 4)

  -- 读取选项
  EXECUTE OptReadInt 88, 'EnableBillDivide', 0, @enabled output
  SET @i = 0
  SET @j = 0
  SET @currentClass = '直配进退'
  SET @note = '由' + @currentClass + ' ' + @num + ' 拆分生成。'

  -- 单据不存在时不允许拆分
  IF NOT EXISTS(SELECT 1 FROM DirAlc WHERE Num = @num AND Cls = @currentClass)
  BEGIN
    SET @msg = '单据 ' + @num + ' 不存在，请先保存单据后再次操作'
    RETURN 1
  END

  -- 没有启用拆分则不能拆分
  IF @enabled = 0
  BEGIN
    SET @msg = '您没有启用直配进货退货单拆分功能'
    RETURN 1
  END

  -- 准备拆分，写临时表
  SELECT * INTO #tempmst FROM DirAlc WHERE Num = @num AND Cls = @currentClass
  SELECT * INTO #tempdtl FROM DirAlcDtl WHERE Num = @num AND Cls = @currentClass

  -- 删除当前单据
  DELETE DirAlc WHERE Num = @num AND Cls = @currentClass
  DELETE DirAlcDtl WHeRE Num = @num AND Cls = @currentClass

  -- 声明游标
  DECLARE c CURSOR FOR
    SELECT g.BillTo
    FROM Goods g, #tempmst m, #tempdtl d
    WHERE g.GID = d.GDGid AND m.Num = d.Num AND m.Cls = '直配进退'
    GROUP BY BillTo

  -- 根据游标循环
  OPEN c
  FETCH NEXT FROM c INTO @c_billTo

  WHILE @@FETCH_STATUS = 0
  BEGIN
    -- 成功完成的单据数目
    SET @i = @i + 1

    -- 获取新单号
    EXECUTE GenNextBillNumOld @currentClass, 'DirAlc', @newNum output
    IF @newNum IS NULL
      SET @newNum = -1

    -- 定义明细游标
    DECLARE d CURSOR FOR
      SELECT d.GDGid, d.Line
      FROM #tempdtl d, #tempmst m, Goods g
      WHERE d.GDGid = g.Gid AND m.Num = d.Num AND g.BillTo = @c_billTo AND m.Cls = '直配进退'

    -- 明细编号
    SET @j = 0
    OPEN d
    fETCH NEXT FROM d INTO @d_gdgid, @d_line

    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @j = @j + 1

      -- 插入源单据明细
      INSERT DirAlcDtl
      (
        Cls, Num, Line, SettleNo, GdGid, Wrh, Cases, Qty, Loss,
        Price, Total, Tax, AlcPrc, AlcAmt, WsPrc, InPrc, RtlPrc, ValidDate,
        BckQty, PayQty, BckAmt, PayAmt, BNum, SubWrh, OutTax,
        RcpQty, RcpAmt, Note, Cost, CostPrc, OrdLine, SNewFlag
      )
      SELECT
        Cls, @newNum, @j, SettleNo, GdGid, Wrh, Cases, Qty, Loss,
        Price, Total, Tax, AlcPrc, AlcAmt, WsPrc, InPrc, RtlPrc, ValidDate,
        BckQty, PayQty, BckAmt, PayAmt, BNum, SubWrh, OutTax,
        RcpQty, RcpAmt, Note, Cost, CostPrc, OrdLine, SNewFlag
      FROM #tempdtl
      WHERE Line = @d_line AND Num = @num AND Cls = @currentClass AND GdGid = @d_gdgid

      FETCH NEXT FROM d INTO @d_gdgid, @d_line
    END

    CLOSE d
    DEALLOCATE d

    -- 计算需要插入到汇总中的字段值
    SELECT
      @tax = SUM(Tax), @total = SUM(Total),
      @alcTotal = SUM(AlcPrc), @outTax = SUM(OutTax)
    FROM DirAlcDtl
    WHERE Num = @newNum AND Cls = @currentClass

    -- 插入源单据汇总
    INSERT DirAlc
    (
      Cls, Num, OrdNum, SettleNo, Vendor, Sender, Receiver, OcrDate,
      Psr, Total, Tax, AlcTotal, Stat, Src, SrcNum, SrcOrdNum, SndTime,
      Note, RecCnt, Filler, Checker, ModNum, VendorNum, FilDate, Finished,
      PrnTime, ChkDate, Wrh, Gen, GenBill, GenCls, GenNum, PreChecker,
      PreChkDate, Slr, OutTax, RcpFinished, PayMode, PayDate, SrcOrdCls,
      FromNum, FromCls, Verifier, TaxRateLmt, Dept
    )
    SELECT
      Cls, @newNum, OrdNum, SettleNo, Vendor, Sender, Receiver, OcrDate,
      Psr, @total, @tax, @alcTotal, Stat, Src, SrcNum, SrcOrdNum, SndTime,
      @note, @j, Filler, Checker, ModNum, VendorNum, FilDate, Finished,
      PrnTime, ChkDate, Wrh, Gen, GenBill, GenCls, GenNum, PreChecker,
      PreChkDate, Slr, @outTax, RcpFinished, PayMode, PayDate, SrcOrdCls,
      FromNum, FromCls, Verifier, TaxRateLmt, Dept
    FROM #tempmst
    WHERE Num = @num AND Cls = @currentClass

    FETCH NEXT FROM c INTO @c_billTo
  END

  CLOSE c
  DEALLOCATE c

  -- 删除临时表
  DROP TABLE #tempdtl
  DROP TABLE #tempmst

  SET @msg = '成功，共生成 ' + CONVERT(varchar, @i) + ' 张单据。'
  RETURN 0
END
GO
