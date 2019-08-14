SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKBLPreOrd_TO100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @STAT INT, @I INT, @SSQL VARCHAR(255), @USERGID INT, @USERPROPERTY INT, 
	        @SRC INT, @PREORDSET VARCHAR(20)
	SELECT @USERGID = USERGID FROM SYSTEM
	SELECT @USERPROPERTY = PROPERTY FROM STORE WHERE GID = @USERGID
	SELECT @PREORDSET = PREORDSET, @STAT = STAT, @SRC = SRC FROM BLPreOrd WHERE NUM = @NUM
	/*IF @USERPROPERTY & 16 <> 16 
	BEGIN
		SET @MSG = '非总部不能审核'
		RAISERROR('非总部不能审核',16,1)
		RETURN(-1)
	END*/
	IF EXISTS(SELECT 1 FROM BLPREORD WHERE STAT IN(1600, 100) AND RTRIM(PREORDSET) = @PREORDSET AND NUM <> @NUM)
	BEGIN
		SET @MSG = '推荐期号被占用。'
		--RAISERROR('非总部不能审核',16,1)
		RETURN(-2)
	END
	UPDATE BLPreOrd SET
		STAT = 100,
		CHKDATE = GETDATE(),
		CHECKER = @OPER,  --审批人
		LSTUPDTIME = GETDATE()
	WHERE NUM = @NUM
	UPDATE BLPreOrdDTL SET FLAG = 1 WHERE NUM = @NUM
	UPDATE BLPreOrdDTL SET FLAG = 2 WHERE NUM <> @NUM AND FLAG = 1
	EXEC BLPreOrdADDLOG @NUM,100,'',@OPER
	RETURN 0
END
GO