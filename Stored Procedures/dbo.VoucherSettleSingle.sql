SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherSettleSingle]
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
        SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    END;

    SELECT @currentState = State FROM Voucher WHERE Num = @num;
    IF  @currentState NOT IN (0, 1, 2)
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 状态不是已制作、已发放或者已回收，不能进行结算。';
        RETURN(1);
    END;

    IF  (SELECT Phase FROM Voucher WHERE Num = @num) = 1
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 已经被结算，不能再次进行结算。';
        RETURN(1);
    END;

    UPDATE Voucher
    SET Phase = 1
    WHERE Num = @num;
    -- 插入日志
    EXEC VoucherWriteLog @num, @currentState, 5, @operator, @storeGid, '结算购物券成功。';
    SET @errorMessage = NULL;

    RETURN(0);
END;
GO
