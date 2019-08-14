SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_INTERNAL_MODIFY]
(
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg	varchar(255)	output
) as
begin
  declare @vOper varchar(50)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) 
  where GID = @piOperGid
  update CTCNTR set  
    TAG = 0,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum and VERSION < @piVersion
    and TAG <> 0
  update CTCNTR set 
    TAG = 1 ,
    MODIFIER = @vOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum and VERSION = @piVersion
  return(0)
end
GO
