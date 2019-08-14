SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HD_SPACEUSED] 
as  
  
declare @pages int   -- Working variable for size calc.  
declare @dbname sysname  
declare @dbsize dec(15,0)  
declare @logsize dec(15)  
declare @bytesperpage dec(15,0)  
declare @pagesperMB  dec(15,0),
        @database_size dec(17,3),
        @unallocated dec(17,3),
        @reserved dec(17,3),
        @data dec(17,3),
        @index_size dec(17,3),
        @unused dec(17,3)
  
 
create table #spt_space  
(  
 rows  int null,  
 reserved dec(15) null,  
 data  dec(15) null,  
 indexp  dec(15) null,  
 unused  dec(15) null  
)  
   
  
set nocount on  
 
 select @dbsize = sum(convert(dec(15),size))  
  from dbo.sysfiles  
  where (status & 64 = 0)  
  
 select @logsize = sum(convert(dec(15),size))  
  from dbo.sysfiles  
  where (status & 64 <> 0)  
  
 select @bytesperpage = low  
  from master.dbo.spt_values  
  where number = 1  
   and type = 'E'  
 select @pagesperMB = 1048576 / @bytesperpage  
  
 select  --database_name = db_name(),  
  @database_size =  
  (@dbsize + @logsize) / (@pagesperMB * 1024.),  
  @unallocated =  
   (@dbsize -  
    (select sum(convert(dec(15),reserved))  
     from sysindexes  
      where indid in (0, 1, 255)  
    )) / (@pagesperMB * 1024.) 
 
 
 insert into #spt_space (reserved)  
  select sum(convert(dec(15),reserved))  
   from sysindexes  
    where indid in (0, 1, 255)  
  
 
 select @pages = sum(convert(dec(15),dpages))  
   from sysindexes  
    where indid < 2  
 select @pages = @pages + isnull(sum(convert(dec(15),used)), 0)  
  from sysindexes  
   where indid = 255  
 update #spt_space  
  set data = @pages  
  
  
 /* index: sum(used) where indid in (0, 1, 255) - data */  
 update #spt_space  
  set indexp = (select sum(convert(dec(15),used))  
    from sysindexes  
     where indid in (0, 1, 255))  
       - data  
  
 /* unused: sum(reserved) - sum(used) where indid in (0, 1, 255) */  
 update #spt_space  
  set unused = reserved  
    - (select sum(convert(dec(15),used))  
     from sysindexes  
      where indid in (0, 1, 255))  
  
 select @reserved = reserved * d.low / (1024. * 1024. * 1024.),  
  @data = data * d.low / (1024. * 1024. * 1024.),  
  @index_size = indexp * d.low / (1024. * 1024. * 1024.),  
  @unused = unused * d.low / (1024. * 1024. * 1024.)  
  from #spt_space, master.dbo.spt_values d  
  where d.number = 1  
   and d.type = 'E'  
   
select database_name = db_name(),
       database_size = ltrim(str(@database_size,15,3) + ' GB'),
       unallocated = ltrim(str(@unallocated,15,3) + ' GB'),
       reserved = ltrim(str(@reserved,15,3) +  ' ' + 'GB'),
       data = ltrim(str(@data + @index_size,15,3) +  ' ' + 'GB'),
       unused = ltrim(str(@unused,15,3) +  ' ' + 'GB')
  
return (0)
GO
