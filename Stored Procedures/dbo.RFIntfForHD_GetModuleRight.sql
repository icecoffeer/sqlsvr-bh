SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetModuleRight]
(
  @piEmpGid int,                 --用户内码
  @piModuleNo int,               --模块号
  @poRight char(1) output        --用户权限 按位表示 0-有权限 1-没有权限。
)
as
begin
  declare
    @vRight char(1)
  set @vRight = ''
  select @vRight = substring(LOCALRIGHT, @piModuleNo, 1)
    from EMPLOYEE(nolock)
    where GID = @piEmpGid
  if @vRight = 1
  begin
    set @poRight = '0'
    return 0
  end

  set @vRight = ''
  select @vRight = max(substring(eg.[RIGHT], @piModuleNo, 1))
    from EMPLOYEEGROUP eg(nolock), EMPLOYEERIGHT er(nolock)
    where eg.GID = er.EMPLOYEEGROUP
      and er.EMPLOYEE = @piEmpGid
  if @vRight = 1
  begin
    set @poRight = '0'
    return 0
  end

  set @poRight = '1'
  return 0
end
GO
