SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDALTERCOLUMN]
(
  @piTableName sysname,    --表名
  @piColName  varchar(50), --列名
  @piTypeStr varchar(30),  --类型字符串
  @piNullable int          --是否允许为空
) as
begin
  exec('alter table [' + @piTableName + '] disable trigger all')
  if @piNullable = 1
    exec('alter table [' + @piTableName + '] alter column ' + @piColName + ' ' + @piTypeStr + ' NULL')
  else
    exec('alter table [' + @piTableName + '] alter column ' + @piColName + ' ' + @piTypeStr + ' NOT NULL')
  exec('alter table [' + @piTableName + '] enable trigger all')
  return(0)
end
GO
