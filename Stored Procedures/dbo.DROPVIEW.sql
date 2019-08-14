SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPVIEW](
	@piViewName sysname		--视图名
) as
begin
	declare @sql varchar(255), @tname sysname
	if left(ltrim(@piViewName),1) = '[' and right(rtrim(@piViewName),1) = ']'
		select @tname = substring(@piViewName, 2, len(@piViewName) - 2)
	else
		select @tname = @piViewName, @piViewName = '[' + @piViewName + ']'
	if not exists (select 1 from sysobjects 
		where name = @tname and xtype = 'V')
		return 0
	
	set @sql = 'drop view ' + rtrim(@piViewName)
	exec (@sql)
	
	return 0
end
GO
