SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcInvCostRange]
  @store int,
  @settleno int,
  @fromdate datetime,
  @todate datetime,
  @mode int
as begin
  declare @date datetime, @msg varchar(100)
  select @date = @fromdate
  while @date <= @todate
  begin
    select convert(char, getdate(), 13), convert(char, @date, 102)
    exec RecalcInvCost @store, @settleno, @date,@mode
    insert into rgdwrh(gdgid,wrh,qty,invprc,invcost, fildate)
    select gdgid,wrh,qty,invprc,isnull(invcost,0),dateadd(day, 1, @date) from rgdwrh where fildate = @date
    select @date = dateadd(day, 1, @date)
  end
end

GO
