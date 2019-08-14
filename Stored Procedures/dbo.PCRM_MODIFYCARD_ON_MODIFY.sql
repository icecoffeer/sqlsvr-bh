SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MODIFYCARD_ON_MODIFY] (
  @piNum char(14),                     --单号
  @piOper varchar(70),                 --操作人
  @piToStat int,                       --目标状态
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from CRMMODIFYCARD(nolock) where NUM = @piNum
  if @vStat is null
  begin
    set @poErrMsg = '取卡修正单状态失败.'
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
    if (@vStat <> 0)
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
    exec @vRet = PCRM_MODIFYCARD_STAT_TO_100 @piNum, @piOper, @poErrMsg output
    return(@vRet)
  end

  update CRMMODIFYCARD set 
    MODIFIER = @piOper, 
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_MODIFYCARD_ADD_LOG @piNum, @vStat, @piToStat, @piOper

  return(0)
end
GO
