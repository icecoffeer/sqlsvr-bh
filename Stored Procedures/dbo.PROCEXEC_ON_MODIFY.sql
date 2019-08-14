SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_ON_MODIFY] (
  @piNum char(14),                     --单号
  @piOper varchar(30),                 --操作人
  @piToStat int,                       --目标状态
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from ProcExec(nolock) where NUM = @piNum
  if @vStat is null
  begin
    set @poErrMsg = '取加工入库单状态失败.'
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
      set @poErrMsg = '此单据已作废，不能保存.'
      return(1)
    end
    if (@vStat = 834)
    begin
      set @poErrMsg = '此单据已变更，不能保存.'
      return(1)
    end
  end else if @piToStat = 110
  begin
    if (@vStat <> 100)
    begin
      set @poErrMsg = '不是已审核单据，不能作废.'
      return(1)
    end
  end else if @piToStat = 834
  begin
    if (@vStat <> 100)
    begin
      set @poErrMsg = '不是已审核单据，不能变更.'
      return(1)
    end
  end else if @piToStat = 300
  begin
    if (@vStat <> 100)
    begin
      set @poErrMsg = '不是已审核单据，不能完成.'
      return(1)
    end
  end else
  begin
    set @poErrMsg = '未知状态.'
    return(1)
  end

  set @vRet = 1
  --状态调度
  if @vStat <> @piToStat
  begin
    exec @vRet = PROCEXEC_CHECK @piNum, @piOper, '', @piToStat, @poErrMsg output
    return(@vRet)
  end
  update ProcExec set Modifier = @piOper, LstUpdTime = getdate() where Num = @piNum
  exec PROCEXEC_ADD_LOG @piNum, @vStat, @piToStat, @piOper, ''
  return(0)
end
GO
