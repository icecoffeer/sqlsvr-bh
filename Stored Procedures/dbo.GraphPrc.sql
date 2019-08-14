SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[GraphPrc]
  @gdgid int, @fromdate datetime, @todate datetime
as
begin

/*
select @gdgid = (select gid from goods where code = '3512'), 
  @fromdate = '1999.1.17', 
  @todate = getdate()
*/

/* 补上第一天的记录 */
insert into #tgraphprc (num, fildate) values ('a', @fromdate)

/* 从本店已生效的调价单中生成上述表形式的数据 */
declare @num char(10), @cls char(10), @fildate datetime,
  @oldprc money, @newprc money, @invprc money
declare c cursor for
select m.num, m.cls, m.fildate, d.oldprc, d.newprc
from prcadjdtl d (nolock), prcadj m (nolock)
where 
  d.gdgid = @gdgid and 
  m.fildate between @fromdate and @todate and
  m.stat = 5 and
  m.cls = d.cls and 
  m.num = d.num and 
  m.eon = 1
order by m.fildate, m.num
open c
fetch next from c into @num, @cls, @fildate, @oldprc, @newprc
while @@fetch_status = 0
begin
  if not exists (select * from #tgraphprc where num = @num)
    insert into #tgraphprc (num, fildate) values (@num, @fildate)
  if @cls = '核算价' 
    update #tgraphprc set inprc_old = @oldprc, inprc_new = @newprc
    where num = @num
  else if @cls = '核算售价'
    update #tgraphprc set rtlprc_old = @oldprc, rtlprc_new = @newprc
    where num = @num
  select @invprc = avg(finvprc) from invdrpt(nolock)where 
    adate = convert(datetime,convert(char,@fildate,102)) and
    bgdgid = @gdgid
  if @invprc is not null update #tgraphprc set invprc_new = @invprc
  fetch next from c into @num, @cls, @fildate, @oldprc, @newprc
end
close c
deallocate c

/* 删除第一天的记录? */
if (select convert(char,fildate,102) from #tgraphprc where rid = 2) = convert(char,@fromdate,102)
  delete from #tgraphprc where rid = 1  

/* 补上最后一天的记录 */
if not exists (select * from #tgraphprc where fildate > convert(datetime, convert(char,getdate(),102)))
  insert into #tgraphprc (num, fildate) values ('z', @todate)

/* 整理数据.将0换成相应的值
   0,   0,   0,   x1, 0,  0,  0,  x2, x3, 0,  0
   -->
   x1o, x1o, x1o, x1, x1, x1, x1, x2, x3, x3, x3
   如果全0或没有记录,使用GOODS.XPRC
*/
/* 对INPRC,将调价<>0的第一条记录之前的置成这条记录的调价前的值 */
declare @rid int, @inprc_last money, @rtlprc_last money, @invprc_last money
select @rid = min(rid) from #tgraphprc where inprc_new <> 0
if @rid is not null
begin
  select @inprc_last = inprc_old from #tgraphprc where rid = @rid
  update #tgraphprc set inprc_new = @inprc_last where rid < @rid
end
else
begin
  select @inprc_last = inprc from goods where gid = @gdgid
  update #tgraphprc set inprc_new = @inprc_last
end
/* 对RTLPRC做同样的事情 */ 
select @rid = min(rid) from #tgraphprc where rtlprc_new <> 0
if @rid is not null
begin
  select @rtlprc_last = rtlprc_old from #tgraphprc where rid = @rid
  update #tgraphprc set rtlprc_new = @rtlprc_last where rid < @rid
end
else
begin
  select @rtlprc_last = rtlprc from goods where gid = @gdgid
  update #tgraphprc set rtlprc_new = @rtlprc_last
end
/* 对INVPRC做同样的事情 */ 
select @rid = min(rid) from #tgraphprc where invprc_new <> 0
if @rid is not null
begin
  select @invprc_last = invprc_new from #tgraphprc where rid = @rid
  update #tgraphprc set invprc_new = @invprc_last where rid < @rid
end
else
begin
  select @invprc_last = invprc from goods where gid = @gdgid
  update #tgraphprc set invprc_new = @invprc_last
end

/* 填充中间的0为上一条记录的值 */
declare @inprc money, @rtlprc money
declare c cursor for 
select rid, inprc_new, rtlprc_new, invprc_new from #tgraphprc order by rid
open c
fetch next from c into @rid, @inprc, @rtlprc, @invprc
while @@fetch_status = 0 
begin
  if @inprc = 0 update #tgraphprc set inprc_new = @inprc_last where rid = @rid
  else select @inprc_last = @inprc
  if @rtlprc = 0 update #tgraphprc set rtlprc_new = @rtlprc_last where rid = @rid
  else select @rtlprc_last = @rtlprc
  if @invprc = 0 update #tgraphprc set invprc_new = @invprc_last where rid = @rid
  else select @invprc_last = @invprc
  fetch next from c into @rid, @inprc, @rtlprc, @invprc
end
close c
deallocate c
end
GO
