SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_DirAlc] (
	@cls	varchar(30),
	@startdate	datetime,
	@finishdate	datetime
)
as
begin
  declare
	@usergid	int,
	@zbgid	int,
	@fildate datetime,
    @stat int,
    @num char(10),
    @realcls char(10),
    @srcnum char(10),
    @modnum char(10),
    @reccnt int,
    @src int,
    @checkdata1 money

    if @cls = '直配出'
		select @realcls = '直配进'
	if @cls = '直配出退'
		select @realcls = '直配进退'
	if @cls = '直配进'
		select @realcls = '直配出'
	if @cls = ' 直配进退'
		select @realcls = '直配出退'

  select @usergid = usergid, @zbgid = zbgid from system(nolock)
  if (@realcls in ('直配出', '直配出退') and @usergid <> @zbgid)
    and (@realcls in ('直配进', '直配进退') and @usergid = @zbgid)
    return 0

	declare c_edcR cursor for 
	select convert(datetime,convert(varchar(10),o.fildate,102)),
		o.num,o.srcnum,count(d.line),o.src,o.modnum,o.stat,sum(d.total)
	from diralc o (nolock) inner join diralcdtl d(nolock) on o.num = d.num and o.cls = d.cls
	where  o.stat in (1,4,6) 
		and o.cls = @realcls
		and o.fildate between @StartDate and @FinishDate 
		and (o.src<>@usergid and o.src <> 1)
	group by o.fildate,o.num,o.src,o.srcnum,o.modnum,o.stat
	open c_edcR
	fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	while @@Fetch_status = 0
	begin
		if (@stat = 1) or (@stat = 6) 
		begin
		    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
			values (convert(char(10), @fildate, 102),@cls,@srcnum,@reccnt,1,@usergid,@Src,@checkdata1)
		end
		while isnull(@ModNum,'') <> ''
		begin
			select @srcnum = '',@reccnt = 0
			select	@srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
				@stat = o.stat,@checkdata1 = total
			from diralc o(nolock) where num = @modnum and cls = @realcls and stat = 2 and src = @src
			if @@RowCount = 0
			begin
				close c_edcR
				Deallocate c_edcR
				Raiserror('在直配单中根据修正链找不到原始单据，现在单号是%s,类型是%s',16,1,@num)
				return -1
			end
			else
			begin
			    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
				values (convert(char(10), @fildate, 102),@cls,@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)
			end
			select @num = @modnum
		end
 		fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	end
	close c_edcR
	deallocate c_edcR
end
GO
