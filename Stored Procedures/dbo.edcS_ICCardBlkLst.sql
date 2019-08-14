SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_ICCardBlkLst] (
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
  if @usergid <> @zbgid return 0

	declare @BlackNum int
	select @BlackNum = count(*) from ICCARDBLKLST(nolock)
	insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,tgt,src)
	select convert(varchar(10), @FinishDate, 102), 'IC卡黑名单', '0', @BlackNum, gid, @usergid
	from store (nolock) where store.gid <> @zbgid 
end
GO
