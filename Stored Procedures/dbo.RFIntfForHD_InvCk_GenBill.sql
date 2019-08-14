SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_InvCk_GenBill](
  @piEmpCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int

  exec @return_status = RFIntfForHD_InvCk_GenPck @piEmpCode, @poErrMsg output
  if @return_status is null or @return_status <> 0 return 1

  exec @return_status = RFIntfForHD_InvCk_UpdBill @poErrMsg output
  if @return_status is null or @return_status <> 0 return 1

  exec @return_status = RFIntfForHD_InvCk_Clear_RFPCk @piEmpCode, @poErrMsg output
  if @return_status is null or @return_status <> 0 return 1

  return 0
end
GO
