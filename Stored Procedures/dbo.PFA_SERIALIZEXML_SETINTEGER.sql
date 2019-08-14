SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_SERIALIZEXML_SETINTEGER] (    
  @piKeyName varchar(100),    
  @piKeyValue varchar(100) ,  --int  sunya 080614
  @poResult varchar(200) output    
) as     
BEGIN    
  DECLARE     
    @DEFAULT_TYPE_INTEGER varchar(20)    
  select @DEFAULT_TYPE_INTEGER = ' type="1"'    
      
  if @piKeyName = ''     
    select @poResult = ''    
  ELSE    
  BEGIN    
    select @poResult = convert(varchar(80), @piKeyValue)    
    select @poResult = '<' + @piKeyName + @DEFAULT_TYPE_INTEGER + ' value="' + @poResult + '"/>'    
  END    
  RETURN 0    
end    
  
GO
