SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTASK_ON_ADDNEW]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  update ProcTask set Modifier = @piOper, LstUpdTime = getdate() where Num = @piNum
  exec PROCTASK_ADD_LOG @piNum, 0, 0, @piOper
  return(0)
end
GO
