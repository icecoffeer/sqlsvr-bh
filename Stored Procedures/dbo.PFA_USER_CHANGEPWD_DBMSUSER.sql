SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_USER_CHANGEPWD_DBMSUSER](
  @piDatabaseName sysname,        --数据库名
  @piLoginName char(20),          --对应系统用户登录名
  @piPassword sysname             --密码，加密过的
) as
begin
  declare
    @sUserName varchar(200),
    @sCmd varchar(8000),
    @sProductVersion varchar(100),
    @dProductVersion decimal(24,4),
    @nRet int

  --用户名
  set @sUserName = @piDatabaseName + '_' + rtrim(@piLoginName)
  
  --数据库服务器版本号
  select @sProductVersion = convert(varchar, serverproperty('productversion'))
  set @dProductVersion = convert(decimal(24,4),
    substring(@sProductVersion, 1, charindex('.', @sProductVersion) - 1))
  
  if @dProductVersion >= 9
  begin
    set @sCmd = 'ALTER LOGIN ' + @sUserName
      + ' WITH password = ''' + @piPassword +''','
      + ' CHECK_POLICY = OFF,'
      + ' CHECK_EXPIRATION = OFF';
    exec(@sCmd)
    set @nRet = 0
  end
  else begin
    exec @nRet = sp_password null, @piPassword, @sUserName
  end

  return @nRet 
end
GO
