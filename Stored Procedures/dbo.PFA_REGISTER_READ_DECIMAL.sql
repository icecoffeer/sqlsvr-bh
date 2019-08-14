SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PFA_REGISTER_READ_DECIMAL] (
  @piValueName varchar(500),        --值名，可以包含绝对或相对路径
  @poResult decimal(24,4) output,   --返回取值
  @piDefault decimal(24,4) = 0      --默认值
) as
begin
  declare @sDefault varchar(500), @sResult varchar(500)
  
  set @sDefault = convert(varchar, @piDefault)
  exec PFA_REGISTER_READ_STR @piValueName, @sResult output, @sDefault
  set @poResult = convert(decimal(24,4), @sResult)
  return 0
end
GO
