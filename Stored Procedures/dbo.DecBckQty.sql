SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DecBckQty]
  @wrh int,
  @gdgid int,
  @qty money,
  /*00-3-3*/
  @subwrh int = null
as
begin
  select @qty = -@qty
  execute IncBckQty @wrh, @gdgid, @qty, /*00-3-3*/@subwrh
end
GO
