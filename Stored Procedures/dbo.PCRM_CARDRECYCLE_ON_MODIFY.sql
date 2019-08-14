SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_CARDRECYCLE_ON_MODIFY] (
  @piNum char(14),                     --单号
  @piToStat int,                       --目标状态
  @piOper varchar(30),                 --操作人
  @piOperGid int,                      --操作员Gid
  @poErrMsg varchar(255) output        --出错信息
) as
begin
  declare @vRet int
  declare @vStat int

  select @vStat = STAT from CRMCardRecycle where NUM = @piNum
  if @vStat is null
  begin
    set @poErrMsg = '取发卡回退单状态失败.'
    return(1)
  end

  if @piToStat = 0
  begin
    if @vStat <> 0
    begin
      set @poErrMsg = '不是未审核单据，不能保存.'
      return(1)
    end
  end
  else if @piToStat = 100
  begin
    if @vStat <> 0
    begin
      set @poErrMsg = '不是未审核单据，不能审核.'
      return(1)
    end
  end
  else
  begin
    set @poErrMsg = '不能识别的目标状态: ' + convert(varchar(4), @piToStat)
    return(1)
  end

  --状态调度
  if @piToStat = 100
  begin
    exec @vRet = PCRM_CARDRECYCLE_STAT_TO_100 @piNum, @piOper, @piOperGid, @poErrMsg output
    return(@vRet)
  end

  update CRMCARDRECYCLE set Modifier = @piOper, LstUpdTime = getdate() where Num = @piNum
  exec PCRM_CARDRECYCLE_ADD_LOG @piNum, vStat, piToStat, @piOper
  return(0)
end
GO
