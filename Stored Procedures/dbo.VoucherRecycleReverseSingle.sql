SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherRecycleReverseSingle]
(
    @num varchar(32),
    @operator varchar(30),
        @storeGid int,
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

    IF NOT EXISTS(SELECT 1 FROM Voucher WHERE Num = @num AND State = 2)
    BEGIN
        SET @errorMessage = '需要处理的购物券 ' + @num + ' 的状态不是已回收，不能进行回收错误修正。';
        RETURN(1);
    END;

    EXEC @ret = VoucherCheckInLmtScope @num, @errormessage output
    if @ret <> 0 return(@ret)

    -- 记录
    UPDATE Voucher
    SET State = 1, RecycleOperator = NULL, RecycleStore = NULL, RecycleTime = NULL, ReceiveOperator = @operator,
           ReceiveTime = GETDATE()
    WHERE Num = @num;

    -- 插入日志
    EXEC VoucherWriteLog @num, 2, 1, @operator, @storeGid, '购物券回收错误修正处理成功。';
    SET @errorMessage = NULL;
    RETURN(0);
END;
GO
