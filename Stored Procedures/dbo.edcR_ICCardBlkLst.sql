SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_ICCardBlkLst] (
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

  select @n = count(*) from ICCARDBLKLST(nolock)
  insert into RealExchgDataDtl(RecvDate,cls,num,checkint1,tgt,src)
    values(convert(varchar(102), @finishdate, 102), 'IC卡黑名单', '0', @n, @usergid,@zbgid)
end
GO
