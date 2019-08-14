SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_PrcAdj] (
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

  declare @billcls char(10)
  select @billcls = substring(@cls, 1, len(@cls)-3)
  insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,tgt,src,checkint2)
  select convert(datetime,convert(char(10),p.fildate,102)), 
    @cls,p.num,p.reccnt,pld.storegid,@usergid,p.stat
  from prcadj p (nolock), prcadjlacdtl pld (nolock)
  where p.cls = pld.cls and p.num = pld.num
    and p.stat in (1,5)
    and p.fildate between @startdate and @finishdate
    and pld.storegid <> @usergid
    and (p.src = @usergid or p.src = 1)
    and p.cls = @billcls
end
GO
