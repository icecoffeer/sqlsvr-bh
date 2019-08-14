SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherGetNextExistNum]
(
    @num varchar(32),
    @nextNum varchar(32) OUTPUT
) AS
BEGIN
    SET @nextNum = NULL;
    SELECT TOP 1 @nextNum = Num FROM Voucher WHERE Num > @num ORDER BY Num ASC;
    RETURN(0);
END;
GO
