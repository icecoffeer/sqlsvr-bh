SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[HDDROPTABLE] 
(
  @piName sysname --表名
) as
begin
  declare @vCount int
  if exists(select 1 from SYSOBJECTS(nolock) where NAME = @piName and XTYPE = 'U')
  begin
    if object_id('c_tmp') is not null deallocate c_tmp
    exec('declare c_tmp cursor for select count(1) from [' + @piName + ']')
    open c_tmp
    fetch next from c_tmp into @vCount
    close c_tmp
    deallocate c_tmp
    if @vCount > 0
    begin
      print 'WARNING: HDDROPTABLE表' + @piName + '失败，存在记录'
      return(1)
    end
    exec('drop table [' + @piName + ']')
  end
  return(0)
end
GO
