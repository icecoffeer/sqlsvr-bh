SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_InDRpt] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate		datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0

	insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,checkdata1,checkdata2,tgt,src)
    select adate, '进货日报',convert(varchar(12),adate,102), 
    	count(adate),
    	convert(decimal(20,2), sum(dq1+dq2+dq3+dq4)),
    	convert(decimal(20,2), sum(dt1+dt2+dt3+dt4)),
    	@zbgid,@usergid
    from indrpt (nolock)
    where Astore = @usergid 
    	and adate between @startdate and @finishdate
    group by adate
end
GO
