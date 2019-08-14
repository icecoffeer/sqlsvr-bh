SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDALTERPK]
(
  @piTableName sysname,      --表名
  @piColNames  varchar(255)  --列名
) as  
begin
  declare @pk varchar(50)
  select @pk = a.NAME from SYSOBJECTS a, SYSOBJECTS b where a.PARENT_OBJ = b.ID
    and b.NAME = @piTableName and a.XTYPE = 'PK'
  if @@rowcount > 0
    exec('alter table [' + @piTableName + '] drop constraint ' + @pk)
  exec('alter table [' + @piTableName + '] add primary key (' + @piColNames + ')')
  return(0)
end
GO
