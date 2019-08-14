SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DirDltNum]
  @cls char(10),
  @num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
with encryption as
begin
  /*
  99-8-30: 负单的OCRDATE应和废单的一致
  */
  declare
    @cur_date datetime,      @cur_settleno int,         @return_status int,
    @m_stat smallint,        @mode smallint,            @dsp_num char(10),
    @dsp_stat int,           @gendsp int,
    @m_paymode char(10)/*2002-01-17*/, @m_src int,      @optvalue int /*2002-08-14*/

  declare @RistrictCurDayOpt int, @m_FILDATE DATETIME --CHAR(10) CLASS
  select @m_FILDATE = CONVERT(DATETIME,CONVERT(CHAR(10),fildate,102) )  --DIRALC审核时间
  from DIRALC where CLS = @cls and NUM = @num    			--Fanduoyi 1717
  exec optreadint 0, '禁止进货单和进货退货单隔天冲单修正', 0, @RistrictCurDayOpt output
  if @RistrictCurDayOpt = 1
    if @m_FILDATE < CONVERT(DATETIME,CONVERT(CHAR(10),GETDATE(),102) )
    BEGIN
      raiserror('禁止进货单和进货退货单隔天冲单修正！[同名选项]', 16, 1)
      SET @errmsg = '禁止进货单和进货退货单隔天冲单修正！[同名选项]'
      return -1
    end

  select
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @cur_date = convert(datetime, convert(char(10), getdate(), 102)),
    @m_stat = STAT,
    @m_paymode = PAYMODE/*2002-01-17*/,
    @m_src = SRC/*2002-08-14*/
    from DIRALC where CLS = @cls and NUM = @num

  if @m_stat <> 1 and @m_stat <> 6
  begin
    raiserror('被冲单的不是已审核或已复核的单据', 16, 1)
    return 1
  end

  /* 2000-11-02 */
  if @m_stat=6 and (select payflag from system)=1
  begin
    select @errmsg = '已复核的单据不能冲单或修正'
    raiserror(@errmsg, 16, 1)
    return(1)
  end

  /* 00-3-30 */
  execute @return_status = CanDeleteBill 'DIRALC', @cls, @num, @errmsg output
  if @return_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  update DIRALC set STAT = 2 where CLS = @cls and NUM = @num

  /* 2000-2-28 对提单的处理 */
  if (@cls = '直配进退') and (select DSP from SYSTEM) & 128 <> 0
    select @gendsp = 1
  else
    select @gendsp = 0
  if @gendsp = 1
  begin
    select @dsp_num = null
    select @dsp_num = num, @dsp_stat = STAT from dsp
      where cls = 'DIRALC' and posnocls = @cls and flowno = @num
    /* 检查提货单是否已被提货 */
    if @dsp_num is not null
    begin
      if @dsp_stat <> 0
      begin
        select @return_status = 2
        raiserror( '该单据已被提货,不能冲单.', 16, 1 )
        return
      end
      execute @return_status = DSPABORT @dsp_num
      if @return_status <> 0
      begin
        select @return_status = 3
        raiserror( '不能作废相关的提单.', 16, 1 )
        return
      end
    end
  end

  if @m_stat = 1 select @mode = 0
  if @m_stat = 6 select @mode = 2

  insert into DIRALC (CLS, NUM, SETTLENO, VENDOR, SENDER, RECEIVER, OCRDATE,
    PSR, TOTAL, TAX, ALCTOTAL, STAT, SRC, SRCNUM, SNDTIME, NOTE, RECCNT,
    FILLER, CHECKER, MODNUM, VENDORNUM, FILDATE, FINISHED, PRNTIME,
    /*2000-2-25*/ PRECHECKER, PRECHKDATE, SLR, OUTTAX,
    /* 2000-2-28 */ WRH, /* 2001-05-29 */ORDNUM, PAYMODE/*2002-01-17*/,FROMNUM, FROMCLS, GENBILL/*2005-8-13*/)
  select CLS, @neg_num, @cur_settleno, VENDOR, SENDER, RECEIVER, OCRDATE,
    PSR, -TOTAL, -TAX, -ALCTOTAL, 0, SRC, SRCNUM, SNDTIME, NOTE, RECCNT,
    @new_oper, @new_oper, @num, VENDORNUM, @cur_date, FINISHED, null,
    /*2000-2-25*/ PRECHECKER, PRECHKDATE, SLR, -OUTTAX, /*2000-11-23*/
    /* 2000-2-28 */ WRH,  /* 2001-05-29 */ORDNUM,PAYMODE,FROMNUM, FROMCLS, GENBILL/*2005-8-13*/
  from DIRALC
  where CLS = @cls and NUM = @num

  /* 2002-08-14 2002-10-25 2002-10-28*/
  if @m_src = (select USERGID from SYSTEM)
  begin
    exec OPTREADINT 0, 'AutoOcrDate', 0, @optvalue output
    if @optvalue = 1
    begin
      update DIRALC set OCRDATE = getdate()
      where CLS = @cls and NUM = @neg_num
    end
  end

  insert into DIRALCDTL (CLS, NUM, LINE, SETTLENO, GDGID, WRH, CASES, QTY,
    LOSS, PRICE, TOTAL, TAX, ALCPRC, ALCAMT, WSPRC, INPRC, RTLPRC, VALIDDATE,
    BCKQTY, PAYQTY, BCKAMT, PAYAMT, BNUM, SUBWRH,
    /* 2000-2-25 */ OUTTAX, /*2000-8-17*/ RCPQTY, RCPAMT,
    COST/*2002-06-13*/, ORDLINE, DECORDQTY/*2003-08-27*/)
  select CLS, @neg_num, LINE, @cur_settleno, GDGID, D.WRH, -CASES, -QTY,
    -LOSS, PRICE, -TOTAL, -TAX, ALCPRC, -ALCAMT, WSPRC, INPRC, RTLPRC,
    VALIDDATE, -BCKQTY, /*2000-8-17 -PAYQTY*/0, -BCKAMT, /*2000-8-17 -PAYAMT*/0, null, SUBWRH,
    /* 2000-2-25 */ /* 2002-11-12 */ -OUTTAX, 0, 0, -COST/*2002-06-13*/, ORDLINE, -DECORDQTY
  from DIRALCDTL D
  where D.CLS = @cls and D.NUM = @num

  execute @return_status = DIRCHK @cls, @neg_num, @mode, 1
  if @return_status <> 0 return @return_status
  update DIRALC set STAT = 4 where CLS = @cls and NUM = @neg_num

  return @return_status
end
GO
