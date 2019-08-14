SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECAreaSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)
  
  select @sqlstr = 'insert into earea(code, name) '
    + ' select code, name '
    + ' from area(nolock) '
    + ' where code not in (select code from earea(nolock)) '
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)
  
  return 0  
end
GO
