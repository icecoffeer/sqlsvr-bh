SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_SERIALIZEXML_SETSTRING] (
  @piKeyName varchar(100),
  @piKeyValue varchar(1000),
  @poResult varchar(1500) output
) as  
begin
  declare
    @DEFAULT_REPLACE_GREATER varchar(4),
    @DEFAULT_REPLACE_LESSER  VARCHAR(4),
    @DEFAULT_REPLACE_QUOTE VARCHAR(10),
    @DEFAULT_REPLACE_AMP VARCHAR(5),
    @DEFAULT_TYPE_STRING varchar(20)
  select @DEFAULT_REPLACE_GREATER = '&gt;'
  select @DEFAULT_REPLACE_LESSER = '&lt;'
  select @DEFAULT_REPLACE_QUOTE = '&quot'
  select @DEFAULT_REPLACE_AMP = '&amp;'
  select @DEFAULT_TYPE_STRING = ' type= "0"'
  if @piKeyName = '' 
    select @poResult = ''
  else
  begin
    select @poResult = replace(@piKeyValue, '&', @DEFAULT_REPLACE_AMP)
    select @poResult = replace(@poResult, '"', @DEFAULT_REPLACE_QUOTE)
    select @poResult = REPLACE(@poResult, '<', @DEFAULT_REPLACE_LESSER)
    select @poResult = REPLACE(@poResult, '>', @DEFAULT_REPLACE_GREATER)
    select @poResult = '<' + @piKeyName + @DEFAULT_TYPE_STRING + ' value="' + @poResult + '"/>'
  END
  return 0
end
GO
