SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VdrLeGenPrcRateAdj] (
  @Num CHAR(14),
  @OperGid INT,
  @errmsg VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE
    @Line INT,
    @VdrGid int,
    @GdGid int,
    @BillTo int,
    @F1 varchar(64),
    @Brand char(10),
    @PayRate decimal(24,4),
    @OldPrc decimal(24,4),
    @QTY decimal(24,4),
    @AdjAmt decimal(24,4),
    @SumAdjAmt decimal(24,4),
    @SortCode char(13),
    @ShopNo char(30),
    @SettleNo int,
    @GenStat int,
    @AdjClrGds int,
    @UserGid int,
    @RstDept int,
    @RstWrh int,
    @QPC DECIMAL(24,4),
    @QPCSTR CHAR(15),
    @SQL varchar(8000),
    @GoodsTableName varchar(32),
    @GenNum CHAR(10)

  select @UserGid = UserGid, @RstWrh = RstWrh from system
  EXEC OPTREADINT 430, 'RSTDEPT', 0, @RstDept OUTPUT
  EXEC OPTREADINT 86, 'PS3_AdjClrGds', 0, @AdjClrGds OUTPUT
  EXEC OPTREADINT 705, 'GenPrcRateAdjStat', 0, @GenStat OUTPUT

  --生成联销率调整单
  exec GENNEXTBILLNUMOLD '', 'PRCADJ', @GenNum output
  select @SettleNo = Max(NO) from MONTHSETTLE(nolock)

  if (@RstDept = 0) and (@RstWrh = 0)
    set @GoodsTableName = 'GOODS'
  else
    set @GoodsTableName = 'V_GOODS'

  select @VdrGid = VDRGID
    from VDRLESSEE(nolock)
    where NUM = @Num

  set @SQL = 'if exists(select * from master..syscursors where cursor_name = ''c_VdrLeGenPrcRateAdj'')' +
    ' deallocate c_VdrLeGenPrcRateAdj' +
    ' declare c_VdrLeGenPrcRateAdj cursor for' +
    ' select GID, BILLTO, F1, BRAND' +
    ' from ' + @GoodsTableName + '(nolock)' +
    ' where BILLTO = ' + convert(varchar, @VdrGid) +
    ' and SALE = 3'
  if @AdjClrGds = 0
    set @SQL = @SQL + ' and isnull(IsLtd, 0) & 8 <> 8'
  execute(@SQL)

  open c_VdrLeGenPrcRateAdj
  fetch next from c_VdrLeGenPrcRateAdj into @GdGid, @BillTo, @F1, @Brand
  if @@fetch_status <> 0
  begin
    /*set @ErrMsg = '没有可以调整的商品。'
    return 1*/
    close c_VdrLeGenPrcRateAdj
    deallocate c_VdrLeGenPrcRateAdj    
    Return 0
  end

  set @SumAdjAmt = 0
  set @Line = 0
  while @@fetch_status = 0
  begin
    set @Line = @Line + 1

    --获取联销率
    execute VdrLeGetValue @BillTo, @F1, @Brand, @PayRate OUTPUT, @SortCode OUTPUT, @ShopNo OUTPUT

    if (@RstDept = 0) and (@RstWrh = 0)
      select @OldPrc = PAYRATE, @Qty = v.QTY from Goods g, v_inv v
      where g.gid = @GdGid
      and v.GDGID = @GdGid
      and v.store = @usergid
    else
      select @OldPrc = PAYRATE, @Qty = v.QTY from V_Goods g, v_inv v
      where g.gid = @GdGid
      and v.GDGID = @GdGid
      and v.store = @usergid

    if (@RstDept = 0) and (@RstWrh = 0)
      select @QPC = QPCQPC, @QPCSTR = QPCQPCSTR from V_QPCGOODS where Gid = @GdGid
    else
      select @QPC = QPCQPC, @QPCSTR = QPCQPCSTR from V_V_QPCGOODS where Gid = @GdGid

    set @AdjAmt = (@OldPrc - @PayRate) * @QTY / 100
    set @SumAdjAmt = @SumAdjAmt + @AdjAmt

    Insert Into PrcAdjDtl (Cls, Num, Line, SettleNo, GdGid, OldPrc, NewPrc, Qty, QPC, QPCSTR)
      Values('联销率', @GenNum, @Line, @SettleNo, @GdGid, @OldPrc, @PayRate, @Qty, @QPC, @QPCSTR)

    fetch next from c_VdrLeGenPrcRateAdj into @GdGid, @BillTo, @F1, @Brand
  end
  close c_VdrLeGenPrcRateAdj
  deallocate c_VdrLeGenPrcRateAdj

  --未审核
  Insert Into PrcAdj (Cls, Num, SettleNo, Filler, RecCnt, AdjAmt, Stat, Note)
  Values ('联销率', @GenNum, @SettleNo, @OperGid, @Line, @SumAdjAmt, 0,
    '联销贸易协议' + @Num + '审核时自动生成。')
/*
  update PrcAdj set
    AdjAmt = @SumAdjAmt
  where NUM = @GenNum
*/
  if @GenStat = 1
    exec PRCADJCHK '联销率', @GenNum

  return 0
END
GO
