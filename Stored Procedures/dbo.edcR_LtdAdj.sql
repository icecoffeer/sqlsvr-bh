SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_LtdAdj] (
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
    @num char(14),
    @srcnum char(14),
    @modnum char(14),
    @reccnt int,
    @src int,
    @billcls char(10),
    @checkdata1 money

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0

	--select @billcls = substring(@cls, 1, len(@cls)-3)
	insert into RealExchgDataDtl(RecvDate,cls,num,checkint1,tgt,src,checkint2)
	select convert(datetime,convert(char(10),p.fildate,102)),
		@cls,p.srcnum,count(pd.line),@usergid,p.src,p.stat
	from ltdadj p (nolock), ltdadjdtl pd (nolock)
	where p.num = pd.num --and p.stat in (100,800) 
	    and p.fildate between @StartDate and @FinishDate
		and (p.src <> @usergid and p.src <> 1)
	group by p.fildate,p.src,p.srcnum,p.stat
end
GO
