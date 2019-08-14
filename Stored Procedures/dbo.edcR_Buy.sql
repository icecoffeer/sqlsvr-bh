SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_Buy] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int,
	@n int
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0
  
  insert into RealExchgDataDtl(RecvDate,cls,num,checkint1,tgt,src)
  select convert(char(10), @finishdate, 102), 'Buy表', '0', count(*), @zbgid, storegid
  from storebuy1(nolock) group by storegid
end
GO
