SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[AMKTPRCSCHEME_CHECK_0TO100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @RE INT
  UPDATE MKTPRCSCHEME SET
  STAT = 100, CHKDATE = GETDATE(), CHECKER = @OPER, LSTUPDTIME = GETDATE()
  WHERE NUM = @NUM

  EXEC @RE = MKTPRCSCHEME_SEND @NUM, @OPER, NULL, 0, @MSG OUTPUT
  IF @RE <> 0
  BEGIN
    SET @MSG = '单据：' + @NUM + '发送失败'
    RETURN @RE
  END

  SET @MSG = '单据：' + @NUM + '审核成功'

  RETURN 0
END
GO
