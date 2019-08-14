SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LSDLT](
  @old_num char(10),
  @p_oper int,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,
    @cur_date datetime,
    @cur_settleno int,
    @old_settleno int,
    @old_wrh int,
    @old_fildate datetime,
    @old_filler int,
    @old_checker int,
    @old_stat smallint,
    @old_modnum char(10),
    @old_amtls money,
    @old_reccnt int,
    @old_note varchar(100),
    @old_prntime datetime,
    @olddtl_gdgid int,
    @olddtl_qtyls money,
    @olddtl_amtls money,
    @olddtl_inprc money,
    @olddtl_rtlprc money,
    @olddtl_validdate datetime,
    @olddtl_subwrh int,
    @olddtl_cost money, /*2002-06-13*/
    @cur_inprc money,
    @cur_rtlprc money,
    @new_num char(10),
    @max_num char(10),
    @old_cause varchar(40),
    @conflict smallint,
    @sale smallint/*2003-06-13*/
  select
    @old_settleno = SETTLENO,
    @old_wrh = WRH,
    @old_fildate = FILDATE,
    @old_filler = FILLER,
    @old_checker = CHECKER,
    @old_stat = STAT,
    @old_modnum = MODNUM,
    @old_amtls = AMTLS,
    @old_reccnt = RECCNT,
    @old_note = NOTE,
    @old_prntime = PRNTIME,
    @old_cause = cause
    from LS where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被删除的不是已审核过的单据', 16, 1)
    return(1)
  end

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'LS', '', @old_num, 2, @Oper,@old_wrh, 1, 1, @errmsg output
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return(1)
    end

  /* 2000-06-12 */
  execute @return_status = CanDeleteBill 'LS', '', @old_num, @errmsg output
  if @return_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  /* find the @neg_num */
  select @conflict = 1, @max_num = @old_num
  while @conflict = 1
  begin
    execute NEXTBN @max_num, @new_num output
    if exists (select * from LS where NUM = @new_num)
      select @max_num = @new_num, @conflict = 1
    else
      select @conflict = 0
  end

  update LS set STAT = 2 where NUM = @old_num
  select @cur_date = convert(datetime,convert(char,getdate(),102))
  select @cur_settleno = max(NO) from MONTHSETTLE
  insert into LS(NUM, SETTLENO, WRH, FILDATE, FILLER, CHECKER, STAT, MODNUM, AMTLS, RECCNT, NOTE, PRNTIME, CAUSE) values (@new_num, @cur_settleno, @old_wrh,
    getdate(), @p_oper, @p_oper, 4, @old_num, -@old_amtls,
    @old_reccnt, @old_note, @old_prntime, @old_cause) /* added (null, null) by yangsai 2006-04-29 6637 任务单*/
  insert into LSDTL (NUM, LINE, SETTLENO,
    GDGID, QTYLS, AMTLS, INPRC, RTLPRC, VALIDDATE, SUBWRH,
    COST) /*2002-06-13*/
    select @new_num, LINE, @cur_settleno,
    GDGID, -QTYLS, -AMTLS, /*GOODSH.INPRC, GOODSH.RTLPRC 2003-06-13*/INPRC, RTLPRC, VALIDDATE, SUBWRH,
    -COST /*2002-06-13*/
    from LSDTL/*, GOODSH*/
    where NUM = @old_num /*and LSDTL.GDGID = GOODSH.GID 2003-06-13*/
  select @return_status = 0
  declare c_lsdtl cursor for
    select GDGID, QTYLS, AMTLS, INPRC, RTLPRC, VALIDDATE, SUBWRH,
    COST /*2002-06-13*/
    from LSDTL where NUM = @old_num
  open c_lsdtl
  fetch next from c_lsdtl into
    @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
    @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh,
    @olddtl_cost /*2002-06-13*/
  while @@fetch_status = 0 begin
    select
      @cur_inprc = INPRC,
      @cur_rtlprc = RTLPRC,
      @sale = SALE/*2003-06-13*/
      from GOODS where GID = @olddtl_gdgid
    execute UPDINVPRC '进货', @olddtl_gdgid, @olddtl_qtyls, @olddtl_cost, @old_wrh /*2002-06-13 2002.08.18*/
    execute @return_status = LOADIN
      @old_wrh, @olddtl_gdgid, @olddtl_qtyls,
      @cur_rtlprc, @olddtl_validdate
    if @return_status <> 0 break
    if @olddtl_subwrh is not null
    begin
      execute @return_status = LOADINSUBWRH
        @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @olddtl_qtyls,
        /* 2000-06-12 */@olddtl_inprc
      if @return_status <> 0 break
    end
    if @sale = 1/*2003-06-13*/
    execute @return_status = LSDTLDLTCRT
      @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_wrh, @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
      @olddtl_inprc, @olddtl_rtlprc, @olddtl_cost /*2002-06-13*/
    else
    execute @return_status = LSDTLDLTCRT
      @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_wrh, @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
      @olddtl_inprc, @olddtl_rtlprc
    if @return_status <> 0 break

    if @olddtl_inprc <> @cur_inprc or @olddtl_rtlprc <> @cur_rtlprc  /*2003-06-13*/
    begin
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @olddtl_gdgid, @old_wrh,
        case @sale when 1 then 0 else (@cur_inprc-@olddtl_inprc) * @olddtl_qtyls end, (@cur_rtlprc-@olddtl_rtlprc) * @olddtl_qtyls)
    end

    fetch next from c_lsdtl into
      @olddtl_gdgid, @olddtl_qtyls, @olddtl_amtls,
      @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh,
      @olddtl_cost /*2002-06-13*/
  end
  close c_lsdtl
  deallocate c_lsdtl
  return(@return_status)
end
GO
