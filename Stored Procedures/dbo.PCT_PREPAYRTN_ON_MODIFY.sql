SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_PREPAYRTN_ON_MODIFY] (
  @piNum varchar(14),                     --单号
  @piToStat integer,                      --修改后状态
  @piOperGid integer,                     --操作人
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vRet integer
  declare @vStat integer
  declare @vPrePayStat integer
  declare @vPrePayNum varchar(14)

  --数据检查
  select @vStat = STAT, @vPrePayNum = PREPAYNUM from CTPREPAYRTN where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '取预付款还款单状态失败.'
    return(1)
  end

  if @piToStat = 100 and @vStat not in (0, 100)
  begin
    set @poErrMsg = '不是未审核预付款还款单，不能审核.'
    return(1)
  end
  if @piToStat = 900 and @vStat not in (0, 100)
  begin
    set @poErrMsg = '不是未审核或已审核预付款还款单，不能付款.'
    return(1)
  end

  select @vPrePayStat = STAT from CNTRPREPAY where NUM = @vPrePayNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到预付款单 ' + @vPrePayNum
    return(1)
  end
  if @vPrePayStat <> 900
  begin
    set @poErrMsg = '预付款单 ' + @vPrePayNum + ' 不是已付款状态，不能还款'
    return(1)
  end

  --状态调度
  if @piToStat in (100, 900) and @vStat = 0
  begin
    exec @vRet = PCT_PREPAYRTN_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end
  if @piToStat = 900 and @vStat in (0, 100)
  begin
    exec @vRet = PCT_PREPAYRTN_STAT_TO_900 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end
  exec PCT_PREPAYRTN_ADDLOG @piNum, @vStat, @piToStat, @piOperGid

  return(0)
end
GO
