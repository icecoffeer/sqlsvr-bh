SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECGdStoreSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)

  update egdstore set flag = 1, lstupdtime = getdate()
  where not exists(select 1 from gdstore(nolock)
    where gdstore.storegid = egdstore.storegid
    and gdstore.gdgid = egdstore.gdgid)
      
  select @sqlstr = 'insert into egdstore(storegid, gdgid, flag, lstupdtime) '
    + ' select storegid, gdgid, 0, getdate() '
    + ' from gdstore(nolock) '
    + ' where not exists(select 1 from egdstore(nolock) '
    + '   where egdstore.storegid = gdstore.storegid '
    + '   and egdstore.gdgid = gdstore.gdgid)'
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)
  
  return 0  
end
GO
