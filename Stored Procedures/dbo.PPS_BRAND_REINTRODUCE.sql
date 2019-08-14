SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[PPS_BRAND_REINTRODUCE]
(
  @Code varchar(10),
  @FromBusinessStat int,
  @ToBusinessStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  if @FromBusinessStat in (0, 1)
  begin
    set @Msg = '不是淘汰品牌，不能重新引入'
    return(1)
  end
  update Brand set BusinessStat = @ToBusinessStat, EliminateTime = null,
    LstUpdOper = @Oper, LstUpdTime = Getdate() where Code = @Code
  if @@RowCount > 0
    return(0)
end
GO
