SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[chkUser]
(
  @piEmpCode varchar(10),           --传入参数：员工代码。
  @piPassword varchar(32),          --传入参数：员工密码（密文形式）。
  @poModuleRight varchar(1) output, --传出参数（返回值为0时有效）：员工RF虚拟模块权限，0-有权限，1-没有权限。
  @poEmpName varchar(20) output,    --传出参数（返回值为0时有效）：员工名称。
  @poErrMsg varchar(255) output     --传出参数（返回值不为0时有效）：错误消息。
) as
begin
  declare
    @EmpGid int,
    @EmpPassword varchar(32),
    @PwdLeft30 varchar(30),
    @EmpPwdLeft30 varchar(30)

  --读取员工信息。
  select @EmpGid = GID, @EmpPassword = [PASSWORD], @poEmpName = rtrim(NAME)
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '代码为' + rtrim(isnull(@piEmpCode, 'null')) + '的员工资料不存在。'
    return(1)
  end

  --校验员工密码。密码字段的长度是32，实际长度是30。
  set @PwdLeft30 = left(isnull(@piPassword, ''), 30)
  set @EmpPwdLeft30 = left(isnull(@EmpPassword, ''), 30)
  if convert(varbinary, @PwdLeft30) <> convert(varbinary, @EmpPwdLeft30)
  begin
    set @poErrMsg = '密码错误。'
    return(1)
  end

  --获取员工RF虚拟模块权限（1位，0-有权限，1-无权限）。
  exec RFIntfForHD_GetModuleRight @EmpGid, 8146, @poModuleRight output

  return(0)
end
GO
