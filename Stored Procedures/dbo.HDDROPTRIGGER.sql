SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPTRIGGER]
(
  @piName sysname --触发器名
) as
begin
  if exists(select 1 from SYSOBJECTS where NAME = @piName and XTYPE = 'TR')
    exec('drop trigger ' + @piName)
  return(0)
end
GO
