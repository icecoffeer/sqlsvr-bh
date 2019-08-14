SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolGenBillRollback](
	@rollbackfinished	smallint
)
as
begin
	declare
		@num	char(10),
		@billname	varchar(20),
		@scopeflag	smallint,
		@msg	varchar(255)

	set @scopeflag = 1
	if @rollbackfinished = 1
		set @scopeflag = 2

	if object_id('c_genbills') is not null deallocate c_genbills
	declare c_genbills cursor for
	select billname, num
	from alcpoolgenbills where flag <= @scopeflag
	open c_genbills
	fetch next from c_genbills into @billname, @num
	while @@fetch_status = 0
	begin
		if @billname = '定货单'
		begin
			delete from orddtl where num = @num
			delete from ord where num = @num
			set @msg = '定货单, NUM: ' + @num
			exec AlcPoolWriteLog 2, 'SP:AlcPoolGenBillRollBack', @msg
		end else if @billname = '配货出货单'
		begin
			delete from stkoutdtl where num = @num and cls = '配货'
			delete from stkout where num = @num and cls = '配货'
			set @msg = '配出单, NUM: ' + @num
			exec AlcPoolWriteLog 2, 'SP:AlcPoolGenBillRollBack', @msg
		end else if @billname = '批发单'
		begin
			delete from stkoutdtl where num = @num and cls = '批发'
			delete from stkout where num = @num and cls = '批发'
			set @msg = '批发单, NUM: ' + @num
			exec AlcPoolWriteLog 2, 'SP:AlcPoolGenBillRollBack', @msg
		end else if @billname = '配货通知单'
		begin
			delete from DistNotifyDtl where num = @num
			delete from DistNotify where num = @num
			set @msg = '配货通知单, NUM: ' + @num
			exec AlcPoolWriteLog 2, 'SP:AlcPoolGenBillRollBack', @msg
		end


		fetch next from c_genbills into @billname, @num
	end
	close c_genbills
	deallocate c_genbills

	delete from alcpoolgenbills where flag <= @scopeflag
		and billname in ('定货单', '批发单', '配货出货单','配货通知单')

	return (0)
end
GO
