SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_AUTOCHECK](
  @MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @DIFFPROCMETHOD INT,
    @RE INT,
    @NUM CHAR(14)


  DECLARE C_LAC CURSOR FOR
  SELECT NUM, DIFFPROCMETHOD
  FROM INPRCADJNOTIFY(NOLOCK)
  WHERE STAT = 100 AND BGNTIME <= GETDATE()

  OPEN C_LAC
  FETCH NEXT FROM C_LAC INTO
    @NUM, @DIFFPROCMETHOD
  WHILE @@FETCH_STATUS = 0
  BEGIN
    IF @DIFFPROCMETHOD = 0  --一次调整
    BEGIN
      --生效
      EXEC @RE = INPRCADJNOTIFY_CHECK @NUM, '未知[-]', '', 800, @MSG OUTPUT
      IF @RE <> 0 RETURN @RE
      IF NOT EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID = ZBGID)
      BEGIN
        --发送
        EXEC @RE = INPRCADJNOTIFY_SEND @NUM, '', '', 3, @MSG OUTPUT
        IF @RE <> 0 RETURN @RE
      END
    END
    FETCH NEXT FROM C_LAC INTO
      @NUM, @DIFFPROCMETHOD
  END
  CLOSE C_LAC
  DEALLOCATE C_LAC

  SET @MSG = '自动生效成功'

  RETURN 0
END
GO
