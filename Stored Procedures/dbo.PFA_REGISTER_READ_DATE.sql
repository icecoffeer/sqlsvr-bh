SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_READ_DATE] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @poResult datetime output,        --返回取值
  @piDefault datetime = null        --默认值
) as
begin
  declare @sDefault varchar(500), @sResult varchar(500)
  
  set @sDefault = convert(varchar, @piDefault, 120)
  exec PFA_REGISTER_READ_STR @piValueName, @sResult output, @sDefault
  set @poResult = convert(datetime, @sResult)
  return 0
end
GO
