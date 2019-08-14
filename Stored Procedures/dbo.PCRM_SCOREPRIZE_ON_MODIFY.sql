SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREPRIZE_ON_MODIFY]
(
  @piNum varchar(14),
  @piToStat int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vOper varchar(50)

  select @vStat = STAT from CRMSCOREPRIZE where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '积分兑奖单不存在'
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
    if @vStat not in (0, 100)
    begin
      set @poErrMsg = '不是未审核单据，不能审核'
      return(1)
    end
  end else if @piToStat = 300
  begin
    if @vStat not in (0, 100, 300)
    begin
      set @poErrMsg = '不是未审核或已审核单据，不能审核';
      return(1)
    end
  end else
  begin
    set @poErrMsg = '不能识别的目标状态: ' + rtrim(convert(varchar, @piToStat))
    return(1)
  end

  --状态调度
  if (@piToStat in (100, 300)) and (@vStat = 0)
  begin
    exec @vRet = PCRM_SCOREPRIZE_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    if (@vRet <> 0) or (@piToStat = 100)
      return(@vRet)
  end
  if (@piToStat = 300) and (@vStat in (0, 100))
  begin
    exec @vRet = PCRM_SCOREPRIZE_STAT_TO_300 @piNum, @piOperGid, @poErrMsg output
    return(@vRet)
  end

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CRMSCOREPRIZE set 
    MODIFIER = @vOper, 
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_SCOREPRIZE_ADD_LOG @piNum, @vStat, @piToStat, @piOperGid

  return(0)
end
GO
