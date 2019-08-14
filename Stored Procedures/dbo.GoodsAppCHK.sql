SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GoodsAppCHK]
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
	DECLARE @VACTNAME CHAR(40)
	DECLARE @VSTATNAME CHAR(40)
	DECLARE @EXP DATETIME
	DECLARE @LKNUM VARCHAR(13)
    	SET @VRET = 0;

	SELECT @VSTAT = STAT FROM GoodsApp
	WHERE NUM = @NUM
	IF @@ROWCOUNT = 0
	BEGIN
		SET @MSG = '单据' + @NUM + '不存在'
		RETURN 1
	END
	IF @TOSTAT IN (401)
	BEGIN
	  SELECT @EXP = DEADDATE FROM GoodsApp WHERE NUM = @NUM
	  IF (@EXP IS NOT NULL) AND (@EXP <= CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )
	  BEGIN
	    SET @MSG = '单据' + @NUM + '已经超过到效日期'
	    RETURN 1
	  END
	END
	IF @VSTAT = 0 AND @TOSTAT = 1200  --提交
	BEGIN
	  EXEC @VRET = CHKGoodsApp_0TO1200 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
	IF (@VSTAT = 0 or @VSTAT = 1200) AND @TOSTAT = 401  --请求总部批准
	BEGIN
	  EXEC @VRET = CHKGoodsApp_0TO401 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
    IF @VSTAT = 401 AND @TOSTAT = 1600  -- 预审
	BEGIN
	  EXEC @VRET = CHKGoodsApp_401TO1600 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
	IF @VSTAT = 1600 AND @TOSTAT = 400  --总部批准
	BEGIN
	  EXEC @VRET = CHKGoodsApp_1600TO400 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END
	IF (@VSTAT = 401 or @VSTAT = 1600) AND @TOSTAT = 411  --作废
	BEGIN
	  EXEC @VRET = CHKGoodsApp_40XTO411 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
          RETURN @VRET
    END

	SELECT @VACTNAME = ACTNAME FROM MODULESTAT(NOLOCK) WHERE NO = @TOSTAT
	SELECT @VSTATNAME = STATNAME FROM MODULESTAT(NOLOCK) WHERE NO = @VSTAT
    SET @MSG = '不能' + @VACTNAME + '状态为' + @VSTATNAME + '的商品资料申请单'
    RETURN 1
END
GO