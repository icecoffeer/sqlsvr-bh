SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTRANSFER_ON_MODIFY] (
  @piNum varchar(14),                  --单号
  @piOper varchar(80),                 --操作人
  @piToStat int,                       --目标状态
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = Stat from ProcTransfer(nolock) where Num = @piNum
  if @vStat is null
  begin
    set @poErrMsg = '取加工领料单状态失败.'
    return(1)
  end
  if @piToStat = 0
  begin
    if @vStat <> 0
    begin
      set @poErrMsg = '单据已经被其他人处理，不能保存'
      return(1)
    end
  end else if @piToStat = 100
  begin
    if (@vStat = 110)
    begin
      set @poErrMsg = '单据已作废，不能审核单据.'
      return(1)
    end
  end else if @piToStat = 110
  begin
    if (@vStat = 110)
    begin
      set @poErrMsg = '单据已作废，不能保存.'
      return(1)
    end
  end else
  begin
    set @poErrMsg = '不能识别的目标状态: ' + rtrim(convert(varchar, @piToStat))
    return(1)
  end

  --状态调度
  if (@vStat = 0) and (@piToStat = 100)
  begin
    exec @vRet = PROCTRANSFER_STAT_TO_100 @piNum, @piOper, @poErrMsg output
    return(@vRet)
  end

  if (@vStat = 100) and (@piToStat = 110)
  begin
    exec @vRet = PROCTRANSFER_STAT_TO_110 @piNum, @piOper, @poErrMsg output
    return(@vRet)
  end

  update ProcTransfer set MODIFIER = @piOper, LSTUPDTIME = getdate() where NUM = @piNum
  exec PROCTRANSFER_ADD_LOG @piNum, @vStat, @piToStat, @piOper
  return(0)
end
GO
