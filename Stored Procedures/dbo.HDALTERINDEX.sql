SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDALTERINDEX]
(
  @piIndexName sysname,         --索引名称
  @piTableName sysname,         --表名
  @piColNames  varchar(255),    --列名
  @piUnique int,                --是否唯一索引
  @piClustered int,             --是否聚簇索引
  @pitbSpace varchar(255) = ''  --表空间, 对MSSQL无效         
) as
begin
  declare @ColNames varchar(200) 
  declare @ClusterStr varchar(20)
  declare @pk sysname

  select @ColNames = ltrim(rtrim(@piColNames))
  if SubString(@ColNames, 1, 1) <> '('
    select @ColNames = '(' + @ColNames + ')'
  
  if @piClustered = 1 
    select @ClusterStr = ' clustered '
  else
    select @ClusterStr = ''
  
  if IsNull(@piIndexName, '') = ''
  begin
    if @piUnique = 2
    begin
      select @pk = a.NAME from SYSOBJECTS a, SYSOBJECTS b where a.PARENT_OBJ = b.ID
        and b.NAME = @piTableName and a.XTYPE = 'PK'
      if @@rowcount > 0
        exec('alter table [' + @piTableName + '] drop constraint ' + @pk)
    end
    if @piUnique = 2
      exec('alter table [' + @piTableName + '] add primary key ' + @ClusterStr + @ColNames)
    else if @piUnique = 3
      exec('alter table [' + @piTableName + '] add foreign key ' +@ColNames)
    else if @piUnique = 4
      exec('alter table [' + @piTableName + '] add check ' + @ColNames)
    else if @piUnique = 5
      exec('alter table [' + @piTableName + '] add unique ' + @ClusterStr + @ColNames)
  end else
  begin
    if @piUnique in (2, 3, 4, 5)
    begin
      if exists (select 1 from SYSOBJECTS a, SYSOBJECTS b where a.PARENT_OBJ = b.ID
        and b.NAME = @piTableName and a.NAME = @piIndexName
        and a.XTYPE in ('PK', 'UQ', 'F', 'C'))
      begin
          exec('alter table [' + @piTableName + '] drop constraint ' + @piIndexName)
      end
      if @piUnique = 2
        exec('alter table [' + @piTableName + '] add constraint ' + @piIndexName + ' primary key ' + @ClusterStr + @ColNames)
      else if @piUnique = 3
        exec('alter table [' + @piTableName + '] add constraint ' + @piIndexName + ' foreign key ' + @ColNames)
      else if @piUnique = 4
        exec('alter table [' + @piTableName + '] add constraint ' + @piIndexName + ' check ' + @ColNames)
      else if @piUnique = 5
        exec('alter table [' + @piTableName + '] add constraint ' + @piIndexName + ' unique ' + @ClusterStr + @ColNames)
    end else
    begin
      if exists(select 1 from SYSINDEXES i, SYSOBJECTS o where o.NAME = @piTableName 
        and o.XTYPE = 'U' and i.ID = o.ID and i.NAME = @piIndexName)
      begin
        exec('drop index ' + @piTableName + '.' + @piIndexName)
      end
      if @piUnique = 1
        exec('create unique ' + @ClusterStr + ' index ' + @piIndexName + ' on [' + @piTableName + ']' + @ColNames)
      else
        exec('create ' + @ClusterStr + ' index ' + @piIndexName + ' on [' + @piTableName + ']' + @ColNames)
    end
  end    
  return(0)
end
GO
