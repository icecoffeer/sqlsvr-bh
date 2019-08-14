SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCT_CNTRGROUP_INTERNAL_MODIFY]
(
  @piNum	char(14),
  @piVersion	int,
  @piOperGid	int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vOper varchar(30)  
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE where GID = @piOperGid
  update CNTRGROUP set 
    TAG = 0 
  where NUM = @piNum and VERSION < @piVersion;
  update CNTRGROUP set 
    LSTUPDOPER = @vOper, 
    LSTUPDTIME = getdate(), 
    TAG = 1 
  where NUM = @piNum and VERSION = @piVersion;
  return(0);
end
GO
