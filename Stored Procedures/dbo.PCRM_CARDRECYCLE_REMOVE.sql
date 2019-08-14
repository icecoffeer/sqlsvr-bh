SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_CARDRECYCLE_REMOVE] (
  @piNum char(14),                     --单号
  @piOPER varchar(30),                 --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare 
    @vStat int

  select @vStat = STAT from CRMCardRecycle(nolock) where NUM = @piNUM
  
  if @@rowcount = 0 
  begin
    set @poErrMsg = '找不到发卡回退单' + @piNum
    return(1)
  end
    
  if @vStat <> 0
  begin
    set @poErrMsg = '发卡回退单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end

  delete from CRMCardRecycle where NUM = @piNum
  delete from CRMCardRecycleDtl where NUM = @piNum
  delete from CRMCardRecycleLog where NUM = @piNum

  return(0)
end
GO
