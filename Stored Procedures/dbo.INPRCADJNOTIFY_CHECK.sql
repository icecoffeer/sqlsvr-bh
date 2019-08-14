SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_CHECK](
  @NUM	CHAR(14),
  @OPER	CHAR(30),
  @CLS	CHAR(10),
  @TOSTAT       INT,
  @MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @STAT INT,
    @VRET INT

  SELECT @STAT = STAT
  FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NUM

  IF @@ROWCOUNT = 0
  BEGIN
    SET @MSG = '单据' + @NUM + '不存在'
    RETURN 1
  END

  IF @STAT = 0 AND @TOSTAT = 100  --审核
  BEGIN
    EXEC @VRET = INPRCADJNOTIFY_CHKTO10 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  IF @STAT = 100 AND @TOSTAT = 800  --生效
  BEGIN
    EXEC @VRET = INPRCADJNOTIFY_CHKTO80 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  IF @STAT = 100 AND @TOSTAT = 110  --作废
  BEGIN
    EXEC @VRET = INPRCADJNOTIFY_CHKTO11 @NUM, @OPER, @CLS, @TOSTAT, @MSG OUTPUT
    RETURN @VRET
  END

  SET @MSG = '单据' + @NUM + '操作失败'

  RETURN 1
END
GO
