SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create  procedure [dbo].[PCRM_CARD_GetScore]
(
  @piCardNum varchar(20),        --卡号
  @poScore money,                --积分  
  @poErrMsg varchar(255) output  --出错信息
) as
begin
  select @poScore = Score  from CRMCardScoDtl(noLock)
  where CardNum = @piCardNum
  return(0)   
end
GO
