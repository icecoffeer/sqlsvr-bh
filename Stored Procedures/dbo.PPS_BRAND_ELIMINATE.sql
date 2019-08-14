SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[PPS_BRAND_ELIMINATE]
(
  @Code varchar(10),
  @FromBusinessStat int,
  @ToBusinessStat int,
  @Oper varchar(30),
  @Msg varchar(255) output
) as
begin
  if @FromBusinessStat = 2
  begin
    set @Msg = '已经是淘汰品牌，不能淘汰'
    return(1)
  end
  if (select Count(Gid) from Goods(nolock) where Brand = @Code) > 0
  begin
    set @Msg = '还存在品牌为 ' + @Code + ' 的商品，不能淘汰，请检查'
    return(1)
  end
  update Brand set BusinessStat = @ToBusinessStat, EliminateTime = Getdate(),
    LstUpdOper = @Oper, LstUpdTime = Getdate() where Code = @Code
  if @@RowCount > 0
    return(0)
end
GO
