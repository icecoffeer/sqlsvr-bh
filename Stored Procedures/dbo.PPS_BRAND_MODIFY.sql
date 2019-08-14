SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[PPS_BRAND_MODIFY]
(
  @Code varchar(10),
  @FromBusinessStat int,
  @ToBusinessStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  declare
    @ret int
  if @ToBusinessStat = 2
  begin
    exec @ret = PPS_BRAND_ELIMINATE @Code, @FromBusinessStat, @ToBusinessStat, @Oper, @Msg output
    return @ret
  end
  else if @ToBusinessStat = 3
  begin
    exec @ret = PPS_BRAND_REINTRODUCE @Code, @FromBusinessStat, @ToBusinessStat, @Oper, @Msg output
    return @ret
  end
  else begin
    update Brand set BusinessStat = @ToBusinessStat,
      LstUpdOper = @Oper, LstUpdTime = Getdate()
    where Code = @Code
    if @@RowCount > 0
      return(0)
  end
end
GO
