SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCEXEC_ON_ADDNEW]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  update ProcExec set MODIFIER = @piOper, LSTUPDTIME = getdate()
  where NUM = @piNum
  exec PROCEXEC_ADD_LOG @piNum, 0, 0, @piOper, ''
  return(0)
end
GO
