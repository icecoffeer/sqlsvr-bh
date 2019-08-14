SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_REMOVE]
(
  @piNum	char(14),
  @piVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vVersion int
  declare @vStat int

  --数据检查
  exec PCT_CNTRGROUP_CURRENT_VERSION @piNum, @vVersion output
  if(@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史合约组.';
    return(1);
  end;
  select @vStat = STAT from CNTRGROUP(nolock) where NUM = @piNUM and VERSION = @piVersion;
  if(@vStat <> 0)
  begin
    set @poErrMsg = '合约组' + @piNum + '版本(' + rtrim(convert(varchar, @piVersion)) + ')不是未审核状态，不允许删除.';
    return(1);
  end;

  delete from CNTRGROUP where NUM = @piNum and VERSION = @piVersion;
  return(0);
end
GO
