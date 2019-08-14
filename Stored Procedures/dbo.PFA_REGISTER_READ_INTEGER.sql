SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_READ_INTEGER] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @poResult int output,             --返回取值
  @piDefault int = 0                --默认值
) as
begin
  declare @sDefault varchar(500), @sResult varchar(500)
  
  set @sDefault = convert(varchar, @piDefault)
  exec PFA_REGISTER_READ_STR @piValueName, @sResult output, @sDefault
  set @poResult = convert(int, @sResult)
  return 0
end
GO
