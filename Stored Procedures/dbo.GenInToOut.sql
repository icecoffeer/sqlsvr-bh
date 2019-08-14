SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[GenInToOut]
	@enddate datetime,
	@gid int
as
begin
	declare @id int,
		@fildate datetime,          @num char(10),
		@line smallint,             @firstoutdate datetime,
		@alloutqty money,           @qty money,
		@bckqty money,              @payqty money,
		@allpayqty money

	delete from intoout
	where qty <> bckqty + payqty
	and gdgid = @gid

	/*
	truncate table genintoout_a

	insert into genintoout_a(gdgid)
	select distinct b.gdgid
	from stkin a(nolock), stkindtl b(nolock)
	where a.cls = b.cls
	and a.num = b.num
	and a.stat in (1, 6)
	and a.cls = '自营'
	and b.num + '@' + convert(varchar, b.line)
		not in (select num + '@' + convert(varchar, line) from intoout)
	and b.qty <> b.bckqty
	and b.qty > 0
	and b.gdgid = @gid

	while (select count(*) from genintoout_a(nolock)) > 0
	begin
		select @gdgid = max(gdgid) from genintoout_a(nolock)
	*/

	truncate table genintoout_b

	insert into genintoout_b(fildate, num, line, qty, bckqty, payqty)
	select a.fildate, b.num, b.line, b.qty, b.bckqty, b.payqty
	from stkin a(nolock), stkindtl b(nolock)
	where a.cls = b.cls
	and a.num = b.num
	and a.stat in (1, 6)
	and a.cls = '自营'
	and b.num + '@' + convert(varchar, b.line)
		not in (select num + '@' + convert(varchar, line) from intoout)
	and b.qty <> b.bckqty
	and b.qty > 0
	and b.gdgid = @gid
	order by a.fildate, b.line

	if exists(select * from intoout where gdgid = @gid)
	begin
		select @firstoutdate = max(firstoutdate)
		from intoout(nolock)
		       where gdgid = @gid
	end
	else
		select @firstoutdate = '2000.9.1'

	select @alloutqty = isnull((select sum(dq1 + dq2 - dq5 - dq6)
	from outdrpt(nolock)
	where adate between @firstoutdate and @enddate
	and bgdgid = @gid), 0)

	select @allpayqty = isnull((select sum(payqty)
		from intoout(nolock)
		where firstoutdate = @firstoutdate
		and gdgid = @gid), 0)

	if @alloutqty > @allpayqty
	begin
		select @alloutqty = @alloutqty - @allpayqty
		while @alloutqty > 0 and (select count(*) from genintoout_b(nolock)) > 0
		begin
			select @id = min(id) from genintoout_b(nolock)
			select @fildate = fildate, @num = num, @line = line,
				@qty = qty, @bckqty = bckqty, @payqty = payqty
			from genintoout_b(nolock)
			where id = @id
			if @alloutqty <= @qty - @bckqty
				insert into intoout(num, line, fildate, gdgid, qty, bckqty,
					outqty, payqty, firstoutdate, lastoutdate)
				values(@num, @line, @fildate, @gid, @qty, @bckqty,
					@alloutqty, @payqty, @firstoutdate, @enddate)
			else
				insert into intoout(num, line, fildate, gdgid, qty, bckqty,
					outqty, payqty, firstoutdate, lastoutdate)
				values(@num, @line, @fildate, @gid, @qty, @bckqty,
					@qty - @bckqty, @payqty, @firstoutdate, @enddate)
			select @alloutqty = @alloutqty - (@qty - @bckqty)
			delete from genintoout_b where id = @id
		end
	end
	/*
	delete from genintoout_a where gdgid = @gdgid
	end
	*/
end

GO
