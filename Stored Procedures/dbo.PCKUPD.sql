SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKUPD](
  @p_num char(10)
) with encryption as
begin
  declare
    @return_status int,
    @m_wrh int,
    @d_settleno int,
    @d_gdgid int,
    @d_qty money,
    @d_total money,
    @e_gdgid int,
    @mult money,
    @d_subwrh int
  select @return_status = 0
  if exists ( select * from PCKDTL A where NUM = @p_num and
    STAT <> 0 and GDGID not in
    (select GDGID from PCKDTL B where B.NUM = '0000000000' and
    B.STAT <> 0) ) begin
    raiserror('修改单上没有包含原来单据上已盘入或作废的数据.', 16, 1)
    return(1)
  end
  execute @return_status = PCKDLT @p_num
  if @return_status <> 0 return (@return_status)

  delete from PCK where NUM = @p_num
  delete from PCKDTL where NUM = @p_num
  update PCK set NUM = @p_num, STAT = 0 where NUM = '0000000000'
  update PCKDTL set NUM = @p_num where NUM = '0000000000'

  select @m_wrh = WRH from PCK where NUM = @p_num
  declare c_pck cursor for select SETTLENO, GDGID, QTY, TOTAL,subwrh
    from PCKDTL where NUM = @p_num and STAT = 0
  open c_pck
  fetch next from c_pck into @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  while @@fetch_status = 0 begin
    if  @d_subwrh is null  select @d_subwrh = 0
    execute @return_status = PCKDTLCHK
      @m_wrh, @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
    if @return_status <> 0 break
    fetch next from c_pck into
      @d_settleno, @d_gdgid, @d_qty, @d_total,@d_subwrh
  end
  close c_pck
  deallocate c_pck
  return(@return_status)
end
GO
