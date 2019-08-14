SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDFORCEDROPTABLE]
(
  @piName sysname --表名
) as
begin
  if exists(select 1 from SYSOBJECTS(nolock) where NAME = @piName and XTYPE = 'U')
  begin
    exec('drop table [' + @piName + ']')
    print 'HINT: HDFORCEDROPTABLE表' + @piName + '成功'
  end
  return(0)
end
GO
