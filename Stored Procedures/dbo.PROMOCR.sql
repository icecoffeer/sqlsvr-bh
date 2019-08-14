SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PROMOCR]
(
    @NUM     VARCHAR(14),
    @CLS     VARCHAR(10),
    @OPER     VARCHAR(30),
    @TOSTAT  int,
    @MSG  VARCHAR(255) OUTPUT
)
AS
BEGIN
	declare
    @VRET INT,
    @VSTAT INT

    set @VRET = 0
    SELECT @VSTAT = STAT FROM PROM WHERE NUM = @NUM AND CLS = @CLS
    IF @TOSTAT <> 800 OR @VSTAT <> 0 OR @TOSTAT <= @VSTAT
    begin
      set @MSG = '目标状态不对' + CHAR(@TOSTAT)
      RETURN(1)
    end
    IF @VSTAT = 0
    begin
      exec @VRET = LOADPROMTO50 @CLS, @NUM, @OPER, @MSG output
      IF @VRET <> 0 RETURN(@VRET)
    end
        
    UPDATE PROM
    SET STAT = @TOSTAT, FILDATE = getdate(),
        LSTUPDTIME = getdate()
    WHERE NUM = @NUM AND CLS = @CLS

    INSERT INTO PROMLOG (NUM, CLS, STAT, FILLER, FILDATE)
    VALUES(@NUM, @CLS, 800, @OPER, getdate())

    RETURN(0)      
END
GO
