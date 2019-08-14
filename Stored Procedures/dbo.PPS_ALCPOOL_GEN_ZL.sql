SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_GEN_ZL]
(
  @piGoodsCond varchar(255),
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int

  exec @vRet = PPS_ALCPOOL_SEARCH_ZLGOODS @piGoodsCond, @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOL_APPLY_QTYPOLICY @poErrMsg output
  if @vRet <> 0 return(@vRet);
  --exec @vRet = PPS_ALCPOOL_ZLSTKOUTFIFO @poErrMsg output
  --if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOL_GEN_ZLORD @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOL_GEN_ZLSTKOUT @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOL_UPDATE_BILL @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOL_CLEAR_FROM_ZLORD @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet);
  exec @vRet = PPS_ALCPOOLH_GETFROMTEMP @poErrMsg output
  if @vRet <> 0 return(@vRet);

  return(0);
end
GO
