SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_VDRPAYRTN_ON_MODIFY] (
  @piNum varchar(14),                     --单号
  @piToStat integer,                      --修改后状态
  @piOperGid integer,                     --操作人
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vRet integer
  declare @vStat integer
  declare @vVdrPayStat integer
  declare @vVdrPayNum varchar(14)

  --数据检查
  select @vStat = STAT, @vVdrPayNum = VDRPAYNUM from CTVDRPAYRTN where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '取交款退款单状态失败.'
    return(1)
  end

  if @piToStat = 100 and @vStat not in (0, 100)
  begin
    set @poErrMsg = '不是未审核交款退款单，不能审核.'
    return(1)
  end
  if @piToStat = 900 and @vStat not in (0, 100)
  begin
    set @poErrMsg = '不是未审核或已审核交款退款单，不能付款.'
    return(1)
  end

  select @vVdrPayStat = STAT from VDRPAY where NUM = @vVdrPayNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到交款单 ' + @vVdrPayNum
    return(1)
  end
  if @vVdrPayStat <> 500
  begin
    set @poErrMsg = '交款单 ' + @vVdrPayNum + ' 不是已付款状态，不能退款'
    return(1)
  end

  --状态调度
  if @piToStat in (100, 900) and @vStat = 0
  begin
    exec @vRet = PCT_VDRPAYRTN_STAT_TO_100 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end
  if @piToStat = 900 and @vStat in (0, 100)
  begin
    exec @vRet = PCT_VDRPAYRTN_STAT_TO_900 @piNum, @piOperGid, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end
  exec PCT_VDRPAYRTN_ADDLOG @piNum, @vStat, @piToStat, @piOperGid

  return(0)
end
GO
