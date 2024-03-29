SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCADJ_CHECK]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @VRET INT, @VSTAT INT

  SET @VRET = 0;

  SELECT @VSTAT = STAT FROM ALCADJ(NOLOCK) WHERE NUM = @NUM
  IF @@ROWCOUNT = 0
  BEGIN
    SET @MSG = '单据' + @NUM + '不存在'
    RETURN 1
  END

  IF @VSTAT = 0 AND @TOSTAT = 100  --审核
  BEGIN
    EXEC @VRET = ALCADJ_CHECK_0TO100 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  SET @MSG = '单据' + @NUM + '操作失败'

  RETURN 2
END
GO
