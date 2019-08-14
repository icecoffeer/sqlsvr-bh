SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_InPrcPrm] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int  
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0

            insert into RealExchgDataDtl(RecvDate,cls,num,checkint1,tgt,src,checkint2)
	    select convert(datetime,convert(char(10),p.fildate,102)), '进价促销单', p.srcnum, count(pd.line),
		@usergid,p.src,p.stat
	    from inprcprm p (nolock), inprcprmdtl pd (nolock)
	    where p.num = pd.num and p.stat = 1 and p.fildate between @StartDate and @FinishDate
		and (p.src <> @usergid and p.src <> 1)
		group by p.fildate,p.src,p.srcnum,p.stat

end
GO
