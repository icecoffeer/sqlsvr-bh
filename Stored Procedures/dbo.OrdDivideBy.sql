SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OrdDivideBy]
(
  @num varchar(10),
  @mode integer,
  @msg varchar(256) OUTPUT
) AS
BEGIN
  DECLARE @TOTAL MONEY,@TAX MONEY
  -- 思想：根据 @num 单号定货单明细中的商品，找到商品所对应的
  -- 理货组(Goods.F3)，然后按理货组将明细进行 Group By 计算。
  -- 则应该将此单据拆分为组数量张单据。

  -- 判断
  IF NOT EXISTS(SELECT 1 FROM Ord WHERE Num = @num AND STAT = 0)
  BEGIN
    SET @msg = '需要拆分的定货单不存在。';
    RETURN 1;
  END;
  
  IF @mode = 1 and (SELECT COUNT(DISTINCT (ISNULL(g.f3, ''))) FROM Goods g(NOLOCK),OrdDtl a(NOLOCK)
   WHERE a.Num = @num AND a.gdgid = g.gid) <= 1
  begin
      set @msg = '商品属于同一个理货组，不需拆分。';
      return 2;
  end;
  
  IF @mode = 2 and (SELECT COUNT(DISTINCT g.wrh) FROM Goods g(NOLOCK),OrdDtl a(NOLOCK)
   WHERE a.Num = @num AND a.gdgid = g.gid) <= 1
  begin
      set @msg = '商品属于同一个仓位，不需拆分。';
      return 3;
  end;
  
  IF @mode = 3 and (select count(*) from (SELECT distinct g.wrh, isnull(g.f3,'')f3 FROM Goods g(NOLOCK),OrdDtl a(NOLOCK)
   WHERE a.Num = @num AND a.gdgid = g.gid group by g.wrh, isnull(g.f3,''))tmp) <= 1
  begin
      set @msg = '商品属于同一个理货组和同一个仓位，不需拆分。';
      return 4;
  end;

  -- 插入临时表
  SELECT * INTO #tempDtl FROM OrdDtl WHERE Num = @num;
  SELECT * INTO #tempMst FROM Ord WHERE Num = @num;

  -- 删除
  DELETE OrdDtl WHERE Num = @num;
  DELETE Ord WHERE Num = @num;

  -- 声明游标  MODIFIED BY GAOLIPING
  IF @mode =1 
  BEGIN
    DECLARE c CURSOR FOR
      SELECT ISNULL(g.F3, '') F3 FROM #tempdtl d, Goods g
      WHERE g.GID = d.GDGid AND Num = @num
      GROUP BY ISNULL(g.F3, '')
  END;
  IF @mode = 2 
  BEGIN
    DECLARE c CURSOR FOR
      SELECT g.wrh FROM #tempdtl d, Goods g
      WHERE g.GID = d.GDGid AND Num = @num
      GROUP BY g.wrh
  END;
  IF @mode = 3
  BEGIN
    DECLARE c CURSOR FOR
      SELECT ISNULL(g.F3, '') F3 , g.WRH FROM #tempdtl d, Goods g
      WHERE g.GID = d.GDGid AND Num = @num
      GROUP BY ISNULL(g.F3, ''),g.wrh
  END;

  DECLARE @i int, @j int;
  DECLARE @c_f3 varchar(64);
  DECLARE @c_wrh varchar(64);
  DECLARE @p_gdgid int;
  DECLARE @newNum varchar(10);

  SET @i = 0;

  OPEN c;
  IF @mode = 1   
      FETCH NEXT FROM c INTO @c_F3;
  IF @mode = 2
      FETCH NEXT FROM c INTO @c_wrh;
  IF @mode = 3
      FETCH NEXT FROM c INTO @c_F3,@c_wrh;

  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @mode = 1
         DECLARE p CURSOR FOR
         SELECT d.GDGid FROM #tempDtl d, Goods g
         WHERE Num = @num AND ISNULL(g.F3, '') = @c_f3 AND g.Gid = d.GDGid  
    IF @mode = 2
         DECLARE p CURSOR FOR
         SELECT d.GDGid FROM #tempDtl d, Goods g
         WHERE Num = @num AND g.wrh = @c_wrh AND g.Gid = d.GDGid 
    IF @mode = 3
         DECLARE p CURSOR FOR
         SELECT d.GDGid FROM #tempDtl d, Goods g
         WHERE Num = @num AND ISNULL(g.F3, '') = @c_f3 AND g.Gid = d.GDGid AND g.wrh = @c_wrh 
    
    OPEN p;
    FETCH NEXT FROM p INTO @p_gdgid;
    SET @j = 0;

    -- 获取新单号
    -- 第一张单据拆分时，取原来单号。
    IF @i = 0 
      SET @newNum = @num;
    ELSE
      EXEC GenNextBillNumOld '', 'Ord', @newNum OUTPUT;

    WHILE @@FETCH_STATUS = 0
    BEGIN
      SET @j = @j + 1;
      -- 插入明细
      INSERT OrdDtl
      (
        SettleNo, Num, Line, GDGid, Cases, Qty, Price, Total, Tax, ValidDate,
        Wrh, InvQty, ArvQty, AsnQty, AllInvQty, Note, FromGid, Flag, InUse,
        LockNum, LockCls, SubWrh
      )
      SELECT 
        d.SettleNo, @newNum, @j, d.GdGid, d.Cases, d.Qty, d.Price, d.Total, d.Tax, d.ValidDate,
        d.Wrh, d.Invqty, d.ArvQty, d.AsnQty, d.AllInvqty, d.Note, d.FromGid, d.Flag, d.InUse,
        d.LockNum, d.LockCls, d.SubWrh
      FROM #tempDtl d, Goods g
      WHERE d.GDGid = @p_gdgid AND g.Gid = d.GDGid;

      SET @i = @i + 1;

      FETCH NEXT FROM p INTO @p_gdgid;
    END;
    SELECT @TOTAL = TOTAL,@TAX = TAX FROM ORDDTL(NOLOCK) WHERE NUM = @newNum
    CLOSE p;
    DEALLOCATE p;

    -- 插入汇总
    if @mode = 1 
      INSERT Ord
      (
        Num, SettleNo, Vendor, Total, Tax, Note, FilDate, PayDate, PrePay, 
        Filler, Checker, Psr, Stat, ModNum, Wrh, RecCnt, Src, SrcNum, 
        SndTime, Receiver, PrnTime, Finished, AlcCls, ExpDate, PreChecker, 
        PreChkDate, DlvbDate, DlveDate, ImpFlag, AlcGid, TaxRateLmt, Dept, Stat2
      )
      SELECT
        @newNum, SettleNo, Vendor, @Total, @Tax, NOTE + '  ' + '由定货单拆分自动生成', GetDate(), PayDate, PrePay,
        Filler, Checker, Psr, Stat, ModNum, Wrh, @j, Src, SrcNum,
        SndTime, Receiver, PrnTime, Finished, AlcCls, ExpDate, PreChecker,
        PreChkDate, DlvbDate, DlveDate, ImpFlag, AlcGid, TaxRateLmt, Dept, Stat2
      FROM #tempMst m WHERE Num = @num; 
    else
      INSERT Ord
      (
        Num, SettleNo, Vendor, Total, Tax, Note, FilDate, PayDate, PrePay, 
        Filler, Checker, Psr, Stat, ModNum, Wrh, RecCnt, Src, SrcNum, 
        SndTime, Receiver, PrnTime, Finished, AlcCls, ExpDate, PreChecker, 
        PreChkDate, DlvbDate, DlveDate, ImpFlag, AlcGid, TaxRateLmt, Dept, Stat2
      )
      SELECT
        @newNum, SettleNo, Vendor, Total, Tax, NOTE + '  ' + '由定货单拆分自动生成', GetDate(), PayDate, PrePay,
        Filler, Checker, Psr, Stat, ModNum, @c_wrh, @j, Src, SrcNum,
        SndTime, Receiver, PrnTime, Finished, AlcCls, ExpDate, PreChecker,
        PreChkDate, DlvbDate, DlveDate, ImpFlag, AlcGid, TaxRateLmt, Dept, Stat2
      FROM #tempMst m WHERE Num = @num;
    
    -- 设置提示信息
    SET @msg = LTRIM(RTRIM(@msg)) + ',' + @newNum;
    if @mode = 1
        FETCH NEXT FROM c INTO @c_F3
    if @mode = 2
        FETCH NEXT FROM c INTO @c_wrh
    if @mode = 3
        FETCH NEXT FROM c INTO @c_F3,@c_wrh
  END;
  
  CLOSE c;
  DEALLOCATE c;

  DROP TABLE #tempdtl;
  DROP TABLE #tempmst;
  RETURN 0;
END;
GO
