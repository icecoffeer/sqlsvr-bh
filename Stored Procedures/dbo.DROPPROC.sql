SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DROPPROC](
	@piProcName sysname		--存储过程名
) as
begin
	declare @sql varchar(255), @tname sysname
	if left(ltrim(@piProcName),1) = '[' and right(rtrim(@piProcName),1) = ']'
		select @tname = substring(@piProcName, 2, len(@piProcName) - 2)
	else
		select @tname = @piProcName, @piProcName = '[' + @piProcName + ']'
	if not exists (select 1 from sysobjects 
		where name = @tname and xtype = 'P')
		return 0
	
	set @sql = 'drop procedure ' + rtrim(@piProcName)
	exec (@sql)
	
	return 0
end
GO
