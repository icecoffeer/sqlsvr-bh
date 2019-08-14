SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetDeptName](
  @piDeptCode varchar(10),
  @poDeptName varchar(40) output,
  @poErrMsg varchar(255) output
)
as
begin
  select @poDeptName = rtrim(NAME) from DEPT(nolock)
    where CODE = @piDeptCode

  if @@rowcount = 0
  begin
    set @poErrMsg = '部门代码 ' + rtrim(@piDeptCode) + ' 在数据库中不存在。'
    return 1
  end

  return 0
end
GO
