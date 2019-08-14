SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDADDCOLUMN]
(
  @piTableName sysname,    --表名
  @piColName  varchar(50), --列名
  @piTypeStr  varchar(255)  --字段类型
) as
begin
  if not exists(select 1 from SYSOBJECTS a, SYSCOLUMNS b
    where a.ID = b.ID and a.NAME = @piTableName and b.NAME = @piColName)
  begin
    exec('alter table [' + @piTableName + '] disable trigger all')
    exec('alter table [' + @piTableName + '] add ' + @piColName + ' ' + @piTypeStr)
    exec('alter table [' + @piTableName + '] enable trigger all')
  end
  return(0)
end
GO
