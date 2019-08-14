SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_REMOVE]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  declare
    @vStat int

  select @vStat = STAT from ProcExec(nolock) where NUM = @piNUM
  if @vStat <> 0
  begin
    set @poErrMsg = '加工入库单(' + @piNum + ')不是未审核状态，不允许删除!'
    return(1)
  end

  delete from ProcExec where NUM = @piNum
  delete from ProcExecRaw where NUM = @piNum
  delete from ProcExecProd where NUM = @piNum
  delete from ProcExecLOG where NUM = @piNum

  return(0)
end
GO
