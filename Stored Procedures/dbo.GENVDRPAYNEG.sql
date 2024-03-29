SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GENVDRPAYNEG]
(	
	@NUM		CHAR(14),
	@OPER		CHAR(30),
	@NEGNUM		CHAR(14)	OUTPUT,
	@MSG		VARCHAR(255)	OUTPUT
)
AS
BEGIN
	DECLARE @VRET	INT
	DECLARE @VFOUND	INT
	DECLARE @VSETTLENO	INT
	
	EXEC @VSETTLENO = GENNEXTSETTLENO
	IF (@NEGNUM IS NULL) OR EXISTS(SELECT 1 FROM VDRPAY WHERE NUM = @NEGNUM)
	BEGIN
		EXEC @VRET = GENNEXTBILLNUMEX NULL, 'VDRPAY', @NEGNUM OUTPUT
		IF @VRET <> 0 RETURN @VRET
	END
	
	INSERT INTO VDRPAY(NUM, SETTLENO,FILDATE, FILLER, ACNTER, NOTE, STAT, 
		PRNTIME, PAYTOTAL, MODNUM, VGID, LSTUPDTIME, DEPT, STSTORE)
	SELECT @NEGNUM, @VSETTLENO, GETDATE(), @OPER, ACNTER, '作废单据' + @NUM, STAT + 20, 
		NULL, -PAYTOTAL, @NUM, VGID, GETDATE(), DEPT, STSTORE
	FROM VDRPAY WHERE NUM = @NUM

	INSERT INTO VDRPAYDTL(NUM, LINE, CHGNUM, SHOULDPAY, REALPAY, PAYTOTAL, NOPAYTOTAL, NOTE)
	SELECT @NEGNUM, LINE, CHGNUM, -SHOULDPAY, -REALPAY, -PAYTOTAL, -NOPAYTOTAL, NOTE
	FROM VDRPAYDTL WHERE NUM = @NUM
	
	IF @@ERROR <> 0 RETURN @@ERROR

	RETURN 0
END
GO
