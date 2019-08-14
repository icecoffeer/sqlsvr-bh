SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_WRITE_DATE] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @piValue datetime                 --返回取值
) as
begin
  declare @nRet int, @sValue varchar(500)
  set @sValue = convert(varchar, @piValue, 120)
  exec @nRet = PFA_REGISTER_WRITE_STR @piValueName, @sValue
  return @nRet
end
GO
