SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ON_MODIFY]
(
  @piNum varchar(14),
  @piToStat int,
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vOper varchar(30)

  select @vStat = STAT from PS3REDBLUECARD(nolock) where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '红蓝卡限制单不存在!'
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
    if (@vStat = 100)
    begin
      set @poErrMsg = '不是未审核单据，不能审核.'
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
    exec @vRet = PS3_REDBLUELIMIT_STAT_TO_100 @piNum, @piOper, @poErrMsg output
    return(@vRet)
  end
  
  
  exec PS3_REDBLUELIMIT_ADD_LOG @piNum, @vStat, @piToStat, @piOper
  return(0)
end
GO
