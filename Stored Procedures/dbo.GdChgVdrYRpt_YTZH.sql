SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  将INXRPT中@store, @settleno, @wrh, @gdgid的供应商从@oldvdrgid改成@vdrgid
*/
create procedure [dbo].[GdChgVdrYRpt_YTZH]
  @store int,
  @settleno int,
  @gdgid int,
  @oldvdrgid int,
  @vdrgid int,
  @mode int
  --@mode = 0 /*修改全部数据, 修改期初值和发生值*/
  --@mode = 1 /*修改全部数据, 修改发生值*/
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
