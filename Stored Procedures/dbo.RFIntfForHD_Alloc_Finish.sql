SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_Finish](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @return_status int
  exec @return_status = RFIntfForHD_Alloc_GenStkOut @piEmpCode, @poErrMsg output
  return @return_status
end
GO
