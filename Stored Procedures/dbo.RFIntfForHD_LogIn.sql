SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_LogIn](
  @piEmpCode varchar(10),           --传入参数：用户代码。
  @piPassword varchar(32),          --传入参数：用户密码（密文形式）。
  @piPDAMac varchar(40),            --传入参数：手持设备的MAC地址。
  @piPDANum varchar(40),            --传入参数：手持设备的机器号。
  @poModuleRight varchar(1) output, --传出参数（返回值为0时有效）：用户RF虚拟模块权限，0-有权限 1-没有权限。
  @poEmpName varchar(20) output,    --传出参数（返回值为0时有效）：用户名称。
  @poUserGid int output,            --传出参数（返回值为0时有效）：本店GID。
  @poZBGid int output,              --传出参数（返回值为0时有效）：总部GID。
  @poErrMsg varchar(255) output     --传出参数（返回值不为0时有效）：错误信息。
)
as
begin
  declare
    @return_status int

  --登记设备。
  exec @return_status = RFIntfForHD_RegisterDevice @piPDAMac, @piPDANum, @poErrMsg output
  if @return_status <> 0
    return 1

  --校验用户代码、口令。
  exec @return_status = chkUser @piEmpCode, @piPassword, @poModuleRight output, @poEmpName output, @poErrMsg output
  if @return_status <> 0
    return 1

  --读取用户权限及系统选项。
  exec @return_status = RFIntfForHD_GetOptionsAndRights @piEmpCode, @poUserGid output, @poZBGid output, @poErrMsg output
  if @return_status <> 0
    return 1

  return 0
end
GO
