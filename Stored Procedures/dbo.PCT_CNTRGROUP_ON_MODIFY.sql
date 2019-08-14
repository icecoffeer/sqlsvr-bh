SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_ON_MODIFY]
(
  @piNum	char(14),
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
  exec PCT_CNTRGROUP_CURRENT_VERSION @piNum, @vVersion output
  if(@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史版本的合约组.'
    return(1);
  end;
  select @vStat = STAT from CNTRGROUP(nolock) where NUM = @piNum and VERSION = @piVersion;
  if(@vStat is null)
  begin
    set @poErrMsg = '取合约组状态失败.'
    return(1);
  end;
  if(@piToStat = 100) and @vStat not in (0, 100)
  begin
    set @poErrMsg = '不是未审核合约组，不能审核.';
    return(1);
  end;
  if(@piToStat = 110) and @vStat not in (100, 110)
  begin
    set @poErrMsg = '不是已审核合约组，不能作废.';
    return(1);
  end;

  --状态调度
  if (@piToStat = 100) and (@vStat = 0)
  begin
    exec @vRet = PCT_CNTRGROUP_STAT_TO_100 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet);
  end;
  if (@piToStat = 110) and (@vStat = 100)
  begin
    exec @vRet = PCT_CNTRGROUP_STAT_TO_110 @piNum, @piVersion, @piOperGid, @poErrMsg output
    if(@vRet <> 0) return(@vRet);
  end;

  exec @vRet = PCT_CNTRGROUP_INTERNAL_MODIFY @piNum, @piVersion, @piOperGid, @poErrMsg output
  if(@vRet <> 0) return(@vRet);

  return(0);	
end
GO
