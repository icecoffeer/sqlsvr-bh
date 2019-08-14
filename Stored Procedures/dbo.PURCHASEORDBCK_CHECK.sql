SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PURCHASEORDBCK_CHECK]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @VRET INT,     @VSTAT INT

  SET @VRET = 0;

  SELECT @VSTAT = STAT FROM PURCHASEORDER(NOLOCK)
  WHERE NUM = @NUM AND CLS = @CLS
  IF @@ROWCOUNT = 0
  BEGIN
    SET @MSG = '单据' + @NUM + '不存在'
    RETURN 1
  END

  IF @VSTAT = 0 AND @TOSTAT = 100
  BEGIN
    EXEC @VRET = PURCHASEORDBCK_CHECK_0TO100 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  IF @VSTAT = 100 AND @TOSTAT = 3200
  BEGIN
    EXEC @VRET = PURCHASEORDBCK_CHECK_100TO3200 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  IF @VSTAT = 100 AND @TOSTAT = 3300
  BEGIN
    EXEC @VRET = PURCHASEORDBCK_CHECK_100TO3300 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  IF @VSTAT = 3300 AND @TOSTAT = 3200
  BEGIN
    EXEC @VRET = PURCHASEORDBCK_CHECK_100TO3200 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  SET @MSG = '单据' + @NUM + '操作失败'

  RETURN 2
END
GO