SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[BankRecon_GetLiquidatingDate](
  @piTradeDate varchar(50)
)
returns varchar(50)
as
begin
  declare
    @vLiquidatingDateDateTime datetime,
    @vLiquidatingDateVarchar varchar(50)
  set @vLiquidatingDateDateTime = convert(datetime, @piTradeDate) --转成时间格式
  set @vLiquidatingDateVarchar = convert(varchar(50), @vLiquidatingDateDateTime, 112) --转成不带时间和分隔符的字符串格式
  set @vLiquidatingDateVarchar = substring(@vLiquidatingDateVarchar, 5, 50) --去掉年份部分
  return @vLiquidatingDateVarchar
end
GO
