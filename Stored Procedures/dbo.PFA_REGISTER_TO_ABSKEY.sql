SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_TO_ABSKEY] (
  @piKey varchar(500),
  @poResult varchar(500) output
) as
begin
  declare @sPath varchar(500), @sCurrKey varchar(500)
  
  set @sPath = rtrim(@piKey);
  if substring(@sPath, 1, 1) <> '\'
  begin
    exec PFA_REGISTER_GET_CURRENTKEY @sCurrKey output
    set @sPath = @sCurrKey + @sPath
  end
  if substring(@sPath, len(@sPath), 1) <> '\'
    set @sPath = @sPath + '\'
  set @poResult = @sPath
  return 0
end
GO
