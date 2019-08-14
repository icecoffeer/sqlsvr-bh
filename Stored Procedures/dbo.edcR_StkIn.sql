SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_StkIn] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
    @usergid int,
    @zbgid int,
    @fildate datetime,
    @stat int,
    @num char(10),
    @srcnum char(10),
    @modnum char(10),
    @realcls char(10),
    @reccnt int,
    @src int,
    @checkdata1 money

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid <> @zbgid return 0

    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
	select convert(datetime,convert(varchar(10),o.fildate,102)),'配货进',
		srcnum,reccnt,stat,@usergid,Src,total
		from stkout o(nolock)
	where  o.stat = 1 and o.cls = '配货' and o.modnum is null
		and o.fildate between @StartDate and @FinishDate
		and (o.src<>@usergid and o.src <> 1)

	declare c_edcR cursor for 
	select convert(datetime,convert(varchar(10),o.fildate,102)),
		o.num,o.srcnum,o.reccnt,o.src,o.modnum,o.stat,o.total
	from stkout o (nolock)
	where  o.stat in (1,4) and o.cls = '配货' and o.modnum is not null
		and o.fildate between @StartDate and @FinishDate
		and (o.src<>@usergid and o.src <> 1)
	open c_edcR
	fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	while @@Fetch_status = 0
	begin
		if @stat = 1 
		    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
			values (convert(char(10), @fildate, 102),'配货进',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)

		while isnull(@ModNum,'') <> ''
		begin
			select @srcnum = '',@reccnt = 0
			if @stat = 4
				select @srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum
					,@stat = o.stat,@checkdata1= total
				from stkout o(nolock) where num = @modnum and cls = '配货' and stat = 2 and src = @src
			else
				select @srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum
					,@stat = o.stat,@checkdata1= total
				from stkout o(nolock) where Srcnum = @modnum and cls = '配货' and stat = 2 and src = @src
			if @@RowCount = 0
			begin
				select @srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum
					,@stat = o.stat,@checkdata1= total
				from stkout o(nolock) where num = @modnum and cls = '配货' and stat = 2 and src = @src
				if @@RowCount = 0
				begin
					close c_edcR
					Deallocate c_edcR
					Raiserror('在配货出货单中根据修正链找不到原始单据，现在单号是%s',16,1,@num)
					return -1
				end
			end
  		    if not exists (select 1 from realexchgdatadtl
			    where recvdate = @fildate and cls= '配货进' 
			        and num = @srcnum and tgt = @usergid and src = @src )
			begin
			    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
				values (convert(char(10), @fildate, 102),'配货进',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)
			end
			select @num = @modnum

		end
 		fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
    end
    close c_edcR
    deallocate c_edcR
end
GO
