SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ECVendorSnd]
  @condstr varchar(255)
as
begin
  declare @sqlstr varchar(800)
  
  update evendor set flag = 1, lstupdtime = getdate()
  where gid not in (select gid from vendor(nolock))
  
  update evendor
  set lstupdtime = vendor.lstupdtime
  from vendor, evendor where evendor.gid = vendor.gid

  select @sqlstr = 'insert into evendor(gid, flag, lstupdtime, addtime) ' 
    + ' select gid, 0, lstupdtime, getdate() '
    + ' from vendor(nolock) '
    + ' where gid not in (select gid from evendor(nolock)) '
  if isnull(@condstr, '') <> ''
    select @sqlstr = @sqlstr + ' and ' + @condstr
  exec(@sqlstr)
  
  return 0  
end
GO
