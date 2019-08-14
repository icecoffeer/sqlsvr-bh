SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[VoucherDisposeSingle]
(
    @num varchar(32),
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    END;

    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num AND State = 2 AND Phase = 1)
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 的状态不是已发放且已结算，不能进行销毁。';
        RETURN(1);
    END;

    -- 执行销毁。注意，只有总部可以进行此操作。
    -- 此限制在程序中进行。
    UPDATE Voucher
    SET State = 3, DisposeStore = @storeGid, DisposeOperator = @operator,
           DisposeTime = GETDATE()
    WHERE Num = @num;

    DELETE FROM VOUCHERH where num = @num;
    INSERT INTO VoucherH SELECT * FROM Voucher WHERE Num = @num;
    DELETE FROM Voucher WHERE Num = @num;

    -- 插入日志
    EXEC VoucherWriteLog @num, 2, 3, @operator, @storeGid, '销毁购物券成功。';
    SET @errorMessage = NULL;
    RETURN(0);
END;
GO
