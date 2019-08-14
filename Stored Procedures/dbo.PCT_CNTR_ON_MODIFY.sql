SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_ON_MODIFY]
(
  @piNum		char(14),
  @piVersion	int,
  @piToStat	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vRet int
  declare @vStat int
  declare @vVersion int
  
  --数据检查
  exec PCT_CNTR_CURRENT_VERSION @piNum, @vVersion output
  if (@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史版本的合约.'
    return(1)
  end
  select @vStat = STAT from CTCNTR(nolock) 
    where NUM = @piNum and VERSION = @piVersion
  if (@vStat is null)
  begin
    set @poErrMsg = '取合约状态失败.'
    return(1)
  end
  if (@piToStat = 1700) and @vStat not in (0, 1700)
  begin
    set @poErrMsg = '不是未审核合约，不能预审.'
    return(1)
  end
  if (@piToStat = 1710) and @vStat not in (1700)
  begin
    set @poErrMsg = '不是已预审合约，不能作废.';
    return(1)
  end
  if (@piToStat = 500) and @vStat not in (0, 1700, 834)
  begin
    set @poErrMsg = '不是未审核或已预审合约，不能审核.'
    return(1)
  end
  if (@piToStat = 510) and @vStat not in (500)
  begin
    set @poErrMsg = '不是已预审合约，不能作废.'
    return(1)
  end
  if (@piToStat = 1400) and @vStat not in (500)
  begin
    set @poErrMsg = '不是已审核合约，不能终止.'
    return(1)
  end
  if (@piToStat = 1500) and @vStat not in (1400)
  begin
    set @poErrMsg = '不是已终止合约，不能结束.'
    return(1)
  end

  --状态调度
  if (@piToStat = 1700) and (@vStat = 0)
  begin
    exec @vRet = PCT_CNTR_STAT_TO_1700 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet);
  end;
  if (@piToStat = 1710) and (@vStat = 1700)
  begin
    exec @vRet = PCT_CNTR_STAT_TO_1710 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet)
  end
  if (@piToStat = 500) and (@vStat in (0, 1700, 834))
  begin
    exec @vRet = PCT_CNTR_STAT_TO_500 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet)
  end
  if (@piToStat = 510) and (@vStat = 500)
  begin
    exec @vRet = PCT_CNTR_STAT_TO_510 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet)
  end
  if (@piToStat = 1400) and (@vStat = 500) 
  begin
    exec @vRet = PCT_CNTR_STAT_TO_1400 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet)
  end
  if (@piToStat = 1500) and (@vStat = 1400) 
  begin
    exec @vRet = PCT_CNTR_STAT_TO_1500 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet)
  end

  exec @vRet = PCT_CNTR_INTERNAL_MODIFY @piNum, @piVersion, @piOperGid, @poErrMsg output
  if (@vRet <> 0) return(@vRet)
  exec PCT_CNTR_ADDLOG @piNum, @piVersion, @piOperGid, @vStat, @piToStat, ''

  return(0)
end
GO
