SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_SERIALIZEXML_SETDECIMAL] (
  @piKeyName varchar(100),
  @piKeyValue money,
  @poResult varchar(200) output
) as 
BEGIN
  DECLARE 
    @DEFAULT_TYPE_DECIMAL varchar(20)
  select @DEFAULT_TYPE_DECIMAL = ' type="2"'
  
  if @piKeyName = '' 
    select @poResult = ''
  ELSE
  BEGIN
    select @poResult = convert(varchar(80), @piKeyValue)
    select @poResult = '<' + @piKeyName + @DEFAULT_TYPE_DECIMAL + ' value="' + @poResult + '"/>'
  END
  RETURN 0
end
GO
