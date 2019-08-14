SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPCOLUMN]
(
  @piTableName sysname,    --表名
  @piColName  varchar(50)  --列名
) as
begin
  declare @vSQL varchar(255)
  declare @constraint_name varchar(100)
  declare @objId integer
  if exists (select 1 from SYSCOLUMNS c(nolock), SYSOBJECTS s(nolock)
    where c.ID = s.ID and s.NAME = @piTableName and c.name = @piColName)
  begin
    select @objId = ID from SYSOBJECTS where XTYPE = 'U' and name = @piTableName
    --删除CHECK约束
    select @constraint_name = NAME from SYSOBJECTS where XTYPE = 'C' and ID in (
      select CONSTID from SYSCONSTRAINTS where ID = @objId
        and COLID = (select COLID from SYSCOLUMNS where ID = @objId and NAME = @piColName))
    if @@rowcount > 0
      exec('alter table [' + @piTableName + '] drop constraint ' + @constraint_name)
    --删除DEFAULT约束
    select @constraint_name = NAME from SYSOBJECTS where XTYPE = 'D' and ID in (
      select CONSTID from SYSCONSTRAINTS where ID = @objId
        and COLID = (select COLID from SYSCOLUMNS where ID = @objId and NAME = @piColName))
    if @@rowcount > 0
      exec('alter table [' + @piTableName + '] drop constraint ' + @constraint_name)

    select @vSQL = 'alter table [' + rtrim(@piTableName) + '] drop column ' + rtrim(@piColName)
    exec(@vSQL)  
  end
  return(0)
end
GO
