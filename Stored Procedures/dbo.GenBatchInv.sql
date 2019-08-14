SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO


create procedure [dbo].[GenBatchInv]
	@date datetime
as
begin
	create table #a(
                id int identity(1, 1),
                fildate datetime,
                num char(12),
                cls char(10),
                qty money,
                rtlprc money
        )
        
	declare --@begindate datetime,
        	@enddate datetime,
		@gdgid int,                @qty money,
		@tmpdate datetime,
                @id int,
                @tmpqty money
                
	declare c cursor for
		select bgdgid, sum(fq)
		from invdrpt
		where adate = @date
		group by bgdgid
		having sum(fq) > 0
	open c
	fetch next from c into @gdgid, @qty
	while @@fetch_status = 0
	begin
		truncate table #a
		select @tmpdate = dateadd(day, -1, @date)
		while isnull((select sum(qty) from #a), 0) < @qty and @tmpdate >= '2000.9.1'
		begin
			--自营进
			insert into #a(fildate, num, cls, qty, rtlprc)
			select a.fildate, a.num, a.cls, b.qty, b.rtlprc
			from stkin a, stkindtl b
			where a.cls = b.cls
			and a.num = b.num
			and a.cls = '自营'
			and a.stat in (1, 6)
			and a.fildate <= @date
			and a.fildate >= @tmpdate

			--批发退
			insert into #a(fildate, num, cls, qty, rtlprc)
			select a.fildate, a.num, a.cls, b.qty, b.rtlprc
			from stkoutbck a, stkoutbckdtl b
			where a.cls = b.cls
			and a.num = b.num
			and a.cls = '批发'
			and a.stat = 1
			and a.fildate <= @date
			and a.fildate >= @tmpdate

			--零售退
			insert into #a(fildate, num, cls, qty, rtlprc)
			select a.fildate, a.flowno, '零售', b.qty, b.price
			from buy1 a, buy2 b
			where a.posno = b.posno
			and a.flowno = b.flowno
			and b.qty < 0
			and a.fildate <= @date
			and a.fildate >= @tmpdate

			--盘点
			insert into #a(fildate, num, cls, qty, rtlprc)
			select a.ckdate, a.num, '盘点', b.qty - b.acntqty, b.rtlprc
			from ck a, ckdtl b
			where a.num = b.num
			and a.ckdate <= @date
			and a.ckdate >= @tmpdate
			and b.qty >= b.acntqty

			--溢余
			insert into #a(fildate, num, cls, qty, rtlprc)
			select a.fildate, a.num, '溢余', b.qty, b.rtlprc
			from ovf a, ovfdtl b
			where a.num = b.num
			and a.stat = 1
			and a.fildate <= @date
			and a.fildate >= @tmpdate

			select @tmpdate = dateadd(day, -1, @tmpdate)
		end
		while @qty > 0 and (select count(*) from #a) > 0
		begin
			select @tmpdate = max(fildate) from #a
			select @id = (select top 1 id from #a where fildate = @tmpdate)
			select @tmpqty = qty from #a where id = @id
			if @qty < @tmpqty
				select @tmpqty = @qty
			insert into batchinv(date, num, fildate, qty, rtlprc, cls)
			select @date, num, fildate, @tmpqty, rtlprc, cls
			from #a
			where id = @id
			select @qty = @qty - @tmpqty
			delete from #a where id = @id
		end
		fetch next from c into @gdgid, @qty
	end
	close c
	deallocate c

        drop table #a
end

GO
