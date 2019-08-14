SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VDRPAYCHK]
(
	@CLS	  CHAR(20),
	@NUM	  CHAR(14),
	@OPER	  CHAR(30),
	@TOSTAT  INT,
	@MSG	VARCHAR(255)	OUTPUT
)
AS
BEGIN
	DECLARE @VRET INT
	DECLARE @SETTLENO INT
	EXEC @VRET = LOADVDRPAYDTL @NUM, 1, @OPER, @MSG OUTPUT
	IF @VRET <> 0 RETURN @VRET
	EXEC @SETTLENO = GENNEXTSETTLENO
	UPDATE VDRPAY SET 
		SETTLENO = @SETTLENO, 
		FILDATE = GETDATE(), 
		FILLER = @OPER, 
		STAT = 500
	 WHERE NUM = @NUM
	EXEC VDRPAYADDLOG '', @NUM, 500, @OPER
	
	IF @CLS IS NULL OR @CLS = ''
	BEGIN
	  EXEC @VRET = VDRPAYSEND @CLS, @NUM, @OPER, 0, @MSG OUTPUT
	  IF @VRET <= 0 SET @VRET = 0
	END
	
	RETURN @VRET
END
GO
