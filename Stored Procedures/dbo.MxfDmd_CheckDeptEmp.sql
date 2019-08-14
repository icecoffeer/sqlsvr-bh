SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[MxfDmd_CheckDeptEmp]
(
  @Num char(14),
  @Oper char(30),
  @ToStat int,
  @Msg varchar(255) output
)
as
begin
  declare
    @Dept char(10),
    @OperCode varchar(10),
    @OperGid int,
    @OptDeptLimit int
  if @ToStat not in (400, 402)
    return 0
  exec OptReadInt 8013, 'DeptLimit', 0, @OptDeptLimit output
  set @OperCode = substring(@Oper, charindex('[', @Oper) + 1,
    charindex(']', @Oper) - charindex('[', @Oper) - 1)
  select @OperGid = GID from EMPLOYEE(nolock)
    where CODE = @OperCode
  if @@rowcount = 0
  begin
    set @Msg = '不能识别的操作员工' + rtrim(@Oper) + '。'
    return(1)
  end

  select @Dept = DEPT from MXFDMD(nolock)
    where NUM = @Num  
  if @OptDeptLimit = 1 and IsNull(@Dept, '') <> ''
  begin
    if not exists(select * from DEPTEMP(nolock)
      where EMPGID = @OperGid and DEPTCODE = @Dept)
    begin
      set @Msg = '启用了部门限制，当前登录员工不是单据指定部门的员工，不能操作该单据。'
      return(1)
    end
  end
  return 0
end
GO
