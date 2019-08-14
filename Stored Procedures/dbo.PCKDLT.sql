SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKDLT](
  @p_num char(10)
) with encryption as
begin
  declare
    @return_status int,
    @m_wrh int,
    @m_stat smallint,
    @d_settleno int,
    @d_gdgid int,
    @d_qty money,
    @d_total money,
    @e_gdgid int,
    @mult money,
    @d_subwrh int
  select @return_status = 0
  select
    @m_stat = STAT,
    @m_wrh = WRH
    from PCK where NUM = @p_num
  if @m_stat = 1 begin
    raiserror('该预盘单的数据已全部盘入,不能删除.', 16, 1)
    return(1)
  end
  declare c_pck cursor for select SETTLENO, GDGID, QTY, TOTAL,subwrh
    from PCKDTL
    where NUM = @p_num and STAT = 0
  open c_pck
  fetch next from c_pck into @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  while @@fetch_status = 0 begin
    if (select ISPKG from GOODS where GID = @d_gdgid) = 1
    begin
      /* 如果该商品是大包装的,进行转换 */
      execute @return_status = GETPKG @d_gdgid, @e_gdgid output, @mult output
      /* 99-10-20: getpkg return 1 if found, not 0. */
      if @return_status <> 1 break
      select @return_status = 0
      select @d_gdgid = @e_gdgid, @d_qty = @d_qty * @mult, @d_total = @d_total * @mult
    end
    if @d_subwrh is null select @d_subwrh = 0
   execute @return_status = PCKDTLDLT
      @m_wrh, @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
    if @return_status <> 0 break
    delete from PCKDTL where current of c_pck
    fetch next from c_pck into
      @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  end
  close c_pck
  deallocate c_pck
  if @return_status <> 0 return (@return_status)
  if not exists(select * from PCKDTL where NUM = @p_num)
    delete from PCK where NUM = @p_num
end
GO
