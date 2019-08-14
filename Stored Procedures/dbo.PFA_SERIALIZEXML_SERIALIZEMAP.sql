SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_SERIALIZEXML_SERIALIZEMAP] (
  @piTagName varchar(20),
  @piMapCtx varchar(1500),
  @poResult varchar(2100) output
) as 
BEGIN
  declare 
    @XmlTagEnd varchar(20),
    @XmlTagHead varchar(20),
    @DEFAULT_XML_HEAD VARCHAR(50)
  if (@piTagName = '' ) -- 2008-01-14 - zhuhaohui, 序列化参数时，只有TAG为空时，才返回空
    select @poResult = ''
  else
  begin
    select @DEFAULT_XML_HEAD = '<?xml version="1.0" encoding="GBK"?>'
    select @XmlTagHead = '<' + @piTagName + '>';
    select @XmlTagEnd = '</' + @piTagName + '>';
    select @poResult = @DEFAULT_XML_HEAD + @XmlTagHead + @piMapCtx + @XmlTagEnd
  END
  return 0
END
GO
