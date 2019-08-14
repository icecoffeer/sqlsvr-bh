SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[GenChaJia]
	@gdgid int,
	@begindate datetime,
	@enddate datetime
as
begin
	declare @ocrdate datetime,              @total money,
		@qty money,
		@num char(10),                  @line int,
		@gid int
	if @gdgid = -1
		declare c cursor for
			select b.gdgid, convert(datetime, convert(char(10), a.fildate, 102)),
				sum(b.qty), sum((b.newprc - b.oldprc) * b.qty)
			from prcadj a(nolock), prcadjdtl b(nolock)
			where a.cls = b.cls
			and a.num = b.num
			and a.fildate >= @begindate
			and a.fildate <= dateadd(day, 1, @enddate)
			group by b.gdgid, convert(datetime, convert(char(10), a.fildate, 102))
	else
		declare c cursor for
			select @gdgid, convert(datetime, convert(char(10), a.fildate, 102)),
				sum(b.qty), sum((b.newprc - b.oldprc) * b.qty)
			from prcadj a(nolock), prcadjdtl b(nolock)
			where a.cls = b.cls
			and a.num = b.num
			and a.fildate >= @begindate
			and a.fildate <= dateadd(day, 1, @enddate)
			and b.gdgid = @gdgid
			group by convert(datetime, convert(char(10), a.fildate, 102))
	open c
	fetch next from c into @gid, @ocrdate, @qty, @total
	select @num = max(num) from adjinprcchajia(nolock)
	if @num is null
		select @num = '0000000001'
	else
		exec nextbn @num, @num out
	select @line = 0;
	while @@fetch_status = 0
	begin
		select @line = @line + 1
		insert into adjinprcchajia(num, fildate, filler, flag, line, gid, ocrdate, qty, total)
		values(@num, getdate(), 1, 0, @line, @gid, @ocrdate, @qty, @total)
		fetch next from c into @gid, @ocrdate, @qty, @total
	end
	close c
	deallocate c
end

GO
