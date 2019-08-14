SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[COMBINE](
  @wrh int,
  @gdgid int
) with encryption as
begin
  declare @return_status int, @store int
  select @return_status = 0
  if @wrh is null begin
    execute @return_status = CMBGD @gdgid
  end else if @gdgid is null begin
    execute @return_status = CMBWRH @wrh
  end else begin
    if (select CHKVD from WAREHOUSE where GID = @wrh) = 1 and
      (select CHKVD from GOODS where GID = @gdgid) = 1 begin
      raiserror('该仓位中该商品启用到效期管理,不能合并.', 16, 1)
      return (1)
    end

    /* 如果这个仓位是一个门店 */
    select @store = null
    select @store = GID from STORE where GID = @wrh
    if @store is null select @store = USERGID from SYSTEM
    else select @wrh = 1

    execute @return_status = CMB @store, @wrh, @gdgid
  end
  return(@return_status)
end
GO
