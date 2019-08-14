SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IncDspQty]
  @wrh int,
  @gdgid int,
  @qty money,
  /* 2000-3-3 */
  @subwrh int = null
as
begin
  declare @num int, @store int

  /* 如果这个仓位是一个门店 */
  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  select @num = min(NUM) from INV
  where WRH = @wrh and GDGID = @gdgid and STORE = @store

  --2003-05-15 Ysp DSPQTY不允许为负
  if @num is null and @qty < 0
  begin
	raiserror('待提数不允许修改为负值', 16, 1)
	return 1
  end
  else if @num is not null and (select isnull(DSPQTY,0) + @qty from inv where NUM= @num) < 0
  begin
	raiserror('待提数不允许修改为负值', 16, 1)
	return 1
  end

  if @num is null
  begin
    insert into INV (STORE, WRH, GDGID, DSPQTY) values (@store, @wrh, @gdgid, @qty)
  end
  else
  begin
    update INV set DSPQTY = DSPQTY + @qty where NUM = @num
  end
/*2003-01-22hxs修改考虑不同仓位中同一批次情况*/
  /* 00-3-3 */
/*  if @subwrh is not null
  begin
    if not exists (select * from SUBWRHINV where GDGID = @gdgid and SUBWRH = @subwrh)
    begin
      raiserror('没有相应的货位库存记录', 16, 1)
      return 901
    end else
    begin
      update SUBWRHINV set DSPQTY = DSPQTY + @qty where GDGID = @gdgid and SUBWRH = @subwrh
    end
  end
*/
  if @subwrh is not null
  begin
    if not exists (select * from SUBWRHINV where GDGID = @gdgid and SUBWRH = @subwrh and wrh = @wrh)
    begin
      raiserror('没有相应的货位库存记录', 16, 1)
      return 901
    end else
    begin
      update SUBWRHINV set DSPQTY = DSPQTY + @qty where GDGID = @gdgid and SUBWRH = @subwrh and wrh = @wrh
    end
  end
/*2003-01-22hxs修改考虑不同仓位中同一批次情况 end here*/
  return 0
end
GO
