SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[BankRecon_FormatTradeDate](
  @piTradeDate varchar(50)
)
returns varchar(50)
as
begin
  declare
    @vTradeDateDateTime datetime,
    @vTradeDateVarchar varchar(50)
  set @vTradeDateDateTime = convert(datetime, @piTradeDate) --转成时间格式
  set @vTradeDateVarchar = convert(varchar(50), @vTradeDateDateTime, 120) --转成不带毫秒的字符串格式
  set @vTradeDateVarchar = substring(@vTradeDateVarchar, 6, 50) --去掉年份部分
  return @vTradeDateVarchar
end
GO
