SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherCreateWithStartEndNum]
(
    @num varchar(32),
    @type varchar(64),
    @endNum varchar(32),
    @amount decimal(24, 4),
    @operator varchar(30),
	@storeGid int,
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE
        @tailStartNum varchar(10), @headerStartNum varchar(32),
        @tailEndNum varchar(10), @headerEndNum varchar(32);

    IF LEN(@num) <> LEN(@endNum)
    BEGIN
        SET @errorMessage = '起始编号与结束编号长度不一致。';
        RETURN(1);
    END;

    IF @num >= @endNum
    BEGIN
        SET @errorMessage = '起始编号不能小于或等于结束编号。';
        RETURN(1);
    END;

    IF LEN(@num) < 5
    BEGIN
        SET @errorMessage = '编号长度不能小于 5。';
        RETURN(1);
    END;

    -- 由于 NextBn 函数只能产生 5 到 10 位的序号，所以必须根据长度判断
    -- 应该获取 @tailNum 的方式。
    IF LEN(@num) > 10
    BEGIN
        SET @tailStartNum = SUBSTRING(@num, LEN(@num) - 10 + 1, 10);
        SET @headerStartNum = SUBSTRING(@num, 1, LEN(@num) - 10);
        SET @tailEndNum = SUBSTRING(@endNum, LEN(@endNum) - 10 + 1, 10);
        SET @headerEndNum = SUBSTRING(@endNum, 1, LEN(@endNum) - 10);
    END;
    ELSE BEGIN
        SET @tailStartNum = SUBSTRING(@num, LEN(@num) - 5 + 1, 5);
        SET @headerStartNum = SUBSTRING(@num, 1, LEN(@num) - 5);
        SET @tailEndNum = SUBSTRING(@endNum, LEN(@endNum) - 5 + 1, 5);
        SET @headerEndNum = SUBSTRING(@endNum, 1, LEN(@endNum) - 5);
    END;

    -- 要批量生成编号，也规定了结束单号，
    -- 所以结束单号不能包含字母。
    IF @headerStartNum <> @headerEndNum
    BEGIN
        SET @errorMessage = '输入起始编号和结束编号的编号头部不一致。';
        RETURN(1);
    END;

    IF @tailStartNum LIKE '%[^0-9]%' OR @tailEndNum LIKE '%[^0-9]%'
    BEGIN
        SET @errorMessage = '起始编号或结束编号中包含有字母。';
    END;

    -- 循环调用 VoucherCreateSingle 生成购物券
    WHILE @num <> @endNum
    BEGIN
        EXEC VoucherCreateSingle @num, @type, @amount, @operator, @storeGid, @errorMessage OUTPUT;
        IF @errorMessage IS NOT NULL
        BEGIN
            -- 生成时发生了错误
            RETURN(1);
        END;
        -- 没有错误，继续下一次操作。
        EXEC NextBN @tailStartNum, @tailStartNum OUTPUT;
        SET @num = @headerStartNum + @tailStartNum;
    END;

    -- 最后一张尚未生成，生成它。
    EXEC VoucherCreateSingle @num, @type, @amount, @operator, @storeGid, @errorMessage OUTPUT;
    IF @errorMessage IS NOT NULL
    BEGIN
        -- 生成时发生了错误
        RETURN(1);
    END;

    RETURN(0);
END;
GO
