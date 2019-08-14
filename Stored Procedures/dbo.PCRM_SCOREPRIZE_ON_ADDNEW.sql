SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREPRIZE_ON_ADDNEW]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOper varchar(50)

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid
  update CRMSCOREPRIZE set 
    MODIFIER = @vOper,
    LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PCRM_SCOREPRIZE_ADD_LOG @piNum, null, 0, @piOperGid

  return(0)
end
GO
