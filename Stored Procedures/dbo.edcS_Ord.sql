SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcS_Ord] (
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
    @rcv1 int,
    @rcv2 int,
    @num char(10),
    @modnum char(10),
    @reccnt int,
    @checkdata1 money,
    @tgt int

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  
  declare c_edc cursor for
  select convert(datetime,convert(varchar(10),o.fildate,102)),
    o.num, o.reccnt, o.total, o.modnum, o.stat, o.vendor, o.receiver
  from ord o (nolock) 
  where o.stat in (1,4) 
    and o.fildate between @startdate and @finishdate
    and (o.src = @usergid or o.src = 1)
  open c_edc
  fetch next from c_edc into @fildate,@num,@reccnt,@checkdata1,@modnum,@stat,@rcv1,@rcv2
  while @@fetch_status = 0
  begin
    if @stat = 1 
    begin
      if @rcv1 = @zbgid
        insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
	      values (convert(varchar(10), @fildate, 102),'定单',@num,@reccnt,@stat,@checkdata1,@rcv1,@usergid)
	  else if @rcv2 <> @usergid
        insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
	      values (convert(varchar(10), @fildate, 102),'定单',@num,@reccnt,@stat,@checkdata1,@rcv2,@usergid)
	  else begin
	  	fetch next from c_edc into @fildate,@num,@reccnt,@checkdata1,@modnum,@stat,@rcv1, @rcv2
	  	continue
	  end
    end
    
    while isnull(@ModNum,'') <> ''
    begin
      select @num = '',@reccnt = 0
      select @num = o.num, @reccnt = o.reccnt, @modnum = o.modnum,
        @stat = o.stat,@CheckData1 = o.total,@tgt = o.vendor
      from ord o(nolock) where num = @modnum and stat = 2
      if @@RowCount = 0
      begin
        close c_edc
        deallocate c_edc
		raiserror('在定货单根据修正链找不到原始单据，现在单号是%s',16,1, @num)
	    return -1
	  end else
	  begin
	  	if @rcv1 = @zbgid
          insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
            values (convert(char(10), @fildate, 102),'定单',@num,@reccnt,@stat,@checkdata1,@rcv1,@usergid)
        else if @rcv2 <> @usergid
          insert into ShouldExchgDataDtl(SendDate,cls,num,checkint1,checkint2,checkdata1,tgt,src)
            values (convert(char(10), @fildate, 102),'定单',@num,@reccnt,@stat,@checkdata1,@rcv2,@usergid)
	  end
	end
		
    fetch next from c_edc into @fildate,@num,@reccnt,@checkdata1,@modnum,@stat,@rcv1, @rcv2
  end
  close c_edc
  deallocate c_edc
end
GO
