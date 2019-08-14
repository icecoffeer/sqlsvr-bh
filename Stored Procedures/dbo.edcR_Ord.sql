SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[edcR_Ord](
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

	    --定单 
	    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
		select convert(datetime,convert(varchar(10),o.fildate,102)),'定单'
			,srcnum,reccnt,stat,@usergid,o.Src,total
			from ord o(nolock)
		   where  stat =1 and modnum is null
	           and o.fildate between @StartDate and @FinishDate
		   and o.src<>@usergid and o.src = @zbgid

	    declare c_edcR cursor for 
		select convert(datetime,convert(varchar(10),o.fildate,102)),
			o.num,o.srcnum,o.reccnt,o.src,o.modnum,o.stat,o.total
			from ord o (nolock)
		   where  o.stat in (1,4) and o.modnum is not null
	           and o.fildate between @StartDate and @FinishDate 
		   and o.src = @zbgid and o.src<>@usergid
	    open c_edcR
	    fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	    while @@fetch_status = 0
	    begin
		if @stat = 1 
		begin
		    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
			values (convert(char(10), @fildate, 102),'定单',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)
		end
		while isnull(@ModNum,'') <> ''
		begin
			select @srcnum = '',@reccnt = 0
			select @srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
				@stat = o.stat,@checkdata1 = total
			from ord o(nolock) where num = @modnum and stat = 2 and src = @src
			if @@RowCount = 0
			begin
				select @srcnum = o.srcnum,@reccnt = o.reccnt,@modnum = o.modnum,
					@stat = o.stat,@checkdata1 = total
				from ord o(nolock) where srcnum = @modnum and stat = 2 and src = @src
				if @@RowCount <> 0 
				begin
				    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
					values (convert(char(10), @fildate, 102),'定单',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)

				end
				else 
				begin
					select @modnum = ''
				end
			end
			else
			begin
			    insert into RealExchgDataDtl(Recvdate,cls,num,checkint1,checkint2,tgt,src,checkdata1)
				values (convert(char(10), @fildate, 102),'定单',@srcnum,@reccnt,@stat,@usergid,@Src,@checkdata1)
			end

			select @num = @modnum

		end
 		fetch next from c_edcR into @fildate,@num,@srcnum,@reccnt,@src,@modnum,@stat,@checkdata1
	    end
	    close c_edcR
	    deallocate c_edcR
end
GO
