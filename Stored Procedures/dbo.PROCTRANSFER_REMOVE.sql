SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTRANSFER_REMOVE] (
  @piNum varchar(14),                  --单号
  @piOper varchar(80),                 --操作人
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vStat int

  select @vStat = Stat from ProcTransfer(nolock) where NUM = @piNum
  if @vStat <> 0
  begin
    set @poErrMsg = '加工领料单' + @piNum + '不是未审核状态，不允许删除.'
    return(1)
  end

  delete from ProcTransfer where NUM = @piNum
  delete from ProcTransferDtl where NUM = @piNum
  delete from ProcTransferLog where NUM = @piNum
  return(0)
end
GO
