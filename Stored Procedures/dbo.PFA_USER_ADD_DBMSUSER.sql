SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_USER_ADD_DBMSUSER](
  @piDatabaseName sysname,        --数据库名
  @piLoginName char(20),          --对应系统用户登录名
  @piPassword sysname
) as
begin
  declare @sUserName varchar(200), @nRet int
    
  set @sUserName = @piDatabaseName + '_' + rtrim(@piLoginName)
  exec @nRet = sp_addlogin @sUserName ,@piPassword
  exec @nRet = sp_addsrvrolemember @sUserName, SYSADMIN
    
  return @nRet
end
GO
