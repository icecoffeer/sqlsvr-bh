SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_SCOREADJ_STAT_TO_300]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOper varchar(50)  
  
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid

  update CRMSCOREADJ set 
    STAT = 300, 
    CHECKER = @vOper,
    CHKDATE = getdate(),    
    MODIFIER = @vOper,
    LSTUPDTIME = getdate() 
  where NUM = @piNum

  exec PCRM_SCOREADJ_ADD_LOG @piNum, 100, 300, @piOperGid

  return(0)
end
GO
