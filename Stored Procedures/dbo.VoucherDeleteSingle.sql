SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherDeleteSingle]
(
    @num varchar(32),
    @operator varchar(30),
	@storeGid int,
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE @currentState int;

    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        SET @errorMessage = '编号为 ' + @num + ' 的购物券不存在。';
        RETURN(0);
    END;

    SELECT @currentState = State FROM Voucher WHERE Num = @num;
    IF @currentState NOT IN (0, 3)
    BEGIN
        SET @errorMessage = '编号为 ' + @num + ' 的购物券状态不是已制作，或已销毁。不能删除。';
        RETURN(1);
    END;

    DELETE FROM Voucher WHERE Num = @num;
    EXEC VoucherWriteLog @num, @currentState, 4, @operator, @storeGid, '已经被成功删除。';
    RETURN(0);
END;
GO
