SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKCHK](
  @p_num char(10),
  @ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
  declare
    @return_status int,
    @m_wrh int,
    @d_settleno int,
    @d_gdgid int,
    @d_qty money,
    @d_total money,
    @d_subwrh int,
    @errmsg varchar(200) --ShenMin
  select @return_status = 0
  update PCK set STAT = 0 where NUM = @p_num
  select @m_wrh = WRH from PCK where NUM = @p_num

  --ShenMin
  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'PCK', @piCls = '', @piNum = @p_num, @piToStat = 1, @piOper = @Oper, @piWrh = @m_wrh, @piTag = 0, @piAct = null, @poMsg = @errmsg OUTPUT
  if @return_status <> 0
    begin
    	raiserror(@errmsg, 16, 1)
    	return(1)
    end

  declare c_pck cursor for select SETTLENO, GDGID, QTY, TOTAL,subwrh
    from PCKDTL where NUM = @p_num
  open c_pck
    fetch next from c_pck into @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  while @@fetch_status = 0 begin
  if @d_subwrh is null  select @d_subwrh =0
    execute @return_status = PCKDTLCHK
      @m_wrh, @d_settleno, @d_gdgid, @d_qty, @d_total , @d_subwrh
    if @return_status <> 0 break
    fetch next from c_pck into @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  end
  close c_pck
  deallocate c_pck
  return(@return_status)
end
GO
