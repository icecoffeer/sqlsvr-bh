SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  
create procedure [dbo].[GetTableItems]  
@tbname varchar(50)   
as   
begin   
set nocount on   
if object_id('#a') is not null  drop table #a   
if object_id('#b') is not null  drop table #b   
   
create table #a(   
表名 varchar(100),   
字段序号 int,   
字段名 varchar(50),   
标识 varchar(50),   
主键 varchar(10),   
类型 varchar(50),   
占用字节数 int,   
长度 int,   
小数位数 int,   
允许空 varchar(10),   
默认值 varchar(50),   
字段说明 varchar(100)   
)   
   
create table #b(   
tbname varchar(50)   
)   
   
declare @flag smallint   
select @flag=dbo.dxm_isallhz(@tbname)   
   
if @flag=1   
begin   
 insert into #b select rtrim(c.tablename) from [collate] c where rtrim(c.tablelabel) like '%'+rtrim(@tbname)+'%'   
end   
else   
begin   
 IF EXISTS(SELECT 1 FROM [collate] c where rtrim(c.tablename)=rtrim(@tbname))  
    INSERT into #b select rtrim(c.tablename) from [collate] c where rtrim(c.tablename)=rtrim(@tbname)  
 ELSE  
    INSERT INTO #B  
    SELECT [NAME] FROM sysobjects s(NOLOCK) WHERE s.xtype='U' AND RTRIM(S.NAME) LIKE '%'+rtrim(@tbname)+'%'  
end   
   
----select * from #b   
   
declare cur_t cursor for select tbname from #b(nolock) order by tbname   
open cur_t   
fetch next from cur_t into @tbname   
while @@fetch_status=0   
begin   
insert into #a   
SELECT       
---(case when a.colorder=1 then d.name else '' end) as 表名,--如果表名相同就返回空     
     rtrim(convert(varchar,d.name)) as 表名,--如果表名相同就返回空     
     a.colorder as 字段序号,      
     a.name as 字段名,      
     (case when COLUMNPROPERTY( a.id,a.name, 'IsIdentity' )=1 then '√' else '' end) as 标识,      
     (case when (SELECT count(*) FROM sysobjects--查询主键     
                     WHERE (name in       
                             (SELECT name FROM sysindexes       
                             WHERE (id = a.id)   AND (indid in       
                                     (SELECT indid FROM sysindexkeys      
                                       WHERE (id = a.id) AND (colid in       
                                         (SELECT colid FROM syscolumns      
                                         WHERE (id = a.id) AND (name = a.name))      
                         )))))       
         AND (xtype = 'PK' ))>0 then '√' else '' end) as 主键,--查询主键END      
b.name as 类型,      
a.length as 占用字节数,      
COLUMNPROPERTY(a.id,a.name,'PRECISION') as    长度,      
isnull(COLUMNPROPERTY(a.id,a.name,'Scale' ),0) as 小数位数,      
(case when a.isnullable=1 then '√' else '' end) as 允许空,      
convert(varchar(20),isnull(e.text,'' )) as 默认值,'' 字段说明  ---,convert(varchar(50),isnull(g.[value],'' )) AS 字段说明  
FROM syscolumns a    
left join systypes b  on a.xtype=b.xusertype      
inner join sysobjects d  on a.id=d.id and d.xtype='U' and d.name<> 'dtproperties'       
left join syscomments e on a.cdefault=e.id      
---left join sys.extended_properties g  on a.id=g.major_id AND a.colid = g.minor_id       
where d.name=rtrim(@tbname) --所要查询的表     
order by a.id,a.colorder      
   
update #a set 表名=case when a.字段序号=1 then rtrim(a.表名)+':'+rtrim(c.tablelabel) else '' end,   
              字段说明=rtrim(isnull(ct.fieldlabel,''))+rtrim(isnull(字段说明,''))   
from #a a(nolock),[collate] c(nolock),[collateitem] ct(nolock)   
where rtrim(c.tablename)=rtrim(@tbname) and c.no=ct.collateno   
and a.字段名=ct.fieldname and a.表名=c.tablename   
   
fetch next from cur_t into @tbname   
end   
close cur_t   
deallocate cur_t   
   
set nocount off   
   
select 表名,字段序号,字段名,字段说明,标识,主键,类型,占用字节数,长度,小数位数,允许空,默认值   
from #a   
   
end   
  
  
----  
  
GO
