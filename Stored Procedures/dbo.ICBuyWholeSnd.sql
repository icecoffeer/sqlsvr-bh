SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ICBuyWholeSnd]
  @StartTime datetime,
  @EndTime datetime,
  @Rcv int
as begin
	declare @flowno varchar(12),@posno varchar(10)

	declare cur_icbuywhole cursor for
		select flowno,posno from icbuy1 
		where fildate >=@starttime and fildate < @endtime
	open cur_icbuywhole
	fetch next from cur_icbuywhole into @flowno,@posno
	while @@Fetch_status = 0
	begin
		exec icbuysnd @posno,@flowno,@rcv
		fetch next from cur_icbuywhole into @flowno,@posno
	end
	close cur_icbuywhole
	deallocate cur_icbuywhole
	return 0
end
GO
