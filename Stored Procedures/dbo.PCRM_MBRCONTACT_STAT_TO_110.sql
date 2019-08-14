SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MBRCONTACT_STAT_TO_110]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOper varchar(50)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid

  update CRMMBRCONTACT set 
    STAT = 110, 
    LSTUPDTIME = getdate() 
  where NUM = @piNum

  return(0)
end
GO
