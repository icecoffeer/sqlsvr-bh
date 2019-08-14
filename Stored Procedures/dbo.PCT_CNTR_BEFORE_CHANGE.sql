SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_BEFORE_CHANGE]
(
  @piNum	char(14),
  @piVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vStat int
  declare @vVersion int

  select @vStat = STAT from CTCNTR(nolock) where NUM = @piNUM and VERSION = @piVersion;
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到合约' + @piNum;
    return(1);
  end;
  exec PCT_CNTR_CURRENT_VERSION @piNum, @vVersion output
  if(@vVersion <> @piVersion)
  begin
    set @poErrMsg = '不能处理历史合约.';
    return(1);
  end;
  if(@vStat <> 500)
  begin
    set @poErrMsg = '不是已审核合约，不能变更'
    return(1);
  end;
  return(0)
end
GO
