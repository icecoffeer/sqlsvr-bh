SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CMBWRH](
  @wrh int
) with encryption as
begin
  declare @return_status int, @gdgid int, @store int
  if (select CHKVD from WAREHOUSE where GID = @wrh) = 1 begin
    raiserror('该仓位启用到效期管理,不能合并.', 16, 1)
    return(1)
  end

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  declare c_good cursor for
  select distinct GDGID from INV where WRH = @wrh and STORE = @store
  open c_good
  fetch next from c_good into @gdgid
  while @@fetch_status = 0 begin
    execute @return_status = CMB @store, @wrh, @gdgid
    if @return_status <> 0 break
    fetch next from c_good into @gdgid
  end
  close c_good
  deallocate c_good
  return(@return_status)
end
GO
