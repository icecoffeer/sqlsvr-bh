SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdInvChgCHK]
  @num char(10),
  @isneg int, /* 是否冲单.0=否,1=是
                如果是, 则不用当前值更新单据的INPRC和RTLPRC;
                否则, 应该用当前值更新单据的INPRC和RTLPRC*/
  @errmsg varchar(200) = '' output
with encryption as
begin
  declare
    @m_settleno int,      @m_total money,		@m_tax money,
    @m_stat smallint,     @m_note varchar(100),         @m_reccnt int,
    @m_filler int,        @m_checker int,		@m_modnum char(10),
    @m_fildate datetime,  @m_prntime datetime,
    @d_line smallint,     @d_gdgid int,			@d_gdgid2 int,	   @d_qty money,	   @d_price money,
    @d_total money,       @d_tax money,			@d_inprc money,    @d_rtlprc money,	   @d_inprc2 money,    @d_rtlprc2 money,
    @d_wrh int,		  @d_wrh2 int, 			@d_qty2 money,
    @d_relqty money,	  @d_cases2 money,		@d_price2 money,
    @cur_settleno int,    @cur_date datetime,           @return_status int,
    @g_inprc money,	  @g_rtlprc money,	  	@g_inprc2 money,   @g_rtlprc2 money,	@g_qpc2 money,
    @mod_qty money,	  @modnum char(10),  		@i_price money,
    @msg varchar(100),    @d_cost money
  select
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @cur_date = convert(datetime, convert(char(10), getdate(), 102))

  if not exists(select * from GDINVCHG(NOLOCK) where NUM = @num)
    begin
	raiserror('不存在要审核的单据', 16, 1)
	return(1)
    end
  select
    @m_settleno = SETTLENO,
    @m_total = TOTAL,             @m_tax = TAX,
    @m_stat = STAT,		  @m_note = NOTE,
    @m_reccnt = RECCNT,           @m_filler = FILLER,
    @m_checker = CHECKER,         @m_modnum = MODNUM,
    @m_fildate = FILDATE,	  @m_prntime = PRNTIME
  from GDINVCHG(NOLOCK)
  where NUM = @num

  if @m_stat not in (0, 7)
    begin
	raiserror('审核的不是未审核的单据', 16, 1)
	return(1)
    end

  /* 处理明细 */
  declare c_GDINVCHG cursor for
    select
      LINE, GDGID, GDGID2, QTY, PRICE, TOTAL, TAX,
      INPRC, RTLPRC, INPRC2, RTLPRC2, WRH, WRH2, QTY2, CASES2, RELQTY, PRICE2
    from GDINVCHGDTL(NOLOCK) where NUM = @num
  open c_GDINVCHG
  fetch next from c_GDINVCHG into
    @d_line, @d_gdgid, @d_gdgid2, @d_qty, @d_price, @d_total, @d_tax,
    @d_inprc, @d_rtlprc, @d_inprc2, @d_rtlprc2, @d_wrh, @d_wrh2, @d_qty2, @d_cases2, @d_relqty, @d_price2
  while @@fetch_status = 0
  begin
    select @g_inprc = INPRC, @g_rtlprc = RTLPRC
    from GOODSH(nolock) where GID = @d_gdgid

    select @g_inprc2 = INPRC, @g_rtlprc2 = RTLPRC, @g_qpc2 = qpc
    from GOODSH(nolock) where GID = @d_gdgid2

    if @isneg = 0
    begin
	select @d_inprc = @g_inprc, @d_rtlprc = @g_rtlprc
	select @d_inprc2 = @g_inprc2, @d_rtlprc2 = @g_rtlprc2
	update GDINVCHGDTL
		set INPRC = @d_inprc, RTLPRC = @d_rtlprc, INPRC2 = @d_inprc2, RTLPRC2 = @d_rtlprc2
	        where NUM = @num and LINE = @d_line
    end

/* Update inprc */
	execute UPDINVPRC '进货', @d_gdgid2, @d_qty2, @d_total, @d_wrh2
	if @return_status <> 0 break

/* reports */
	execute @return_status = UNLOAD @d_wrh, @d_gdgid, @d_qty, @g_rtlprc, null
	if @return_status <> 0 break
	execute @return_status = LOADIN @d_wrh2, @d_gdgid2, @d_qty2, @g_rtlprc2, null
	if @return_status <> 0 break

	execute UPDINVPRC '销售', @d_gdgid, @d_qty, @d_total, @d_wrh, @d_cost
	if @return_status <> 0 break

	execute @return_status = STKOUTDTLCHKCRT
		'转出', @cur_date, @cur_settleno, @cur_date, @cur_settleno,
		null, null, @d_wrh, @d_gdgid, @d_qty, @d_total, @d_tax, @d_inprc, @d_rtlprc, null, @d_cost, 1, 0 /*2005-05-31*/
	if @return_status <> 0 break

	execute @return_status = STKINDTLCRT
		@cur_date, @cur_settleno, @cur_date, @cur_settleno,
		'转入', @d_wrh2, @d_gdgid2, null, null,
		@d_qty2, @d_price2, @d_total, @d_tax, null, @d_inprc2, @d_rtlprc2, null  --qty, price -> xxx2
	if @return_status <> 0 break

	/* 生成调价差异 */
	if @d_inprc <> @g_inprc or @d_rtlprc <> @g_rtlprc
		insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
	        values (@cur_settleno, @cur_date, @d_gdgid, @d_wrh,
		(@g_inprc-@d_inprc) * @d_qty, (@g_rtlprc-@d_rtlprc) * @d_qty)

  fetch next from c_GDINVCHG into
    @d_line, @d_gdgid, @d_gdgid2, @d_qty, @d_price, @d_total, @d_tax,
    @d_inprc, @d_rtlprc, @d_inprc2, @d_rtlprc2, @d_wrh, @d_wrh2, @d_qty2, @d_cases2, @d_relqty, @d_price2
  end
  close c_GDINVCHG
  deallocate c_GDINVCHG

  update gdinvchg set stat = 1 where num = @num

  return(@return_status)
end
GO
