SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LSCHK](
  @p_num char(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @cur_settleno int,
    @m_wrh int,
    @m_filler int,
    @m_stat smallint,
    @m_amtls money,
    @d_settleno int,
    @d_gdgid int,
    @d_qtyls money,
    @d_amtls money,
    @d_inprc money,
    @d_rtlprc money,
    @d_validdate datetime,
    @d_subwrh int,
    @d_line smallint,
    @d_outcost money /*2002-06-13*/,
    @sale smallint, /*2003-06-13*/
    @errMsg VARCHAR(200) --ShenMin
  select
    @cur_date = convert(datetime,convert(char,getdate(),102)),
    @cur_settleno = SETTLENO,
    @m_wrh = WRH,
    @m_stat = STAT,
    @m_amtls = AMTLS
    from LS where NUM = @p_num
  if @m_stat <> 0 begin
    raiserror('被审核的不是未审核的单据', 16, 1)
    return(1)
  end

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'LS', @piCls = '', @piNum = @p_num, @piToStat = 1, @piOper = @Oper, @piWrh = @m_wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return(1)
    end

  select @cur_settleno = max(NO) from MONTHSETTLE
  update LS set STAT = 1, FILDATE = getdate(), SETTLENO = @cur_settleno
  where NUM = @p_num
  select @return_status = 0
  declare c_lsdtl cursor for
    select LINE, GDGID, QTYLS, AMTLS, INPRC, RTLPRC, VALIDDATE, SUBWRH
    from LSDTL where NUM = @p_num
    for update
  open c_lsdtl
  fetch next from c_lsdtl into @d_line,
    @d_gdgid, @d_qtyls, @d_amtls, @d_inprc, @d_rtlprc, @d_validdate, @d_subwrh
  while @@fetch_status = 0 begin
    -- update detail set inprc, rtlprc to current values *
    select @d_inprc = INPRC, @d_rtlprc = RTLPRC, @sale = SALE/*2003-06-13*/
      from GOODSH where GID = @d_gdgid
    update LSDTL set INPRC = @d_inprc, RTLPRC = @d_rtlprc
      where NUM = @p_num and LINE = @d_line
    -- inventory
    execute @return_status = UNLOAD
      @m_wrh, @d_gdgid, @d_qtyls, @d_rtlprc, @d_validdate
    if @return_status <> 0 break
    if @d_subwrh is not null
    begin
      execute @return_status = UNLOADSUBWRH
        @m_wrh, @d_subwrh, @d_gdgid, @d_qtyls
      if @return_status <> 0 break
    end
    /*2002-06-13*/
    execute UPDINVPRC '销售', @d_gdgid, @d_qtyls, 0, @m_wrh, @d_outcost output /*2002.08.18*/
    if @sale = 1
        update LSDTL set COST = @d_outcost
            where NUM = @p_num and LINE = @d_line
    else --2004-08-12
        update LSDTL set COST = @d_qtyls * @d_inprc
            where NUM = @p_num and LINE = @d_line
    -- reports
    if @sale = 1/*2003-06-13*/
    execute @return_status = LSDTLCHK
      @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyls, @d_amtls,
      @d_inprc, @d_rtlprc, @d_outcost /*2002-06-13*/
    else
    execute @return_status = LSDTLCHK
      @cur_date, @cur_settleno, @m_wrh, @d_gdgid, @d_qtyls, @d_amtls,
      @d_inprc, @d_rtlprc
    if @return_status <> 0 break
    fetch next from c_lsdtl into @d_line,
      @d_gdgid, @d_qtyls, @d_amtls, @d_inprc, @d_rtlprc, @d_validdate, @d_subwrh
  end
  close c_lsdtl
  deallocate c_lsdtl
  return(@return_status)
end
GO
