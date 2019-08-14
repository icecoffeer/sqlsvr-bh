SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_REMOVE]
(
  @piNum varchar(14),
  @piOper varchar(14),
  @poErrMsg varchar(255) output
) as
begin
  declare
    @vStat int

  select @vStat = Stat from ProcTask(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '加工任务单(' + @piNum + ')不是未审核状态，不允许删除!'
    return(1)
  end

  delete from ProcTask where NUM = @piNum
  delete from ProcTaskRaw where NUM = @piNum
  delete from ProcTaskProd where NUM = @piNum
  delete from ProcTaskLOG where NUM = @piNum

  return(0)
end
GO
