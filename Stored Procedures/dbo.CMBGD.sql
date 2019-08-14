SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CMBGD](
  @gdgid int
) with encryption as
begin
  declare @return_status int, @wrh int, @store int
  if (select CHKVD from GOODS where GID = @gdgid) = 1 begin
    raiserror('该商品启用到效期管理,不能合并.', 16, 1)
    return(1)
  end
  declare c_wrh cursor for
  select distinct STORE, WRH from INV where GDGID = @gdgid
  open c_wrh
  fetch next from c_wrh into @store, @wrh
  while @@fetch_status = 0 begin
    execute @return_status = CMB @store, @wrh, @gdgid
    if @return_status <> 0 break
    fetch next from c_wrh into @store, @wrh
  end
  close c_wrh
  deallocate c_wrh
  return(@return_status)
end
GO
