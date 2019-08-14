SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VDRPAYUPD]
(
	@CLS	  CHAR(20),
	@NUM	  CHAR(14),
	@OPER	  CHAR(30),
	@TOSTAT   INT,
	@MSG 	VARCHAR(255)	OUTPUT
)
AS
BEGIN
	DECLARE @VNEGNUM CHAR(14)
	DECLARE @VRET INT
	DECLARE @VSTAT INT
	DECLARE @VENDSTAT INT
	DECLARE @VMODNUM CHAR(14)

	SELECT @VMODNUM = MODNUM FROM VDRPAY WHERE NUM = @NUM
	SELECT @VSTAT = STAT FROM VDRPAY WHERE NUM = @VMODNUM
	IF @VSTAT <> 500
	BEGIN
		SELECT @MSG = '状态不是已完成，不许修正'
		RETURN 1
	END
	EXEC @VRET = GENVDRPAYNEG @VMODNUM, @OPER, @VNEGNUM OUTPUT, @MSG OUTPUT
	IF @VRET <> 0 RETURN @VRET
	EXEC @VRET = LOADVDRPAYDTL @VNEGNUM, -1, @OPER, @MSG OUTPUT
	IF @VRET <> 0 RETURN @VRET
	UPDATE VDRPAY SET STAT = @VSTAT + 40 WHERE NUM = @VNEGNUM
	SELECT @VENDSTAT = @VSTAT + 40
	EXEC VDRPAYADDLOG '', @VNEGNUM, @VENDSTAT, @OPER
	UPDATE VDRPAY SET 
		STAT = STAT + 10, 
		LSTUPDTIME = GETDATE()
	WHERE NUM = @VMODNUM
	SELECT @VENDSTAT = @VSTAT + 10
	EXEC VDRPAYADDLOG '', @VMODNUM, @VENDSTAT, @OPER
	EXEC @VRET = VDRPAYCHK @CLS, @NUM, @OPER, @TOSTAT, @MSG OUTPUT
	IF @VRET <> 0 RETURN @VRET
	
	IF @CLS IS NULL OR @CLS = ''
	BEGIN
	  EXEC @VRET = VDRPAYSEND @CLS, @NUM, @OPER, 0, @MSG OUTPUT
	  IF @VRET <= 0 SET @VRET = 0
	END
	RETURN @VRET
END
GO
