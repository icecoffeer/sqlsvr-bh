SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_LmtPrm] (
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

  insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,tgt,src,checkint2)
  select convert(datetime,convert(char(10),p.fildate,102)), 
    '限量促销单', p.num, p.reccnt,pld.storegid,@usergid,p.stat
  from lmtprm p (nolock), lmtprmlacdtl pld (nolock)
  where pld.num = p.num and p.stat = 1
    and p.fildate between @startdate and @finishdate
    and pld.storegid <> @usergid
    and (p.src = @usergid or p.src = 1)
end
GO
