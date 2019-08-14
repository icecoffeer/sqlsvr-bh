SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPVIEW]
(
  @piName sysname --视图名
) as
begin
  if exists(select 1 from SYSOBJECTS where NAME = @piName and XTYPE = 'V')
    exec('drop view ' + @piName)
  return(0)
end
GO
