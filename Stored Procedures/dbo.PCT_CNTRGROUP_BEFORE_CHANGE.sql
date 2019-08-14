SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_BEFORE_CHANGE]
(
  @piNum	char(14),
  @piVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vStat int
  select @vStat = STAT from CNTRGROUP(nolock) where NUM = @piNUM and VERSION = @piVersion;
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到合约组' + @piNum;
    return(1);
  end;
  if(@vStat <> 100)
  begin
    set @poErrMsg = '不是已审核合约组，不能变更';
    return(1);
  end;
  return(0);
end
GO
