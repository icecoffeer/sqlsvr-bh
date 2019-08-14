SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PCRM_MBRCONTACT_STAT_TO_100]
(
  @piNum varchar(14),
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  declare @vAStart datetime
  declare @vAFinish datetime
  declare @vCount int
  declare @vSettleNo int
  declare @vOper varchar(50)
  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']' from EMPLOYEE(nolock) where GID = @piOperGid

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  update CRMMBRCONTACT set 
    STAT = 100, 
    SETTLENO = @vSettleNo, 
    LSTUPDTIME = getdate() 
  where NUM = @piNum

  return(0)
end
GO
