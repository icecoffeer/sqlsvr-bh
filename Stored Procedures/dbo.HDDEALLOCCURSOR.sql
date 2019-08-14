SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDEALLOCCURSOR]
(
  @piCursorName sysname --游标名
) as
begin
  declare
    @SQL varchar(1000)
  set @SQL = 'if exists(select * from master..syscursors where cursor_name = ''' + @piCursorName + ''')'
    + ' deallocate ' + @piCursorName
  exec(@SQL)
  return(0)
end
GO
