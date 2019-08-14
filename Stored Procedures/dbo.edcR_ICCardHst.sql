SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_ICCardHst] (
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

	insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,checkint3,checkdata1,checkdata2,checkdata3,tgt,src)
	select convert(datetime,convert(char(10),ih.fildate,102)), 'IC卡记录', ih.cardnum, 
	    sum(case ih.action when '消费' then 1 else 0 end),
	    sum(case ih.action when '充值' then 1 else 0 end),
	    sum(case ih.action when '转储' then 1 else 0 end),
		sum(case ih.action when '消费' then occur else 0 end),
		sum(case ih.action when '充值' then occur else 0 end),
		sum(case ih.action when '转储' then occur else 0 end),@usergid,store
	from iccardhst ih (nolock)
	where ih.fildate between @startDate and @finishDate
	group by convert(datetime,convert(char(10),ih.fildate,102)),ih.cardnum,store
end
GO
