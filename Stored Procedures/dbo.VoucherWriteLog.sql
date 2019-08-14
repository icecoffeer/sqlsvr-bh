SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VoucherWriteLog]
(
    @num varchar(32),
    @fromState int,
    @toState int,
    @operator varchar(30),
	@storeGid int,
    @note varchar(256)
) AS
BEGIN
    INSERT INTO VoucherLog(Num, FromState, ToState, Creator, CreateTime, StoreGid, Note)
    VALUES(@num, @fromState, @toState, @operator, GETDATE(), @storeGid, @note)
    RETURN(0);
END;
GO
