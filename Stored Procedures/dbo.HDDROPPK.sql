SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPPK]
(
  @piTableName sysname --表名
) as
begin
  declare @pk varchar(50)
  select @pk = a.NAME from SYSOBJECTS a, SYSOBJECTS b where a.PARENT_OBJ = b.ID
    and b.NAME = @piTableName and a.XTYPE = 'PK'
  if @@rowcount > 0
    exec('alter table [' + @piTableName + '] drop constraint ' + @pk)
  return(0)
end
GO
