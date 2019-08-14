SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RepairBuyEx](
	@p_database varchar(30) = 'hd31buypool'
) as
begin
	set nocount on
	declare @posno char(10)
	declare cc_pos cursor for 
		select no from workstation where style = 0 and npcnt <> 0
		order by no
	open cc_pos
	fetch next from cc_pos into @posno
	while @@fetch_status=0
	begin
		exec repairbuy @p_database, @posno
		select 'RepairBuy ' + @posno
		fetch next from cc_pos into @posno
	end
	close cc_pos
	deallocate cc_pos
end
GO
