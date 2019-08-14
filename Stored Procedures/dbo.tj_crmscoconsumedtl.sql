SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[tj_crmscoconsumedtl]
as
begin  
  declare @store int, @startdate datetime, @enddate datetime
  
  select @store=usergid from system(nolock)
  select @startdate=convert(char(10),getdate()-1,102)
  select @enddate=getdate()  

  delete from crmscoconsumedtl where fildate>=@startdate and fildate<=@enddate
  insert into crmscoconsumedtl
  select distinct a.fildate,@store store,a.cardcode cardnum,'收银机号:'+rtrim(a.posno)+' 流水号:'+rtrim(a.flowno) note,rtrim(e1.name)+'['+rtrim(e1.code)+']' cashier,rtrim(e2.name)+'['+rtrim(e2.code)+']' assistant,
  rtrim(g.name)+'['+rtrim(g.code)+']' gd,rtrim(f.name)+'['+rtrim(f.code)+']' brand,rtrim(d.name)+'['+rtrim(d.code)+']' dept,rtrim(s.name)+'['+rtrim(s.code)+']' sort,b.realamt
  from buy1 a(nolock),buy2 b(nolock),employee e1(nolock),employee e2(nolock),brand f(nolock),goods g(nolock),dept d(nolock),sort s(nolock)
  where a.posno=b.posno and a.flowno=b.flowno and len(a.cardcode)>=6
  and a.cashier=e1.gid and b.assistant=e2.gid and b.gid=g.gid and g.brand=f.code and g.f1=d.code and g.sort=s.code
  and a.fildate>=@startdate and a.fildate<=@enddate
end
GO
