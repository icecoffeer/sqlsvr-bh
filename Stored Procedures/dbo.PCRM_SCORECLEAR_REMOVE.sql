SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCORECLEAR_REMOVE] (
  @piNum char(14),                     --单号
  @piOperGid int,                      --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vStat int

  select @vStat = STAT from CRMSCORECLEAR(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '积分作废单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end
  
  delete from CRMSCORECLEAR where NUM = @piNum
  delete from CRMSCORECLEARSCOREDTL where NUM = @piNum
  delete from CRMSCORECLEARSORTDTL where NUM = @piNum
  delete from CRMSCORECLEARLOG where NUM = @piNum
  return(0)
end
GO
