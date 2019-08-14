SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_KEY_EXISTS] (
  @piKey varchar(500)               --指定的键
) as                                --返回值，1-是；0-否。
begin
  declare @sPath varchar(500), @sKey varchar(500)
  
  if rtrim(@piKey) is null return 0
  if rtrim(@piKey) = '\' return 1
  exec PFA_REGISTER_TO_ABSKEY @piKey, @sPath output
  exec PFA_REGISTER_EXTRACT_LASTKEY @sPath, @sPath output, @sKey output
  if exists (select 1 from FAREGISTER
    where FKEY = @sPath and CAPTION = @sKey and FTYPE = 1)
    return 1
  else
    return 0
end
GO
