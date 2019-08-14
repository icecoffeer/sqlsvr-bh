SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherCreateWithStartNum]
(
    @num varchar(32),
    @type varchar(64),
    @count int,
    @amount decimal(24, 4),
    @operator varchar(30),
	@storeGid int,
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE
        @tailNum varchar(10), @headerNum varchar(32), @i int;

    IF LEN(@num) < 5
    BEGIN
        SET @errorMessage = '编号长度不能小于 5。';
        RETURN(1);
    END;

    -- 由于 NextBn 函数只能产生 5 到 10 位的序号，所以必须根据长度判断
    -- 应该获取 @tailNum 的方式。
    IF LEN(@num) > 10
    BEGIN
        SET @tailNum = SUBSTRING(@num, LEN(@num) - 10 + 1, 10);
        SET @headerNum = SUBSTRING(@num, 1, LEN(@num) - 10);
    END;
    ELSE BEGIN
        SET @tailNum = SUBSTRING(@num, LEN(@num) - 5 + 1, 5);
        SET @headerNum = SUBSTRING(@num, 1, LEN(@num) - 5);
    END;

    -- 循环调用 VoucherCreateSingle 生成购物券
    SET @i = 0
    WHILE @i <> @count
    BEGIN
        EXEC VoucherCreateSingle @num, @type, @amount, @operator, @storeGid, @errorMessage OUTPUT;
        IF @errorMessage IS NOT NULL
        BEGIN
            -- 生成时发生了错误
            RETURN(1);
        END;
        -- 没有错误，继续下一次操作。
        SET @i = @i + 1;
        EXEC NextBN @tailNum, @tailNum OUTPUT;
        SET @num = @headerNum + @tailNum;
    END;

    RETURN(0);
END;
GO
