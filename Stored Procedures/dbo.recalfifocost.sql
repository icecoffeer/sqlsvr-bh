SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[recalfifocost] 
	@date datetime
as begin
declare 
	@yestoday datetime, 	@curdate datetime,	@settleno int,
	@ret int

	select @yestoday = dateadd(day, -1, convert(datetime, convert(char(10), getdate(), 102)))
	if @date > @yestoday 
		raiserror('开始日期不能大于昨天', 16, 1)
	else 
    begin
	set nocount on
        truncate table fifolog
	begin transaction
	insert into fifolog values(getdate(), @date,
	'开始重算' + rtrim(convert(char(10), @date, 102)) + '到昨天为止的财务进销存报表')

	delete fifo_stkinv
	from stkin
	where stkin.cls = fifo_stkinv.cls
	and stkin.num = fifo_stkinv.num
	and stkin.fildate >= @date

	delete from fifo_Stkinv
	from diralc
	where diralc.cls = fifo_stkinv.cls
	and diralc.num = fifo_stkinv.num
	and diralc.cls = '直配进'
	and diralc.fildate >= @date

	create table #t_i(cls char(10), num char(10))

	insert into #t_i(cls, num)
	select cls, modnum from stkin
	where fildate >= @date and fildate < dateadd(day, 1, @yestoday)
    	and modnum is not null and stat in (1, 4, 6)

	insert into #t_i(cls, num)
	select cls, modnum from diralc
	where fildate >= @date and fildate < dateadd(day, 1, @yestoday)
    	and modnum is not null and stat in (1, 4, 6)

	delete from #t_i
	from fifo_stkinv
	where #t_i.cls = fifo_stkinv.cls
	and #t_i.num = fifo_stkinv.num

	insert fifo_stkinv(gdgid, Ocrdate, qty, price, Cls, Num, dateid)
	select b.gdgid, a.Ocrdate, b.qty, b.price, a.cls, a.num,
		convert(char(8), a.ocrdate, 112) + rtrim(b.cls) + rtrim(b.num)
		+ right('0000' + rtrim(convert(char(4), b.line)),4)
	from stkin a(NOLOCK), stkindtl b(NOLOCK), goodsh c(nolock), #t_i
	where #t_i.cls = a.cls and #t_i.num = a.num
		and a.cls = b.cls
		and a.num = b.num
		and b.gdgid = c.gid
		and a.stat = 2
		and a.fildate < @date

	insert fifo_stkinv(gdgid, Ocrdate, qty, price, Cls, Num, dateid)
	select b.gdgid, a.Ocrdate, b.qty, b.price, a.cls, a.num,
		convert(char(8), a.ocrdate, 112) + rtrim(b.cls) + rtrim(b.num) 
		+ right('0000' + rtrim(convert(char(4), b.line)),4)
	from diralc a(NOLOCK), diralcdtl b(NOLOCK), goodsh c(nolock), #t_i
	where #t_i.cls = a.cls and #t_i.num = a.num
		and #t_i.cls = '直配进'
		and a.cls = b.cls
		and a.num = b.num
		and b.gdgid = c.gid
		and a.stat = 2
		and a.fildate < @date

	insert into fifolog values(getdate(), @date,
	'调整' + rtrim(convert(char(10), @date, 102)) + '进货先进先出队列成功')
	commit transaction

	select @ret = 0, @curdate = @date
	while @curdate <= @yestoday
	begin
		begin transaction
		select @settleno = max(no) from monthsettle 
		where convert(datetime, convert(char(10), begindate, 102)) <= @curdate
		and convert(datetime, convert(char(10), enddate, 102)) >= @curdate
		delete from fifocostcheck where adate = @curdate
		exec @ret = fifocost @settleno, @curdate, 1
		if @ret <> 0 begin
			rollback transaction
			break
		end
		insert into fifolog values(getdate(), @curdate,
		'重算' + rtrim(convert(char(10), @curdate, 102)) + '进销存表成功')
		select @curdate = dateadd(day, 1, @curdate)
		commit transaction
	end
	if @ret <> 0 begin
		raiserror('计算先进先出失败', 16, 1)
		return 1
	end
    end
end


GO
