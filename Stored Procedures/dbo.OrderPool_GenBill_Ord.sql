SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_GenBill_Ord](
  @piGoodsCond varchar(1000),
  @piOperGid int,
  @piCaller varchar(255), --调用方信息
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int

  --生成定货单
  exec @vRet = OrderPool_Search_Goods @piGoodsCond, @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPool_Gen_Ord @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPool_Update_Bill @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPool_Clear_From_Ord @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPoolH_GetFromTemp @piCaller, @poErrMsg output
  if @vRet <> 0 return(@vRet);

  return(0);
end
GO
