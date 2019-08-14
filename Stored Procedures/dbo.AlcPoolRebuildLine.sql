SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolRebuildLine](
	@storegid int
)
as
begin
	declare @gdgid int, @baseline int, @line int
	if object_id('c_alcpool_goods') is not null deallocate c_alcpool_goods
	if object_id('c_alcpool_line') is not null deallocate c_alcpool_line
	declare c_alcpool_goods cursor for
	select gdgid from alcpool
	where storegid = @storegid
	for update
	open c_alcpool_goods
	fetch next from c_alcpool_goods into @gdgid
	while @@fetch_status = 0
	begin
		set @baseline = 0

		declare c_alcpool_line cursor for
		select line from alcpool
		where storegid = @storegid and gdgid = @gdgid
		order by line asc
		for update of line
		open c_alcpool_line
		fetch next from c_alcpool_line into @line
		while @@fetch_status = 0
		begin
			set @baseline = @baseline + 1
			update alcpool set line = @baseline
			where current of c_alcpool_line
			fetch next from c_alcpool_line into @line
		end
		close c_alcpool_line
		deallocate c_alcpool_line

		fetch next from c_alcpool_goods into @gdgid
	end
	close c_alcpool_goods
	deallocate c_alcpool_goods

	return (0)
end
GO
