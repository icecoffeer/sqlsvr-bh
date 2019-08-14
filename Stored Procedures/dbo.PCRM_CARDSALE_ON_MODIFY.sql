SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_CARDSALE_ON_MODIFY] (
  @piNum char(14),                     --单号
  @piOperGid int,                      --操作人
  @piToStat int,                       --目标状态
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vOper varchar(30)

  select @vStat = STAT from CRMCARDSALE(nolock) where NUM = @piNum
  if @vStat is null
  begin
    set @poErrMsg = '取发售单状态失败.'
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
    if @vStat = 300
    begin
      set @poErrMsg = '此单据已完成，不能再审核。'
      return(1)
    end
  end else if @piToStat = 300
  begin
    if @vStat = 300
    begin
      set @poErrMsg = '此单据已完成，不能再完成。'
      return(1)
    end
  end else
  begin
    set @poErrMsg = '不能识别的目标状态: ' + rtrim(convert(varchar, @piToStat))
    return(1)
  end

  set @vRet = 1
  --状态调度
  if (@vStat = 0) and (@piToStat = 100)
  begin
    exec @vRet = PCRM_CARDSALE_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    return(@vRet) 
  end else if (@piToStat = 300)
  begin
    exec @vRet = PCRM_CARDSALE_STAT_TO_300 @piNum, @piOperGid, @poErrMsg output 
    return(@vRet)  
  end

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CRMCARDSALE set 
    MODIFIER = @vOper, 
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_CARDSALE_ADD_LOG @piNum, @vStat, @piToStat, @piOperGid

  return(0)
end
GO
