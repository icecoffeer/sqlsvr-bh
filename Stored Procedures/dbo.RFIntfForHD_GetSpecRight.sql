SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_GetSpecRight]
(
  @piEmpGid int,                 --用户内码
  @piSpecRightNo int,            --权限编号
  @piSpecRightNo2 char(32),      --权限编号2
  @poRight char(1) output        --用户权限 按位表示 0-有权限 1-没有权限。
)
as
begin
  declare
    @vRight int
  set @vRight = 1
  select @vRight = RIGHTLEVEL
    from EMPSPECRIGHT(nolock)
    where EMPID = @piEmpGid
      and SPECRIGHTNO = @piSpecRightNo
      and SPECRIGHTNO2 = @piSpecRightNo2
  if @vRight = 0
  begin
    set @poRight = '0'
    return 0
  end

  set @vRight = 1
  select @vRight = min(EMPGROUPSPECRIGHT.RIGHTLEVEL)
    from EMPGROUPSPECRIGHT(nolock), EMPLOYEERIGHT(nolock)
    where EMPGROUPSPECRIGHT.EMPGROUPID = EMPLOYEERIGHT.EMPLOYEEGROUP
      and EMPLOYEERIGHT.EMPLOYEE = @piEmpGid
      and EMPGROUPSPECRIGHT.SPECRIGHTNO = @piSpecRightNo
      and EMPGROUPSPECRIGHT.SPECRIGHTNO2 = @piSpecRightNo2
  if @vRight = 0
  begin
    set @poRight = '0'
    return 0
  end

  set @poRight = '1'
  return 0
end
GO
