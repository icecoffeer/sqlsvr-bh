SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[KillUser_DoBeforeKill](
  @empcode char(10), --被踢用户代码
  @hostname nchar(256), --被踢工作站编号
  @msg varchar(255) output
)
with encryption
as
begin
  set @msg = ''
  if day(getdate()) <> 24 or DATEPART (hour,getdate()) < 21
  begin
   set @msg = '需在月结日，即每月24号的21点之后才允许KILL用户'
   return (2)
  end
  if not exists (select 1 from employee(nolock) where code = @empcode)
  begin
    set @msg = '输入的用户代码不正确'
    return (2)
  end
  return 0
end
GO
