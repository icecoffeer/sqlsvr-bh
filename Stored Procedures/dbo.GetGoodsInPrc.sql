SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsInPrc]
(
 @gdgid  int,
 @wrh    int,
 @invprc money   output
)
with encryption as
begin
  select @invprc = invprc from gdwrh(nolock) where gdgid = @gdgid and wrh = @wrh
  if @@rowcount = 0
    select @invprc = inprc from goods where gid = @gdgid
  return (0)
end
GO
