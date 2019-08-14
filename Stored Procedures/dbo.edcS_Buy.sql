SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_Buy] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate		datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int,
	@storegid int
  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0
  
  insert into ShouldExchgDataDtl(senddate,cls,num,checkint1,tgt,src)
  select convert(char(10), @finishdate, 102), 'Buy表', '0', count(*), @zbgid, @usergid
  from buy1(nolock)
end
GO
