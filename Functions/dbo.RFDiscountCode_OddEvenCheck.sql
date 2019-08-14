SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create function [dbo].[RFDiscountCode_OddEvenCheck](
  @piBarCode varchar(40) --商品条码
) returns varchar(40)
as
begin
  declare @BarCode varchar(40)
  declare @SumOdd int
  declare @SumEven int
  declare @i int
  
  set @BarCode = isnull(@piBarCode, '')

  if len(@BarCode) > 13
  begin
    if len(@BarCode) < 18
      set @BarCode = replicate('0', 17 - len(@BarCode)) + @BarCode
    else
      set @BarCode = substring(@BarCode, 1, 17)
  end
  else if len(@BarCode) > 8
  begin
    if len(@BarCode) < 13
      set @BarCode = replicate('0', 12 - len(@BarCode)) + @BarCode
    else
      set @BarCode = substring(@BarCode, 1, 12)
  end
  else
  begin
    if len(@BarCode) < 8
      set @BarCode = replicate('0', 7 - len(@BarCode)) + @BarCode
    else
      set @BarCode = substring(@BarCode, 1, 7)
  end
  
  set @BarCode = '0' + @BarCode
  set @SumOdd = 0
  set @SumEven = 0
  set @i = len(@BarCode)
  while @i >= 2
  begin
    set @SumEven = @SumEven + ascii(substring(@BarCode, @i, 1)) - ascii('0')
    set @SumOdd = @SumOdd + ascii(substring(@BarCode, @i - 1, 1)) - ascii('0')
    set @i = @i - 2
  end
  set @BarCode = substring(@BarCode, 2, len(@BarCode)) + char(ascii('0') + (10 - (@SumOdd + @SumEven * 3) % 10) % 10)
  return @BarCode
end
GO
