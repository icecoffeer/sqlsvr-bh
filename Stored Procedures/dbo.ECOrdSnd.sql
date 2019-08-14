SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECOrdSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)
  
  select @sqlstr = 'insert into eord(num, flag) '
    + ' select num, 0 '
    + ' from ord(nolock) '
    + ' where num not in (select num from eord(nolock))'
    + ' and stat <> 0 and finished = 0 '
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)

  delete from eord where num in (select eord.num from ord, eord where eord.num = ord.num and ord.finished = 1)

  return 0  
end
GO
