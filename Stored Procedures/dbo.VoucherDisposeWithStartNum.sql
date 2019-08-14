SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherDisposeWithStartNum]
(
    @num varchar(32),
    @count int,
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE
        @i int, @errorCount int;

    IF LEN(@num) < 5
    BEGIN
        SET @errorMessage = '编号长度不能小于 5。';
        RETURN(1);
    END;

    -- 循环调用 VoucherReceiveSingle 处理
    SET @i = 0;
    SET @errorCount = 0;
    WHILE (@i <> @count) AND (@num IS NOT NULL)
    BEGIN
        EXEC VoucherDisposeSingle @num, @storeGid, @operator, @errorMessage OUTPUT;
        IF @errorMessage IS NOT NULL
        BEGIN
            -- 生成时发生了错误
            -- 目前项目要求发生错误就中断操作。
            RETURN (1);
            SET @errorCount = @errorCount + 1;
        END
        ELSE BEGIN
            -- 继续下一次操作。
            SET @i = @i + 1;
        END;

        EXEC VoucherGetNextExistNum @num, @num OUTPUT;
    END;

    IF @errorCount <> 0
        SET @errorMessage = '成功发放了购物券，但仍有 ' + CONVERT(varchar(16), @errorCount) + ' 张购物券没有处理成功。原因可能是这些购物券不存在，或状态不是已制作。详细信息： ' + @errorMessage;
    RETURN(0);
END;
GO
