SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROC [dbo].[NEXTBN2]
    @PINUM   VARCHAR(14),
    @PONUM   VARCHAR(14) OUTPUT
AS
BEGIN
	DECLARE
		@LEN INT 
		,@I INT 
		,@CARRY INT 
		,@NUM VARCHAR(14) 

    SELECT @NUM = REVERSE(RTRIM(SUBSTRING(@PINUM, 5, 10))) 
    SELECT @LEN = LEN(@NUM) 
    SELECT @I = 1 
    SELECT @CARRY = 1 
    WHILE (@CARRY = 1) AND (@I <= @LEN)
    BEGIN
        IF SUBSTRING(@NUM, @I, 1)='Z'  
	BEGIN
            SELECT @NUM = STUFF(@NUM, @I, 1, 'A') 
            SELECT @I = @I + 1 
	END
        ELSE IF SUBSTRING(@NUM, @I, 1)='9'  
	BEGIN
            SELECT @NUM = STUFF(@NUM, @I, 1, '0') 
            SELECT @I = @I + 1 
	END
        ELSE
	BEGIN
            SELECT @NUM = STUFF(@NUM, @I, 1, CHAR(ASCII(SUBSTRING(@NUM, @I, 1)) + 1)) 
            SELECT @CARRY = 0 
        END
    END
    IF @I > @LEN  
    BEGIN
        IF SUBSTRING(@NUM, @LEN, 1)='A'  
            SELECT @NUM = @NUM + 'A' 
        ELSE
            SELECT @NUM = @NUM + '1' 

        SELECT @LEN = @LEN + 1 
    END  
    IF @LEN > 10  
        SELECT @NUM = SUBSTRING(@NUM, 1, 10) 

    SELECT @PONUM = SUBSTRING(@PINUM,1,4) + REVERSE(@NUM) 
    RETURN 0 
END
GO
