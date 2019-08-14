SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFDLTNUM](
  @old_num varchar(10),
  @p_oper int,
  @new_num varchar(10),
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
    @old_amtovf money,
    @old_reccnt int,
    @old_note varchar(100),
    @olddtl_gdgid int,
    @olddtl_qtyovf money,
    @olddtl_amtovf money,
    @olddtl_inprc money,
    @olddtl_rtlprc money,
    @olddtl_validdate datetime,
    @olddtl_subwrh int,
    @max_num char(10),
    @g_inprc money,
    @g_rtlprc money,
    @conflict smallint

  select
    @old_settleno = SETTLENO,
    @old_wrh = WRH,
    @old_fildate = FILDATE,
    @old_filler = FILLER,
    @old_checker = CHECKER,
    @old_stat = STAT,
    @old_modnum = MODNUM,
    @old_amtovf = AMTOVF,
    @old_reccnt = RECCNT,
    @old_note = NOTE
    from OVF where NUM = @old_num
  if @old_stat <> 1 begin
    raiserror('被删除的不是已审核过的单据', 16, 1)
    return(1)
  end

  update OVF set STAT = 2 where NUM = @old_num
  select @cur_date = convert(datetime,convert(char,getdate(),102))
  select @cur_settleno = max(NO) from MONTHSETTLE
  insert into OVF (NUM, SETTLENO, WRH,
    FILDATE, FILLER, CHECKER, STAT, MODNUM, AMTOVF,
    RECCNT, NOTE)
  values (@new_num, @cur_settleno, @old_wrh,
    getdate(), @p_oper, @p_oper, 0, @old_num, -@old_amtovf,
    @old_reccnt, @old_note)
  insert into OVFDTL ( NUM, LINE, SETTLENO,
    GDGID, QTYOVF, AMTOVF, INPRC, RTLPRC, VALIDDATE, SUBWRH, COST)/*2002-06-13*/
    select @new_num, LINE, @cur_settleno,
    GDGID, -QTYOVF, -AMTOVF, /*GOODSH.INPRC, GOODSH.RTLPRC 2003-06-13*/INPRC, RTLPRC, VALIDDATE, SUBWRH, -COST/*2002-06-13*/
    from OVFDTL/*, GOODSH*/
    where NUM = @old_num /*and OVFDTL.GDGID = GOODSH.GID*/
  select @return_status = 0
  /*
  declare c_ovfdtl cursor for
    select GDGID, QTYOVF, AMTOVF, INPRC, RTLPRC, VALIDDATE, SUBWRH
    from OVFDTL where NUM = @old_num
  open c_ovfdtl
  fetch next from c_ovfdtl into
    @olddtl_gdgid, @olddtl_qtyovf, @olddtl_amtovf,
    @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh
  while @@fetch_status = 0 begin
    select
      @g_inprc = INPRC,
      @g_rtlprc = RTLPRC
      from GOODS where GID = @olddtl_gdgid
    execute @return_status = UNLOAD
      @old_wrh, @olddtl_gdgid, @olddtl_qtyovf,
      @g_rtlprc, @olddtl_validdate
    if @return_status <> 0 break
    if @olddtl_subwrh is not null
    begin
      execute @return_status = UNLOADSUBWRH
        @old_wrh, @olddtl_subwrh, @olddtl_gdgid, @olddtl_qtyovf
      if @return_status <> 0 break
    end
    execute @return_status = OVFDTLDLTCRT
      @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_wrh, @olddtl_gdgid, @olddtl_qtyovf, @olddtl_amtovf,
      @g_inprc, @g_rtlprc
    if @return_status <> 0 break
    fetch next from c_ovfdtl into
      @olddtl_gdgid, @olddtl_qtyovf, @olddtl_amtovf,
      @olddtl_inprc, @olddtl_rtlprc, @olddtl_validdate, @olddtl_subwrh
  end
  close c_ovfdtl
  deallocate c_ovfdtl
  */
  execute @return_status = OVFCHK @p_num = @new_num, @isneg = 1/*2003-06-13*/, @errmsg = @errmsg output
  if @return_status <> 0 update OVF set STAT = 3 where NUM = @new_num
  return(@return_status)
end
GO
