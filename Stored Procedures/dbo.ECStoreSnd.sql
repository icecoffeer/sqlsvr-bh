SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECStoreSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)

  update estore set flag = 1, lstupdtime = getdate()
  where gid not in (select gid from store(nolock))
  
  select @sqlstr = 'insert into estore(gid, flag, lstupdtime) '
    + ' select gid, 0, getdate() '
    + ' from store(nolock) '
    + ' where gid not in (select gid from estore(nolock)) '
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)
  
  return 0  
end
GO
