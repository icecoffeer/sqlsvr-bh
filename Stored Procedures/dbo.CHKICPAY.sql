SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKICPAY]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @VRET INT
	DECLARE @VSTAT INT
	DECLARE @VACTNAME VARCHAR(40)
	DECLARE @VSTATNAME VARCHAR(40)
	DECLARE @EXP DATETIME
	DECLARE @LKNUM VARCHAR(13)
    SET @VRET = 0;	
    
	SELECT @VSTAT = STAT FROM ICPAY
	WHERE NUM = @NUM
	IF @@ROWCOUNT = 0
	BEGIN
		SET @MSG = '单据' + @NUM + '不存在'
		RETURN 1
	END
	IF @VSTAT = 0 AND @TOSTAT = 100
	BEGIN
	  EXEC @VRET = CHKICPAYTO100 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
      RETURN @VRET
    END
	IF @VSTAT = 100 AND @TOSTAT = 600
	BEGIN
	  EXEC @VRET = CHKICPAYTO600 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
      RETURN @VRET
    END
    IF @VSTAT = 100 AND @TOSTAT = 110
	BEGIN
	  EXEC @VRET = CHKICPAYTO110 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
      RETURN @VRET
    END
	SELECT @VACTNAME = ACTNAME FROM MODULESTAT(NOLOCK) WHERE NO = @TOSTAT
	SELECT @VSTATNAME = STATNAME FROM MODULESTAT(NOLOCK) WHERE NO = @VSTAT
    SET @MSG = '不能修改' + @VSTATNAME + '状态为' + @VACTNAME + '的IC卡收款单'
    RETURN 1
END
GO
