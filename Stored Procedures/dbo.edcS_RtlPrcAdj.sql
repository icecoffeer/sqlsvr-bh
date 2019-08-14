SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_RtlPrcAdj] (
	@cls		varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid		int
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0

  --declare @billcls char(10)
  --select @billcls = substring(@cls, 1, len(@cls)-3)
  insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,tgt,src,checkint2)
  select convert(datetime,convert(char(10),p.chkdate,102)), --用审核时间
    @cls,p.num,p.reccnt,pld.storegid,@usergid,p.stat--如果对不上，有可能是RECCNT有问题
    --,convert(datetime,convert(char(10),p.sndtime,102))--增加发送时间
  from rtlprcadj p (nolock), rtlprcadjlacdtl pld (nolock)
  where p.num = pld.num and p.stat in (100,800)--如果有对不上，还要查看是否发送出去。
    and p.fildate between @startdate and @finishdate
    and pld.storegid <> @usergid
    and (p.src = @usergid or p.src = 1)
end
GO
