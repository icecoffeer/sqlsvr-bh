SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPINDEX]
(
  @piTableName sysname,  --表名
  @piIndexName sysname   --索引名
) as
begin
  if exists(select 1 from SYSINDEXES i, SYSOBJECTS o where o.NAME = @piTableName 
    and o.XTYPE = 'U' and i.ID = o.ID and i.NAME = @piIndexName)
    exec('drop index ' + @piTableName + '.' + @piIndexName)

  return(0)
end
GO
