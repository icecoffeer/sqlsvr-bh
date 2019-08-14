SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherCheckInLmtScope]
(
   @num varchar(32),
   @errorMessage varchar(256) OUTPUT
) AS
BEGIN
  declare
    @numScope int,
    @numScopeLow varchar(32),
    @numScopeHigh varchar(32),
    @flag int --0为随机券，1为常规券，为振华定制  
  EXEC OptReadInt 0, 'VouNumScopeOn', 0, @numScope OUTPUT;
  IF @numScope = 1
  BEGIN
    if exists(select 1 from voucherbckstgrcvdtl2 where vouchernum = @num)
      select @flag = 0
    else
      select @flag = 1
    EXEC OptReadStr 0, 'VouNumScopeLow', '', @numScopeLow OUTPUT;
    EXEC OptReadStr 0, 'VouNumScopeHigh', '', @numScopeHigh OUTPUT;
    if @flag = 0
    begin
      if @num < @numScopeLow or @num > @numScopeHigh
      begin
        SET @errorMessage = '请求处理的购物券编号 ' + @num + ' 超出了随机赠券的规定范围(' + @numScopeLow + ' - ' + @numScopeHigh + ')。';
        RETURN(1);
      end
    end
    else
    begin
      if @num >= @numScopeLow and @num <= @numScopeHigh
      begin
        SET @errorMessage = '请求处理的购物券编号 ' + @num + ' 不应该落在随机赠券的规定范围内(' + @numScopeLow + ' - ' + @numScopeHigh + ')。';
        RETURN(1);
      end
    end
  END
  else
    return 0
END
GO
