SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_StkOutBck] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate		datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int,
    @fildate datetime,
    @stat int,
    @modnum char(10),
    @num char(10),
    @reccnt int,
    @checkdata1 money,
    @tgt int

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0

  declare c_edcS cursor for 
  select convert(datetime,convert(varchar(10),o.fildate,102)),
    o.num,o.reccnt,o.total,o.modnum,o.stat,o.client
  from stkoutbck o (nolock) 
  where  o.stat in (1,4) and cls = '配货' 
    and o.fildate between @startdate and @finishdate
    and (o.src=@usergid or o.src = 1)
  open c_edcS
  fetch next from c_edcS into @fildate,@num,@reccnt,@checkdata1,@modnum,@stat,@tgt
  while @@Fetch_status = 0
  begin
    if @stat = 1 
      insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
        values (convert(char(10), @fildate, 102),'配货出退',@num,@reccnt,@stat,@checkdata1,@tgt,@usergid)
   
    while isnull(@ModNum,'') <> ''
    begin
      select @num = '',@reccnt = 0
      select @num = o.num,@reccnt = o.reccnt,@modnum = o.modnum,
        @stat = o.stat,@checkdata1 = o.total,@tgt = o.client
	  from stkoutbck o(nolock) where num = @modnum and stat = 2 and cls = '配货' 
	  if @@Rowcount = 0
	  begin
	    close c_edcS
	    deallocate c_edcS
		raiserror('在配货出货退货单根据修正链找不到原始单据，现在单号是%s',16,1,@num)
		return -1
	  end else
	    insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
	      values (convert(char(10), @fildate, 102),'配货出退',@num,@reccnt,@stat,@checkdata1,@tgt,@usergid)
    end
    fetch next from c_edcS into @fildate,@num,@reccnt,@checkdata1,@modnum,@stat,@tgt
  end
  close c_edcS
  deallocate c_edcS
end
GO
