SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_GenBill_OrdApply](
  @piGoodsCond varchar(1000),
  @piOperGid int,
  @piCaller varchar(255), --调用方信息
  @poErrMsg varchar(255) output
)
as
begin
  declare @vRet int

  --生成门店叫货申请单
  exec @vRet = OrderPool_Search_Goods_OrdApply @piGoodsCond, @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPool_Gen_OrdApply @piOperGid,@poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPool_Clear_From_OrdApply @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = OrderPoolH_GetFromTemp_OrdApply @piCaller, @poErrMsg output
  if @vRet <> 0 return(@vRet);

  return(0);
end
GO
