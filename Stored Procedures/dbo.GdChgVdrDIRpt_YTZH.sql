SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdChgVdrDIRpt_YTZH]
  @store int,
  @settleno int,
  @gdgid int,
  @oldvdrgid int,
  @vdrgid int
as
begin
  declare @msg varchar(255)
  if (select SALE from GOODS(nolock) where GID = @gdgid) <> 3
  begin
    set @msg = '商品不是联销商品，不能更改供应商'
    raiserror(@msg, 16, 1)
    return(1)
  end

  return(0)
end
GO
