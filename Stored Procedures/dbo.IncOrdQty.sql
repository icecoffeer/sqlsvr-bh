SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IncOrdQty]
  @wrh int,
  @gdgid int,
  @qty money
--with encryption 
as
begin
  declare
    @num int, @store int

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  select @num = min(NUM) from INV
  where WRH = @wrh and GDGID = @gdgid and STORE = @store
  if @num is null
  begin
    if @qty > 0 insert into INV (STORE, WRH, GDGID, ORDQTY)
    values (@store, @wrh, @gdgid, @qty)
  end
  else
  begin
    select @qty = ORDQTY + @qty from INV where NUM = @num
    if @qty < 0 select @qty = 0
    update INV set ORDQTY = @qty where NUM = @num
  end
end

GO
