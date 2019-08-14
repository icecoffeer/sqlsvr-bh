SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherDisposeWithStartEndDate]
(
    @startDate datetime,
    @endDate datetime,
    @storeGid int,
    @operator varchar(30),
    @errorMessage varchar(256) OUTPUT
) AS
BEGIN
    DECLARE @c_num varchar(32);
    DECLARE c_num CURSOR FOR SELECT Num FROM Voucher WHERE RecycleTime BETWEEN @startDate AND @endDate;

    OPEN c_num;
    FETCH NEXT FROM c_num INTO @c_num;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC VoucherDisposeSingle @c_num, @storeGid, @operator, @errorMessage OUTPUT;
        IF @errorMessage IS NOT NULL
        BEGIN
            -- 生成时发生了错误
            -- 目前项目要求发生错误就中断操作。
            CLOSE c_num;
            DEALLOCATE c_num;
            RETURN (1);
        END
        FETCH NEXT FROM c_num INTO @c_num;
    END;

    CLOSE c_num;
    DEALLOCATE c_num;
    RETURN(0);
END;
GO
