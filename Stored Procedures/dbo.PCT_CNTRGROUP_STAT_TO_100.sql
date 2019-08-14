SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_STAT_TO_100](
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vOper varchar(30)  
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE where GID = @piOperGid
  update CNTRGROUP set STAT = 100, CHECKER = @vOper, CHKDATE = getdate() where NUM = @piNum and VERSION = @piVersion;
  return(0);
end;
GO
