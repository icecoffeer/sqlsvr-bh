SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_SERIALIZEXML_SETDATETIME] (
  @piKeyName varchar(100),
  @piKeyValue DATETIME,
  @poResult varchar(200) output
) as 
BEGIN
  DECLARE 
    @DEFAULT_TYPE_DATETIME varchar(20)
  select @DEFAULT_TYPE_DATETIME = ' type="3"'
  
  if @piKeyName = '' 
    select @poResult = ''
  ELSE
  BEGIN
    select @poResult = convert(varchar(20), @piKeyValue, 120)
    select @poResult = '<' + @piKeyName + @DEFAULT_TYPE_DATETIME + ' value="' + @poResult + '"/>'
  END
  RETURN 0
end
GO
