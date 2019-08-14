SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_PrcAdj] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
    @usergid int,
    @zbgid int,
    @fildate datetime,
    @stat int,
    @num char(10),
    @srcnum char(10),
    @modnum char(10),
    @reccnt int,
    @src int,
    @billcls char(10),
    @checkdata1 money

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0

	select @billcls = substring(@cls, 1, len(@cls)-3)
	insert into RealExchgDataDtl(RecvDate,cls,num,checkint1,tgt,src,checkint2)
	select convert(datetime,convert(char(10),p.fildate,102)),
		@cls,p.srcnum,count(pd.line),@usergid,p.src,p.stat
	from prcadj p (nolock), prcadjdtl pd (nolock)
	where p.cls = pd.cls and p.num = pd.num
	    --and p.stat in (1,5) 
	    and p.fildate between @StartDate and @FinishDate
		and (p.src <> @usergid and p.src <> 1)
		and p.cls = @billcls
	group by p.fildate,p.src,p.srcnum,p.stat
end
GO
