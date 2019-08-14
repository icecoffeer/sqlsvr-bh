SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_PrmBanlan] (
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
	select ADate, '促销进价销售差额日报',convert(varchar(12),adate,102), 
		count(adate),
		convert(decimal(20,2), sum(dq1+dq2+dq3+dq4)),
		convert(decimal(20,2), sum(dp1+dp2+dp3+dp4)),
		@zbgid,astore
	from prmbanlan(nolock)
	where adate between @startDate and @finishdate
	group by astore,adate
end
GO
