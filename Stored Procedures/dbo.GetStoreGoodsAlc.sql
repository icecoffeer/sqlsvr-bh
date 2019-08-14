SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetStoreGoodsAlc] (
  @storegid int,
  @gdgid int,
  @alc char(10) output
)
as
begin
  declare @option int
  exec OptReadInt 0, 'StoreGdAlcStrategy', 0, @option output
  if @option = 0
    select @alc = alc from goods(nolock) where gid = @gdgid
  else
  begin
    select @alc = alc from gdstore(nolock) where storegid = @storegid and gdgid = @gdgid
    if @alc is null
      select @alc = alc from goods(nolock) where gid = @gdgid
  end
  return 0;
end
GO
