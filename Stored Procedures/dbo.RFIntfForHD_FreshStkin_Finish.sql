SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_FreshStkin_Finish](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int
  if exists(select * from SYSTEM(nolock) where USERGID = ZBGID)
  begin
    exec @return_status = RFIntfForHD_FreshStkin_GenStkin @piEmpCode, @poErrMsg output
  end
  else begin
    exec @return_status = RFIntfForHD_FreshStkin_GenDirin @piEmpCode, @poErrMsg output
  end
  return @return_status
end
GO
