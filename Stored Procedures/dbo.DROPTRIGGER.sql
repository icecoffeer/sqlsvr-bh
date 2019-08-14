SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPTRIGGER](
	@piTriggerName sysname		--触发器名
) as
begin
	declare @sql varchar(255), @tname sysname
	if left(ltrim(@piTriggerName),1) = '[' and right(rtrim(@piTriggerName),1) = ']'
		select @tname = substring(@piTriggerName, 2, len(@piTriggerName) - 2)
	else
		select @tname = @piTriggerName, @piTriggerName = '[' + @piTriggerName + ']'
	if not exists (select 1 from sysobjects 
		where name = @tname and xtype = 'TR')
		return 0
	
	set @sql = 'drop trigger ' + rtrim(@piTriggerName)
	exec (@sql)
	
	return 0
end
GO
