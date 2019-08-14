SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPFUNC]
(
  @piName sysname
) as
begin
  if exists(select 1 from SYSOBJECTS(nolock) where NAME = @piName and XTYPE = 'FN')
    exec('drop function ' + @piName)
  return(0)
end
GO
