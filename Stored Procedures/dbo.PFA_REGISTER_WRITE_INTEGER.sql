SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_WRITE_INTEGER] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @piValue int                      --返回取值
) as
begin
  declare @nRet int, @sValue varchar(500)
  set @sValue = convert(varchar, @piValue)
  exec @nRet = PFA_REGISTER_WRITE_STR @piValueName, @sValue
  return @nRet
end
GO
