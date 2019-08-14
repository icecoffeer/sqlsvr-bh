SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_USER_DROP_DBMSUSER](
  @piDatabaseName sysname,        --数据库名
  @piLoginName char(20)           --对应系统用户登录名
) as
begin
  declare @sUserName varchar(200), @nRet int
    
  set @sUserName = @piDatabaseName + '_' + rtrim(@piLoginName)
  exec @nRet = sp_droplogin @sUserName
    
  return @nRet
end
GO
