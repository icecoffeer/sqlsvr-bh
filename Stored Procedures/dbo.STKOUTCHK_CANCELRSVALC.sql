SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[STKOUTCHK_CANCELRSVALC](
  @old_cls char(10),
  @old_num char(10),
  @new_oper int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
)
--With Encryptions
As
begin
  declare
    @max_num char(10),
    @neg_num char(10),
    @conflict smallint,
    @OptionValue_RCPCST char(1)
  declare
    @return_status int,       @vdr int,
    @old_settleno int,        @old_client int,          @old_ocrdate datetime,
    @old_total money,         @old_tax money,           @old_wrh int,
    @old_fildate datetime,    @old_stat smallint,       @old_slr int,
    @old_reccnt int,          @old_billto int,          @old_gdgid int,
    @old_qty money,           @oldd_total money,        @oldd_tax money,
    @old_inprc money,         @old_rtlprc money,        @old_validdate datetime,
    @old_src int,             @cur_date datetime,       @cur_settleno int,
    @cur_inprc money,         @cur_rtlprc money,        @ordnum char(10),
    @paymode char(10),        @temp_qty money,          @temp_total money,
    @temp_tax money,          @money1 money,            @old_subwrh int,
    @old_gen int,        @dsp_num char(10),        @dsp_stat smallint,
    @gendsp smallint

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @old_cls, @piNum = @old_num, @piToStat = 16, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg output
  if @return_status <> 0 return -1

  select
    @old_settleno = SETTLENO,
    @old_client = CLIENT,
    @old_ocrdate = OCRDATE,
    @old_total = TOTAL,
    @old_tax = TAX,
    @old_wrh = WRH,
    @old_fildate = FILDATE,
    @old_stat = STAT,
    @old_slr = SLR,
    @old_reccnt = RECCNT,
    @old_src = SRC,
    @old_billto = BILLTO,
    @old_gen = GEN,
    @ordnum = ORDNUM,
    @paymode = PAYMODE
    from STKOUT(nolock) where CLS = @old_cls and NUM = @old_num

  if @old_stat <> 15 begin
    set @poMsg = '删除的不是已待配的单据'
    return 1
  end
  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @neg_num output
    if exists (select * from STKOUT(nolock) where CLS = @old_cls and NUM = @neg_num)
      select @max_num = @neg_num, @conflict = 1
    else
      select @conflict = 0
  end

  select
    @return_status = 0,
    @cur_settleno = max(NO)
    from MONTHSETTLE

  update STKOUT set STAT = 2 where CLS = @old_cls and NUM = @old_num

  insert into STKOUT (CLS, NUM, SETTLENO, CLIENT, OCRDATE, TOTAL,
    TAX, WRH, FILDATE, FILLER, CHECKER, STAT, MODNUM, SLR, RECCNT, SRC, ORDNUM,
    BILLTO, PAYMODE)
    values (@old_cls, @neg_num, @cur_settleno, @old_client,
    @old_ocrdate, -@old_total, -@old_tax, @old_wrh, getdate(),
    @new_oper, @new_oper, 16, @old_num, @old_slr, @old_reccnt, @old_src, @ordnum,
    @old_billto, @paymode)
  insert into STKOUTDTL (CLS, NUM, LINE, SETTLENO, GDGID, QTY, WSPRC,
    PRICE, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, SUBWRH, RCPQTY, RCPAMT, RSVALCQTY)
    select CLS, @neg_num, LINE, @cur_settleno, GDGID, -QTY, WSPRC,
    PRICE, -TOTAL, -TAX, INPRC, RTLPRC, VALIDDATE, STKOUTDTL.WRH, SUBWRH, 0, 0, -ISNULL(RSVALCQTY, 0)
    from STKOUTDTL(nolock)
    where CLS = @old_cls and NUM = @old_num

  /*减少预配数*/
  declare @Opqty money, @m_store int
  select @m_store = usergid from system
  declare c_Procalcgft1 cursor for
  select gdgid, ISNULL(RSVALCQTY, 0)
  from stkoutdtl(nolock)
  where cls = @old_cls and num = @old_num order by line
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @old_gdgid, @old_qty
  while @@fetch_status = 0
  begin
    exec @return_status = DecPreAlcQty @piStore = @m_store, @piWrh = @old_wrh, @piGdgid = @old_gdgid, @piQty = @old_qty, @piMode = -1, @poOpqty = @Opqty output --zhangzhen 20071114
    if @return_status <> 0
    begin
      close c_Procalcgft1
      deallocate c_Procalcgft1
      return @return_status
    end
    fetch next from c_Procalcgft1 into @old_gdgid, @old_qty
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    set @poMsg = '处理单据时发生错误.'
    return (@return_status)
  end

    /*2006-5-21 待配冲单 由15 - 16 (实际15 - 2)杨赛 Add*/
  if @old_cls = '配货'
  begin
    select * from EPSSENDSTKOUT where num = @old_num
    if @@RowCount = 0
      insert into EPSSENDSTKOUT values(@old_num, @old_client, 1)
    else
      delete from EPSSENDSTKOUT where num = @old_num
  end

  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @old_cls, @piNum = @old_num, @piToStat = 16, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
