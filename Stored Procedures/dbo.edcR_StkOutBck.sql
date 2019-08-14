SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_StkOutBck] (
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
    @reccnt int,
    @src int,
    @checkdata1 money

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if @usergid = @zbgid return 0

	insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
	select convert(datetime,convert(varchar(10),o.fildate,102)),'配货出退',
		srcnum,reccnt,stat,@usergid,Src,total
	from stkinbck o(nolock)
	where  o.stat = 1 and o.cls = '配货' and o.modnum is null
		and o.fildate between @StartDate and @FinishDate
		and (o.src<>@usergid and o.src <> 1)

	declare c_edcR cursor for 
	select convert(datetime,convert(varchar(10),o.fildate,102)),
		o.num,o.srcnum,reccnt,o.src,o.modnum,o.stat,total
	from stkinbck o (nolock) 
	where  o.stat in (1,4) and o.cls = '配货' and o.modnum is not null
		and o.fildate between @StartDate and @FinishDate
		and (o.src<>@usergid and o.src <> 1)
	open c_edcR
	fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	while @@Fetch_status = 0
	begin
		if @stat = 1 
		    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
			values (convert(char(10), @fildate, 102),'配货出退',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)

		while isnull(@ModNum,'') <> ''
		begin
			select @srcnum = '',@reccnt = 0
			--如果是冲销单，则修正单号对应本地的单据号。
			--如果是修正后的单据，则修正单号对应来源单号。
			--因为一张单据只能被冲销或修正一次，所以单据状态为2的单据的修正单号对应来源单号
			--配货单都是按照这个逻辑来处理。其他单据不是按这个逻辑处理。
			if @stat = 4
			begin
				select @num = num,@srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
					@stat = o.stat,@checkdata1 = total
				from stkinbck o(nolock) where num = @modnum and cls = '配货' and stat = 2 AND src = @src
			end
			else
			begin
				select @num = num,@srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
					@stat = o.stat,@checkdata1 = total
				from stkinbck o(nolock) where srcnum = @modnum and cls = '配货' and stat = 2 AND src = @src
			end
			if @@Rowcount = 0
			begin
				select @num = num,@srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
					@stat = o.stat,@checkdata1 = total
				from stkinbck o(nolock) where num = @modnum and cls = '配货' and stat = 2 AND src = @src
				if @@RowCount = 0
				begin
					close c_edcR
					Deallocate c_edcR
					Raiserror('在配货出货退货单中根据修正链找不到原始单据，现在单号是%s',16,1,@num)
					return -1
				end
			end
				--为了修正接收配货进退单过程的错误。
			    if not exists (select 1 from realexchgdatadtl
				where recvdate = @fildate and cls= '配货出退' 
					and num = @srcnum and tgt = @usergid and src = @src )
				    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
					values (convert(char(10), @fildate, 102),'配货出退',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)
		end
 		fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	end
	close c_edcR
	deallocate c_edcR
end
GO
