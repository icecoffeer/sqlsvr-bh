SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO



create procedure [dbo].[GenCwInv]
	@date datetime,
	@sort varchar(10)
as
begin
	declare @gdgid int,         @qty money,
        	@exists smallint,   @outqty money,
                @noutnin money,     @noutyin money,
                @youtnin money,     @youtyin money,
		@payqty money,      @outbckqty money,
		@inbckqty money,    @maxdate datetime,
		@total money,       @inbcktotal money,
		@noutnintotal money,@noutyintotal money,
		@youtnintotal money,@youtyintotal money,
		@outtotal money,    @outbcktotal money,
		@paytotal money

	truncate table cwinv_gdgid
	insert into cwinv_gdgid(gid)
	select gid
	from goodsh(nolock)
	where sort like @sort

	delete from cwinv
	where date = @date
	and gdgid in (select gid from cwinv_gdgid(nolock))


	insert into cwinv(date, gdgid,
		cnoutnin, cnoutnintotal, 
		cnoutyin, cnoutyintotal, 
		cyoutnin, cyoutnintotal, 
		cyoutyin, cyoutyintotal,
		fnoutnin, fnoutnintotal, 
		fnoutyin, fnoutyintotal, 
		fyoutnin, fyoutnintotal, 
		fyoutyin, fyoutyintotal)
	select @date, gdgid,
		fnoutnin, fnoutnintotal, 
		fnoutyin, fnoutyintotal, 
		fyoutnin, fyoutnintotal, 
		fyoutyin, fyoutyintotal,
		fnoutnin, fnoutnintotal, 
		fnoutyin, fnoutyintotal, 
		fyoutnin, fyoutnintotal, 
		fyoutyin, fyoutyintotal
	from cwinv(nolock)
	where date = dateadd(day, -1, @date)
	and gdgid in (select gid from cwinv_gdgid(nolock))


	/*进货*/
	declare c cursor for
		select bgdgid, sum(dq1), sum(dr1)
		from indrpt(nolock)
		where adate = @date
		and adate <> '2000.9.28'
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
			update cwinv set inqty = inqty + @qty,
					intotal = intotal + @total,
					fnoutnin = fnoutnin + @qty,
					fnoutnintotal = fnoutnintotal + @total
			where date = @date
			and gdgid = @gdgid
		else
		begin
			insert into cwinv(date, gdgid, inqty, intotal, fnoutnin, fnoutnintotal)
			values(@date, @gdgid, @qty, @total, @qty, @total)
		end
		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c

	/*进货退货*/
	declare c cursor for
		select bgdgid, sum(DQ4), sum(dr4)
		from indrpt(nolock)
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
	open c
	fetch next from  c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @inbckqty = inbckqty,
				@inbcktotal = inbcktotal,
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin,
				@noutyintotal = fnoutyintotal,
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock) 
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @inbckqty = 0,
				@inbcktotal = 0,
				@noutnin = 0,
				@noutnintotal = 0,
				@noutyin = 0,
				@noutyintotal = 0,
				@youtnin = 0,
				@youtnintotal = 0,
				@youtyin = 0,
				@youtyintotal = 0
		end
		if @qty <= @noutnin
			select @noutnin = @noutnin - @qty,
				@noutnintotal = @noutnintotal - @total
		else
			select @noutnin = 0, @noutnintotal = 0,
				@noutyin = @noutyin - (@qty - @noutnin),
				@noutyintotal = @noutyintotal - (@total - @noutnintotal)
		if @exists = 1
			update cwinv set inbckqty = inbckqty + @qty,
				inbcktotal = inbcktotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, inbckqty, inbcktotal, 
					fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal)
				values(@date, @gdgid, @qty, @total, 
					@noutnin, @noutnintotal, @noutyin, @noutyintotal)
		fetch next from  c into @gdgid, @qty, @total
	end
	close c
	deallocate c

	/*销售*/
	declare c cursor for
		select bgdgid, sum(dq1 + dq2), sum(dt1 + dt2)
		from outdrpt(nolock) 
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @outqty = outqty,
				@outtotal = outtotal,
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin,
				@noutyintotal = fnoutyintotal,
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock)
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @outqty = 0,
				@outtotal = 0,
				@noutnin = 0,
				@noutnintotal = 0,
				@noutyin = 0,
				@noutyintotal = 0,
				@youtnin = 0,
				@youtnintotal = 0,
				@youtyin = 0,
				@youtyintotal = 0
		end

		if @qty <= @noutyin
			select @noutyin = @noutyin - @qty,
				@noutyintotal = @noutyintotal - @total,
				@youtyin = @youtyin + @qty,
				@youtyintotal = @youtyintotal + @total
		else
			select @youtyin = @youtyin + @noutyin,
				@youtyintotal = @youtyintotal + @noutyintotal,
				@noutnin = @noutnin - (@qty - @noutyin),
				@noutnintotal = @noutnintotal - (@total - @noutyintotal),
				@youtnin = @youtnin + (@qty - @noutyin),
				@youtnintotal = @youtnintotal + (@total - @noutyintotal),
				@noutyin = 0,
				@noutyintotal = 0

		if @exists = 1
			update cwinv set outqty = outqty + @qty,
				outtotal = outtotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal,
				fyoutnin = @youtnin,
				fyoutnintotal = @youtnintotal,
				fyoutyin = @youtyin,
				fyoutyintotal = @youtyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, outqty, outtotal,
				fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal, 
				fyoutnin, fyoutnintotal, fyoutyin, fyoutyintotal)
			values(@date, @gdgid, @qty, @total, 
				@noutnin, @noutnintotal, @noutyin, @noutyintotal, 
				@youtnin, @youtnintotal, @youtyin, @youtyintotal)

		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c

	/*销售退货*/
	
	declare c cursor for
		select bgdgid, sum(dq5 + dq6), sum(dt5 + dt6)
		from outdrpt(nolock) 
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @outbckqty = outbckqty, 
				@outbcktotal = outbcktotal, 
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin, 
				@noutyintotal = fnoutyintotal, 
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock) 
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @outbckqty = 0, @outbcktotal = 0, 
				@noutnin = 0, @noutnintotal = 0,
				@noutyin = 0, @noutyintotal = 0, 
				@youtnin = 0, @youtnintotal = 0,
				@youtyin = 0, @youtyintotal = 0
		end

		if @qty <= @youtnin
			select @youtnin = @youtnin - @qty,
				@youtnintotal = @youtnintotal - @total,
				@noutnin = @noutnin + @qty,
				@noutnintotal = @noutnintotal + @total
		else
			select @noutnin = @noutnin + @youtnin,
				@noutnintotal = @noutnintotal + @youtnintotal,
				@youtyin = @youtyin - (@qty - @youtnin),
				@youtyintotal = @youtyintotal - (@total - @youtnintotal),
				@noutyin = @noutyin + (@qty - @youtnin),
				@noutyintotal = @noutyintotal + (@total - @youtnintotal),
				@youtnin = 0,
				@youtnintotal = 0
		if @exists = 1
			update cwinv set outbckqty = outbckqty + @qty,
				outbcktotal = outbcktotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal,
				fyoutnin = @youtnin,
				fyoutnintotal = @youtnintotal,
				fyoutyin = @youtyin,
				fyoutyintotal = @youtyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, outbckqty, outbcktotal,
				fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal, 
				fyoutnin, fyoutnintotal, fyoutyin, fyoutyintotal)
			values(@date, @gdgid, @qty, @total,
				@noutnin, @noutnintotal, @noutyin, @noutyintotal, 
				@youtnin, @youtnintotal, @youtyin, @youtyintotal)
		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c
	

	/*结算*/
	
	declare c cursor for
		select bgdgid, sum(dq4), sum(dt4)
		from vdrdrpt(nolock) 
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @payqty = payqty,
				@paytotal = paytotal,
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin,
				@noutyintotal = fnoutyintotal,
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock) 
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @payqty = 0,
				@paytotal = 0,
				@noutnin = 0,
				@noutnintotal = 0,
				@noutyin = 0,
				@noutyintotal = 0,
				@youtnin = 0,
				@youtnintotal = 0,
				@youtyin = 0,
				@youtyintotal = 0
		end
		if @qty <= @youtnin
			select @youtnin = @youtnin - @qty,
				@youtnintotal = @youtnintotal - @total,
				@youtyin = @youtyin + @qty,
				@youtyintotal = @youtyintotal + @total
		else
			select @youtyin = @youtyin + @youtnin,
				@youtyintotal = @youtyintotal + @youtnintotal,
				@noutnin = @noutnin - (@qty - @youtnin),
				@noutnintotal = @noutnintotal - (@total - @youtnintotal),
				@noutyin = @noutyin + (@qty - @youtnin),
				@noutyintotal = @noutyintotal + (@total - @youtnintotal),
				@youtnin = 0,
				@youtnintotal = 0

		if @exists = 1
			update cwinv set payqty = payqty + @qty,
				paytotal = paytotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal,
				fyoutnin = @youtnin,
				fyoutnintotal = @youtnintotal,
				fyoutyin = @youtyin,
				fyoutyintotal = @youtyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, payqty, paytotal,
				fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal, 
				fyoutnin, fyoutnintotal, fyoutyin, fyoutyintotal)
			values(@date, @gdgid, @qty, @total,
				@noutnin, @noutnintotal, @noutyin, @noutyintotal, 
				@youtnin, @youtnintotal, @youtyin, @youtyintotal)
		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c


	/*盘点亏*/
        /*
	declare c cursor for
		select bgdgid, abs(sum(DQ2)), abs(sum(dr2))
		from invchgdrpt(nolock)
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
		having sum(DQ2) < 0
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @outqty = outqty,
				@outtotal = outtotal,
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin,
				@noutyintotal = fnoutyintotal,
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock)
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @outqty = 0,
				@outtotal = 0,
				@noutnin = 0,
				@noutnintotal = 0,
				@noutyin = 0,
				@noutyintotal = 0,
				@youtnin = 0,
				@youtnintotal = 0,
				@youtyin = 0,
				@youtyintotal = 0
		end

		if @qty <= @noutyin
			select @noutyin = @noutyin - @qty,
				@noutyintotal = @noutyintotal - @total,
				@youtyin = @youtyin + @qty,
				@youtyintotal = @youtyintotal + @total
		else
			select @youtyin = @youtyin + @noutyin,
				@youtyintotal = @youtyintotal + @noutyintotal,
				@noutnin = @noutnin - (@qty - @noutyin),
				@noutnintotal = @noutnintotal - (@total - @noutyintotal),
				@youtnin = @youtnin + (@qty - @noutyin),
				@youtnintotal = @youtnintotal + (@total - @noutyintotal),
				@noutyin = 0,
				@noutyintotal = 0

		if @exists = 1
			update cwinv set outqty = outqty + @qty,
				outtotal = outtotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal,
				fyoutnin = @youtnin,
				fyoutnintotal = @youtnintotal,
				fyoutyin = @youtyin,
				fyoutyintotal = @youtyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, outqty, outtotal,
				fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal, 
				fyoutnin, fyoutnintotal, fyoutyin, fyoutyintotal)
			values(@date, @gdgid, @qty, @total,
				@noutnin, @noutnintotal, @noutyin, @noutyintotal, 
				@youtnin, @youtnintotal, @youtyin, @youtyintotal)
		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c
        */

	/*损耗*/
	/*
	declare c cursor for
		select bgdgid, abs(sum(DQ1)), abs(sum(dr1))
		from invchgdrpt(nolock)
		where adate = @date
		and bgdgid in (select gid from cwinv_gdgid(nolock))
		group by bgdgid
		having sum(DQ1) < 0
	open c
	fetch next from c into @gdgid, @qty, @total
	while @@fetch_status = 0
	begin
		if exists(select * from cwinv(nolock) where date = @date and gdgid = @gdgid)
		begin
			select @exists = 1
			select @outqty = outqty,
				@outtotal = outtotal,
				@noutnin = fnoutnin,
				@noutnintotal = fnoutnintotal,
				@noutyin = fnoutyin,
				@noutyintotal = fnoutyintotal,
				@youtnin = fyoutnin,
				@youtnintotal = fyoutnintotal,
				@youtyin = fyoutyin,
				@youtyintotal = fyoutyintotal
			from cwinv(nolock)
			where date = @date
			and gdgid = @gdgid
		end
		else
		begin
			select @exists = 0
			select @outqty = 0,
				@outtotal = 0,
				@noutnin = 0,
				@noutnintotal = 0,
				@noutyin = 0,
				@noutyintotal = 0,
				@youtnin = 0,
				@youtnintotal = 0,
				@youtyin = 0,
				@youtyintotal = 0
		end

		if @qty <= @noutyin
			select @noutyin = @noutyin - @qty,
				@noutyintotal = @noutyintotal - @total,
				@youtyin = @youtyin + @qty,
				@youtyintotal = @youtyintotal + @total
		else
			select @youtyin = @youtyin + @noutyin,
				@youtyintotal = @youtyintotal + @noutyintotal,
				@noutnin = @noutnin - (@qty - @noutyin),
				@noutnintotal = @noutnintotal - (@total - @noutyintotal),
				@youtnin = @youtnin + (@qty - @noutyin),
				@youtnintotal = @youtnintotal + (@total - @noutyintotal),
				@noutyin = 0,
				@noutyintotal = 0
		if @exists = 1
			update cwinv set outqty = outqty + @qty,
				outtotal = outtotal + @total,
				fnoutnin = @noutnin,
				fnoutnintotal = @noutnintotal,
				fnoutyin = @noutyin,
				fnoutyintotal = @noutyintotal,
				fyoutnin = @youtnin,
				fyoutnintotal = @youtnintotal,
				fyoutyin = @youtyin,
				fyoutyintotal = @youtyintotal
			where date = @date
			and gdgid = @gdgid
		else
			insert into cwinv(date, gdgid, outqty, outtotal,
				fnoutnin, fnoutnintotal, fnoutyin, fnoutyintotal, 
				fyoutnin, fyoutnintotal, fyoutyin, fyoutyintotal)
			values(@date, @gdgid, @qty, @total,
				@noutnin, @noutnintotal, @noutyin, @noutyintotal, 
				@youtnin, @youtnintotal, @youtyin, @youtyintotal)
		fetch next from c into @gdgid, @qty, @total
	end
	close c
	deallocate c
	*/	
end

GO
