SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ON_ADDNEW]
(
  @piNum varchar(14),
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as
begin
  exec PS3_REDBLUELIMIT_ADD_LOG @piNum, null, 0, Oper

  return(0)
end
GO
