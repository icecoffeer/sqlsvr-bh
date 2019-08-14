SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[inbcktoin]
        @begindate datetime,
	@enddate datetime
as
begin
	declare @id int,                   @num char(10),
		@line int,                 @qty money,
		@inqty money,              @tmpqty money,
		@fildate datetime,         @billto int,
		@gid int,                  @cls char(10),
		@innum char(10),           @inline int

	truncate table inbcktoin_b

	insert into inbcktoin_b(fildate, cls, BILLTO, num, line, gdgid, qty)
	select a.fildate, '自营进退', a.billto, a.num, b.line, b.gdgid, b.qty - b.payqty
	from stkinbck a(nolock), stkinbckdtl b(nolock)
	where a.cls = b.cls
	and a.num = b.num
	and a.cls = '自营'
	and a.stat in (1, 6)
	and a.fildate >= @begindate
	and a.fildate <= dateadd(day, 1, @enddate)
	and b.qty <> b.payqty

	insert into inbcktoin_b(fildate, cls, BILLTO, num, line, gdgid, qty)
	select a.fildate, '自营进', a.billto, a.num, b.line, b.gdgid, abs(b.qty - b.payqty)
	from stkin a(nolock), stkindtl b(nolock)
	where a.cls = b.cls
	and a.num = b.num
	and a.cls = '自营'
	and a.stat in (1, 6)
	and a.fildate >= @begindate
	and a.fildate <= dateadd(day, 1, @enddate)
	and b.qty <> b.payqty
	and b.qty < 0

	declare c cursor for
		select fildate, cls, BILLTO, num, line, gdgid, qty
		from inbcktoin_b
		order by fildate, billto, num, line
	open c
	fetch next from c into @fildate, @cls, @billto, @num, @line, @gid, @qty
	while @@fetch_status = 0
	begin
		truncate table inbcktoin_a
		insert into inbcktoin_a(num, line, qty)
		select a.num, b.line, b.qty - b.payqty - b.bckqty
		from stkin a(nolock), stkindtl b(nolock)
		where a.cls = b.cls
		and a.cls = '自营'
		and a.num = b.num
		and a.stat in (1, 6)
		and a.billto = @billto
		and a.fildate <= @fildate
		and b.gdgid = @gid
		and b.qty <> b.bckqty + b.payqty
		and b.qty > 0
		order by a.fildate, b.line

		while @qty > 0 and (select count(*) from inbcktoin_a) > 0
		begin
			select @id = max(id) from inbcktoin_a
			select @innum = num, @inline = line, @inqty = qty
			from inbcktoin_a
			where id = @id

			if @qty < @inqty
				select @tmpqty = @qty, @inqty = @qty
			else
				select @tmpqty = @inqty

			update stkindtl set bckqty = bckqty + @inqty
			where num = @innum and cls = '自营'
			and line = @inline

			delete from inbcktoin_a
			where id = @id

			select @qty = @qty - @tmpqty

			if @cls = '自营进退'
				update stkinbckdtl set payqty = payqty + @inqty
				where cls = '自营'
				and num = @num
				and line = @line
			else
				update stkindtl set payqty = payqty - @inqty
				where cls = '自营'
				and num = @num
				and line = @line
		end

		if @qty > 0
		begin
			truncate table inbcktoin_a
			insert into inbcktoin_a(num, line, qty)
			select a.num, b.line, b.qty - b.payqty - b.bckqty
			from stkin a(nolock), stkindtl b(nolock)
			where a.cls = b.cls
			and a.cls = '自营'
			and a.num = b.num
			and a.stat in (1, 6)
			and a.billto = @billto
			and a.fildate > @fildate
			and b.gdgid = @gid
			and b.qty <> b.bckqty + b.payqty
			and b.qty > 0
			order by a.fildate, b.line

			while @qty > 0 and (select count(*) from inbcktoin_a) > 0
			begin
				select @id = min(id) from inbcktoin_a
				select @innum = num, @inline = line, @inqty = qty
				from inbcktoin_a
				where id = @id

				if @qty < @inqty
					select @tmpqty = @qty, @inqty = @qty
				else
					select @tmpqty = @inqty

				update stkindtl set bckqty = bckqty + @inqty
				where num = @innum and cls = '自营'
				and line = @inline

				delete from inbcktoin_a
				where id = @id

				select @qty = @qty - @tmpqty

				if @cls = '自营进退'
					update stkinbckdtl set payqty = payqty + @inqty
					where cls = '自营'
					and num = @num
					and line = @line
				else
					update stkindtl set payqty = payqty - @inqty
					where cls = '自营'
					and num = @num
					and line = @line
			end
		end

		fetch next from c into @fildate, @cls, @billto, @num, @line, @gid, @qty
	end
	close c
	deallocate c
end

GO
