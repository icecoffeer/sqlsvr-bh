SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSET_GenFromTempTable](
  @Filler int,
  @Msg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @Num char(14),
    @GdCode varchar(40),
    @GdGid int,
    @VdrCode char(10),
    @VdrGid int,
    @Total money,
    @Qty money,
    @SumTotal money,
    @Amount money,
    @SumAmount money,
    @TaxRate money,
    @Tax money,
    @SumTax money,
    @Line int,
    @Note  varchar(255),
    @LastVdrCode char(10),
    @UserGid int,
    @SettleNo int,
    @Alc  char(10),
    @IsOffsetGoods int,
    @Opt_CSTMINSERT int,
    @Opt_OFFSETTYPE int,
    @Opt_OFFSETCALCTYPE int,
    @Opt_PSRCODE varchar(10),
    @Opt_GatheringMode int,
    @Opt_SETTLEDEPTCODE varchar(10),
    @Ramt money,
    @Psr int,
    @Offsetprc money,
    @DiffPrc money,
    @CntInPrc money,
    @AgmNum char(14),
    @AgmLine int

  set @return_status = 0
  select @UserGid = UserGid from system(nolock)
  select @SettleNo = Max(NO) from MONTHSETTLE(nolock)

  exec OPTREADINT 727, 'CSTMINSERT', 0, @Opt_CSTMINSERT OUTPUT
  exec OPTREADINT 727, 'OFFSETTYPE', 0, @Opt_OFFSETTYPE OUTPUT
  exec OPTREADINT 727, 'OFFSETCALCTYPE', 0, @Opt_OFFSETCALCTYPE OUTPUT
  exec OPTREADSTR 727, 'PSRCODE', '-', @Opt_PSRCODE OUTPUT
  exec OPTREADINT 727, 'GatheringMode', 0, @Opt_GatheringMode OUTPUT
  exec OPTREADSTR 727, 'SETTLEDEPTCODE', '', @Opt_SETTLEDEPTCODE OUTPUT

  if @Opt_CSTMINSERT <> 1
  begin
    set @Msg = '未启用手工录入,不能从XLS文件导入!'
    return 1
  end

  --清空生成单据临时表
  
  delete from PRMOFFSETXLSGENNUM where SPID = @@spid

  --开始生成

  set @LastVdrCode = ''

  if exists(select * from master..syscursors where cursor_name = 'c_PRMOFFSETXLSTEMP')
    deallocate c_PRMOFFSETXLSTEMP
  declare c_PRMOFFSETXLSTEMP cursor for
    select GDCODE, VDRCODE, QTY, TOTAL, NOTE, AGMNUM, AGMLINE
      from PRMOFFSETXLSTEMP(nolock)
      where SPID = @@spid
    order by GDCODE, VDRCODE
  open c_PRMOFFSETXLSTEMP
  fetch next from c_PRMOFFSETXLSTEMP into
    @GdCode, @VdrCode, @Qty, @Total, @Note, @AgmNum, @AgmLine
  while @@fetch_status = 0
  begin
    select @GdGid = GID , @IsOffsetGoods = IsOffsetGoods from GOODS(nolock)
      where CODE = @GdCode
    if @@rowcount = 0
    begin
      set @Msg = '商品代码 ' + @GdCode + ' 无效。'
      set @return_status = 1
      break
    end

    if @IsOffsetGoods = 0
    begin
      set @Msg = '商品代码为 ' + @GdCode + ' 的商品不是补差商品。'
      set @return_status = 1
      break
    end

    select @VdrGid = GID from VENDOR(nolock)
      where CODE = @VdrCode
    if @@rowcount = 0
    begin
      set @Msg = '供应商代码 ' + @VdrCode + ' 无效。'
      set @return_status = 1
      break
    end

    if not exists (select * from VDRGD where VDRGID = @VdrGid and GDGID = @GdGid)
    begin
      set @Msg = '供应商 ' + @VdrCode + ' 与商品' + @GdCode + '不匹配。'
      set @return_status = 1
      break
    end
    
    select @Alc = alc, @CntInPrc = CntInPrc, @TaxRate = TaxRate from goods
      where BillTo = @VdrGid and Gid = @GdGid
    if @@rowcount = 0
    begin
      set @Msg = '无供应商 ' + @VdrCode + ' 下商品' + @GdCode + '供应信息！'
      set @return_status = 1
      break
    end
    
    --开始生成促销补差单据

    --汇总，按供应商不同分单

    if @VdrCode <> @LastVdrCode
    begin
      set @LastVdrCode = @VdrCode
      set @Line = 0
      set @SumTotal = 0
      set @SumAmount = 0
      set @SumTax = 0

      select @Psr = gid from employee where code = @Opt_PSRCODE
      if (@Psr is null) or (@@rowcount = 0)
        set @Psr = 1

      exec GENNEXTBILLNUMEX '', 'PRMOFFSET', @Num output

      --插入促销补差单汇总
      INSERT INTO PrmOffset(Num, VdrGid, SettleNo, FilDate, Filler, LSTUPDTIME, Reccnt, Src, Stat,
        Note, EOn, BillTo, OffsetType, OffsetCalcType, GatheringMode,
        CHGNUM, DeptLmt, PAYFLAG, SETTLEDEPTCODE, PSR, TOTAL, AMOUNT, TAX,
        PAYDIRECT, BTYPE)
      VALUES (@Num, @VdrGid, @SettleNo, getdate(), @Filler, getdate(), 0, @UserGid, 0,
        '由EXCEL文件导入生成', 1, @VdrGid, @Opt_OFFSETTYPE, @Opt_OFFSETCALCTYPE, @Opt_GatheringMode,
        '', '', 0, @Opt_SETTLEDEPTCODE, @Psr, 0, 0, 0,
        1, 1)

      --生效门店
      insert into PRMOFFSETLACDTL(NUM, STOREGID)
        select @Num, @UserGid
        
      --生成单据临时表
      insert into PRMOFFSETXLSGENNUM(SPID, NUM) values(@@spid, @Num)
    end

    --明细们

    set @Line = @Line + 1
    set @Ramt = @Total
    if @Qty = 0
      set @Offsetprc = @Ramt
    else
      set @Offsetprc = @Ramt / @Qty
    set @DiffPrc = @OffsetPrc
    if @AgmNum = ''
      set @AgmNum = '-'
      
    set @Tax = round(@TaxRate * @Total /(100 + @TaxRate), 2)
    set @Amount = @Total - @Tax
    set @SumTotal = @SumTotal + @Total
    set @SumTax = @SumTax + @Tax
    set @SumAmount = @SumAmount + @Amount

    --明细

    INSERT INTO PrmOffsetDtl(Num, Line, SettleNo, GDGid, Qpc, QpcStr,
      AGMNUM, SAMT, RAMT, OffsetPrc, CntInPrc, Qty,
      Start, Finish, Note, Alc, Total, Tax, Amount, DiffPrc,
      PAYQTY, PAYAMT, SQTY, AGMTABLENAME)
    VALUES (@Num, @Line, @SettleNo, @GdGid, 1, '1*1',
      @AgmNum, @Ramt, @Ramt, @Offsetprc, @CntInPrc, @Qty,
      convert(varchar(10), getdate(), 121), convert(varchar(10), getdate() + 1, 121), @Note,
      @Alc, @Total, @Tax, @Amount, @DiffPrc,
      0, 0, @Qty, '')
    
    --协议号不为空且行号有效时更新协议行号
    if @AgmNum <> '' and @AgmLine <> 0 
      update PrmOffsetDtl set AgmLine = @AgmLine where Num = @Num  and Line = @Line

    --明细2

    insert into PRMOFFSETDTLDTL(NUM, LINE, ITEM, GDGID, STOREGID, AGMNUM,  SAMT, RAMT, SQTY, RQTY, AGMTABLENAME)
      select @Num, @Line, 1, @GdGid, @UserGid, @AgmNum, @Ramt, @Ramt, @Qty, @Qty, ''

    --协议号不为空且行号有效时更新协议行号
    if @AgmNum <> '' and @AgmLine <> 0 
      update PRMOFFSETDTLDTL set AgmLine = @AgmLine where Num = @Num and Line = @Line 
    --下一条记录

    fetch next from c_PRMOFFSETXLSTEMP into
      @GdCode, @VdrCode, @Qty, @Total, @Note, @AgmNum, @AgmLine

    --更新汇总

    if (@@fetch_status = 0 and @VdrCode <> @LastVdrCode) or @@fetch_status <> 0
    begin
      update PrmOffset set
        Reccnt = @Line,
        TOTAL = @SumTotal,
        AMOUNT = @SumAmount,
        TAX = @SumTax
      where NUM = @Num
    end
  end
  close c_PRMOFFSETXLSTEMP
  deallocate c_PRMOFFSETXLSTEMP
  return @return_status
end
GO
