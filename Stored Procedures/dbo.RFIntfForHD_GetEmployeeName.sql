SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetEmployeeName](
  @piEmpCode varchar(10),
  @poEmpName varchar(20) output,
  @poErrMsg varchar(255) output
)
as
begin
  select @poEmpName = rtrim(NAME) from EMPLOYEE(nolock)
    where CODE = @piEmpCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '员工代码 ' + rtrim(isnull(@piEmpCode, 'null')) + ' 在数据库中不存在。'
    return 1
  end
  return 0
end
GO
