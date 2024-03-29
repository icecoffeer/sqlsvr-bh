SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_CHKTO11](
  @NUM	CHAR(14),
  @OPER	CHAR(30),
  @CLS	CHAR(10),
  @TOSTAT       INT,
  @MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RE INT

  UPDATE INPRCADJNOTIFY SET STAT = 110 WHERE NUM = @NUM

  IF NOT EXISTS(SELECT 1 FROM INPRCADJNOTIFY WHERE NUM = @NUM AND SNDDATE IS NULL)
  BEGIN
    --发送
    EXEC @RE = INPRCADJNOTIFY_SEND @NUM, @OPER, @CLS, 0, @MSG OUTPUT
    IF @RE <> 0 RETURN @RE
    UPDATE INPRCADJNOTIFYLAC SET PROCSTAT = 0 WHERE NUM = @NUM
    UPDATE INPRCADJNOTIFY SET EXESTAT = 0 WHERE NUM = @NUM
  END

  EXEC INPRCADJNOTIFY_ADDLOG @NUM, @TOSTAT, '作废', @OPER

  SET @MSG = '单据：' + @NUM + '作废成功'

  RETURN 0
END
GO
