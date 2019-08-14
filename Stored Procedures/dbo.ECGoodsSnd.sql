SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECGoodsSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)
  
  update egoods set flag = 1, lstupdtime = getdate()
  where gid not in (select gid from goods(nolock))
  
  update egoods
  set lstupdtime = goods.lstupdtime
  from goods, egoods where egoods.gid = goods.gid
  
  select @sqlstr = 'insert into egoods(gid, flag, lstupdtime) '
    + ' select gid, 0, lstupdtime '
    + ' from goods(nolock) '
    + ' where gid not in (select gid from egoods(nolock)) '
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)
  
  return 0  
end
GO
