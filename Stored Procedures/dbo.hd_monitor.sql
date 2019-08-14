SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[hd_monitor] --- 1999/08/19 00:00
@cpu_busy_percent int output,
@io_busy_percent int output,
@idle_percent int output
as

/*
**  Declare variables to be used to hold current monitor values.
*/
declare @now 		datetime
declare @cpu_busy 	int
declare @io_busy	int
declare @idle		int
declare @pack_received	int
declare @pack_sent	int
declare @pack_errors	int
declare @connections	int
declare @total_read	int
declare @total_write	int
declare @total_errors	int

declare @oldcpu_busy 	int	/* used to see if DataServer has been rebooted */
declare @interval	int
declare @mspertick	int	/* milliseconds per tick */

/*
**  If we're in a transaction, disallow this since it might make recovery
**  impossible.
*/
if @@trancount > 0
	begin
		raiserror(15002,-1,-1,'sp_monitor')
		return (1)
	end

/*
**  Set @mspertick.  This is just used to make the numbers easier to handle
**  and avoid overflow.
*/
select @mspertick = convert(int, @@timeticks / 1000.0)

/*
**  Get current monitor values.
*/
select
	@now = getdate(),
	@cpu_busy = @@cpu_busy,
	@io_busy = @@io_busy,
	@idle = @@idle,
	@pack_received = @@pack_received,
	@pack_sent = @@pack_sent,
	@connections = @@connections,
	@pack_errors = @@packet_errors,
	@total_read = @@total_read,
	@total_write = @@total_write,
	@total_errors = @@total_errors

/*
**  Check to see if DataServer has been rebooted.  If it has then the
**  value of @@cpu_busy will be less than the value of spt_monitor.cpu_busy.
**  If it has update spt_monitor.
*/
select @oldcpu_busy = cpu_busy
	from master.dbo.spt_monitor
if @oldcpu_busy > @cpu_busy
begin
	update master.dbo.spt_monitor
		set
			lastrun = @now,
			cpu_busy = @cpu_busy,
			io_busy = @io_busy,
			idle = @idle,
			pack_received = @pack_received,
			pack_sent = @pack_sent,
			connections = @connections,
			pack_errors = @pack_errors,
			total_read = @total_read,
			total_write = @total_write,
			total_errors = @total_errors
end

/*
**  Now print out old and new monitor values.
*/
set nocount on
select @interval = datediff(ss, lastrun, @now)
	from master.dbo.spt_monitor
/* To prevent a divide by zero error when run for the first
** time after boot up
*/
if @interval = 0
	select @interval = 1
select
	@cpu_busy_percent = convert(int, ((((@cpu_busy - cpu_busy)
		* @mspertick) / 1000) * 100) / @interval),
	@io_busy_percent = convert(int, ((((@io_busy - io_busy)
		* @mspertick) / 1000) * 100) / @interval),
	@idle_percent = convert(int, ((((@idle - idle)
		* @mspertick) / 1000) * 100) / @interval)
from master.dbo.spt_monitor

/*
**  Now update spt_monitor
*/
update master.dbo.spt_monitor
	set
		lastrun = @now,
		cpu_busy = @cpu_busy,
		io_busy = @io_busy,
		idle = @idle,
		pack_received = @pack_received,
		pack_sent = @pack_sent,
		connections = @connections,
		pack_errors = @pack_errors,
		total_read = @total_read,
		total_write = @total_write,
		total_errors = @total_errors

return (0) -- sp_monitor

GO
