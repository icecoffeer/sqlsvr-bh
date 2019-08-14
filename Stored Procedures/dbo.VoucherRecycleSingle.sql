SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherRecycleSingle]
(
    @num varchar(32),
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE @currentState int;
    declare @vouchertype int;

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

    SELECT @currentState = State, @vouchertype = VOUCHERTYPE FROM Voucher WHERE Num = @num;
    IF  @currentState = 2
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 已经回收，不能再次进行回收。';
        RETURN(1);
    END;
    ELSE IF @currentState <> 4
    BEGIN
        SET @errorMessage = '购物券 ' + @num + ' 的状态不是已发售，不能进行回收。';
        RETURN(1);
    END;

    -- 执行发放。注意，如果执行方是总部，则退券；重置状态。
    -- 否则回收。
    IF (SELECT Property & 16 FROM Store WHERE Gid = @storeGid) = 16
    BEGIN
        -- 总部
                -- 总部回收，不更新回收人和回收单位。
        UPDATE Voucher
        SET State = 0
        WHERE Num = @num;
        -- 插入日志
                DECLARE @msg varchar(256);
                SET @msg =  '退券成功。操作人：' + @operator + '，操作单位：' + CONVERT(varchar(10), @storeGid);
        EXEC VoucherWriteLog @num, @currentState, 0, @operator, @storeGid, @msg;
        SET @errorMessage = NULL;
    END;
    ELSE BEGIN
    UPDATE Voucher
        SET State = 2, RecycleStore = @storeGid, RecycleOperator = @operator,
               RecycleTime = GETDATE()
        WHERE Num = @num;
        -- 插入日志
        EXEC VoucherWriteLog @num, @currentState, 2, @operator, @storeGid, '回收购物券成功。';
        SET @errorMessage = NULL;
    END;
    delete from VOUCHERCASHAUTHOR where NUM = @num
    delete from VOUCHERCASHSTORE where NUM = @num
    delete from VOUCHERCASHSPAN where NUM = @num
    RETURN(0);
END;
GO
