SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[KillUser_DoAfterKill](
  @empcode char(10), --被踢用户代码
  @hostname nchar(256), --被踢工作站编号
  @msg varchar(255) output
)
with encryption
as
begin
  declare
    @settleno int,
    @oper varchar(30),
    @opercode varchar(10),
    @opername varchar(20),
    @workstationno char(10)
  set @msg = ''
  select @settleno = max(NO) from MONTHSETTLE(nolock)
  select @oper = suser_sname()
  select @opercode = substring(@oper, charindex('_', @oper) + 1, 10)
  select @opername = NAME from EMPLOYEE(nolock) where CODE = @opercode
  select @workstationno = isnull(HOSTNAME, '') from master..sysprocesses where SID = suser_sid()
  insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values(GetDate(), @settleno, @opercode, @opername, @workstationno, '当前用户:228', 101, '踢出用户。代码：' + @empcode + '，工作站编号：' + @hostname)
  return 0
end
GO
