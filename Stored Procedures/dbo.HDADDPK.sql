SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDADDPK]
(
  @piTableName sysname,      --表名
  @piColNames  varchar(255)  --列名
) as  
begin
  if not exists(select 1 from SYSOBJECTS a, SYSOBJECTS b 
    where a.XTYPE = 'PK' and a.PARENT_OBJ = b.ID
      and b.XTYPE = 'U' and b.NAME = @piTableName)
    exec('alter table [' + @piTableName + '] add primary key (' + @piColNames + ')')
  else
    print 'WARNING: HDADDPK失败' + @piTableName + '(' + @piColNames + '), 表已存在主键'
  return(0)
end
GO
