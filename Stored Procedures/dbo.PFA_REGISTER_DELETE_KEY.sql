SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_DELETE_KEY] (
  @piKey varchar(500)               --指定的键
) as                                --返回值，0-成功；其它-失败
begin
  declare @sPath varchar(500), @sKey varchar(500)
  
  if @piKey is null or rtrim(@piKey) = '' or rtrim(@piKey) = '\'
    return -1
  exec PFA_REGISTER_TO_ABSKEY @piKey, @sPath output
  delete from FAREGISTER where FKEY like rtrim(@sPath) + '%'
  exec PFA_REGISTER_EXTRACT_LASTKEY @sPath, @sPath output, @sKey output
  delete from FAREGISTER where FKEY = @sPath and CAPTION = @sKey and FTYPE = 1;
  return 0
end
GO
