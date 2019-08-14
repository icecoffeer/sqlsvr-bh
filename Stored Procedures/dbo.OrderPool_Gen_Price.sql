SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Gen_Price](
  @piGdGid int,
  @piVdrGid int,
  @piPoolPrice decimal(24,4), --商品在定货池里的价格
  @poOrdPrice decimal(24,4) output, --最终记录在定单上的价格
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vPrice decimal(24,4),
    @vDefPrc decimal(24,4)

  --默认价格
  exec GetGoodsOrderPrc @piGdGid, @piVdrGid, @vDefPrc output

  --指定价、默认价的较小值
  set @vPrice = @piPoolPrice
  if @vPrice is null or @vDefPrc <= @vPrice
    set @vPrice = @vDefPrc

  set @poOrdPrice = @vPrice
  return 0
end
GO
