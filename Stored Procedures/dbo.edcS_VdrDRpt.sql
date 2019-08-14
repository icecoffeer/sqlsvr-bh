SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_VdrDRpt] (
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
	select ADate, '供应商帐款日报',convert(varchar(12),adate,102), 
		count(adate),
		convert(decimal(20,2), sum(dq1+dq2+dq3+dq4+dq5+dq6)),
		convert(decimal(20,2), sum(dt1+dt2+dt3+dt4+dt5+dt6+dt7)),
		@zbgid,@usergid
	from vdrdrpt (nolock)
	where astore = @usergid
    	and adate between @startdate and @finishdate
	group by adate
end
GO
