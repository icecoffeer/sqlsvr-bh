SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DecDspQty]
  @wrh int,
  @gdgid int,
  @qty money,
  /* 2000-3-3 */
  @subwrh int = null
as
begin
  declare @ret int
  select @qty = -@qty
  execute @ret = IncDspQty @wrh, @gdgid, @qty, /*00-3-3*/ @subwrh
  if @ret <> 0		--2003-05-30
  begin
	raiserror('减少仓位待提数错误', 16, 1)
	return 1
  end
  return 0
end
GO
