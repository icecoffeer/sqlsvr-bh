SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_ICBuy1] (
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

	insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkdata1,tgt,src)
	select convert(datetime,convert(char(10),fildate,102)), 'IC卡零售', b1.flowno+b1.posno, reccnt,realamt,@usergid,store
	from icbuy1 b1 (nolock)
	where b1.fildate between @startDate and @finishDate
end
GO
