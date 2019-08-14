SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_DEL] (
  @NUM	CHAR(14),
  @OPER	CHAR(30),
  @CLS	CHAR(10),
  @TOSTAT       INT,
  @MSG	VARCHAR(255) OUTPUT
) AS
BEGIN
  IF (SELECT STAT FROM INPRCADJNOTIFY WHERE NUM = @NUM) <> 0
  BEGIN
    SET @MSG = '单据：' + @NUM + '不是未审核状态'
    RETURN 1
  END
  DELETE FROM INPRCADJNOTIFYDTL WHERE NUM = @NUM
  DELETE FROM INPRCADJNOTIFYLAC WHERE NUM = @NUM
  DELETE FROM INPRCADJNOTIFYBCKDTL WHERE NUM = @NUM
  DELETE FROM INPRCADJNOTIFY WHERE NUM = @NUM
  DELETE FROM INPRCADJNOTIFYLOG WHERE NUM = @NUM
  RETURN 0
END
GO