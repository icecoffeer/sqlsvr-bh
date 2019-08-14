SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_InvChgDRpt] (
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
  if @usergid <> @zbgid return 0

	insert into RealExchgDataDtl(recvdate,cls,num,checkint1,checkdata1,checkdata2,tgt,src)
	select ADate, '库存调整日报',convert(varchar(12),adate,102), 
		count(adate),
		convert(decimal(20,2), sum(dq1+dq2+dq4+dq5)),
		convert(decimal(20,2), sum(di1+di2+di3+di4+di5)),
		@zbgid,astore
	from invchgdrpt (nolock)
	where adate between @startDate and @finishdate
	group by astore,adate
end
GO
