SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE FUNCTION [dbo].[PrmOffsetGetLacStores]
(
    @num varchar(14)
) RETURNS VARCHAR(256)
AS
BEGIN
    DECLARE c CURSOR FOR
    SELECT StoreGid FROM PrmOffsetLacDtl WHERE Num = @num;
    DECLARE @returnValue varchar(256), @c_gid int, @currentStore varchar(256);

    OPEN c;
    FETCH NEXT FROM c INTO @c_gid;
    SET @returnValue = '';
    WHILE @@FETCH_STATUS = 0
    BEGIN
        SELECT @currentStore = RTRIM(s.Name) + '[' + RTRIM(s.Code) + ']'
        FROM PrmOffsetLacDtl AS d, Store AS s
        WHERE d.StoreGid = s.Gid AND d.Num = @num AND d.StoreGid = @c_gid;

        SET @returnValue = @returnValue + @currentStore + '; ';
        FETCH NEXT FROM c INTO @c_gid;
    END;
    CLOSE c;
    DEALLOCATE c;
    RETURN @returnValue;
END
GO
