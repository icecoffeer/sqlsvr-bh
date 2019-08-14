SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcProcdrptRange]
  @store int,
  @settleno int,
  @fromdate datetime,
  @todate datetime
as begin
  declare @date datetime, @msg varchar(100)
  select @date = @fromdate
  while @date <= @todate
  begin
    select convert(char, getdate(), 13), convert(char, @date, 102)
    exec RecalcProcdrpt @store, @settleno, @date
    select @date = dateadd(day, 1, @date)
  end
end
GO