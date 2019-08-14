SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherReceiveSingle]
(
    @num varchar(32),
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    declare
      @ret int
    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num)
    BEGIN
        SET @errorMessage = '当前数据库中不存在编号为 ' + @num + ' 的购物券。';
        RETURN(1);
    END;

    IF NOT EXISTS(SELECT 1 FROM Store WHERE Gid = @storeGid)
    BEGIN
        SET @errorMessage = '编号为 ' + CONVERT(varchar(16), @storeGid) + ' 的门店不存在。';
        RETURN(1);
    END;

    IF (SELECT State FROM Voucher WHERE Num = @num) <> 0
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 的状态不是已制作，不能进行发放。';
        RETURN(1);
    END;

    EXEC @ret = VoucherCheckInLmtScope @num, @errormessage output
    if @ret <> 0 return(@ret)

    -- 执行发放。注意，只有总部可以进行此操作。
    -- 此限制在程序中进行。
    UPDATE Voucher
    SET State = 1, ReceiveStore = @storeGid, ReceiveOperator = @operator,
           ReceiveTime = GETDATE()
    WHERE Num = @num;

    -- 插入日志
    EXEC VoucherWriteLog @num, 0, 1, @operator, @storeGid, '发放购物券成功。';
    SET @errorMessage = NULL;
    RETURN(0);
END;
GO
