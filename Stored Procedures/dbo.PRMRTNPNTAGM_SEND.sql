SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRMRTNPNTAGM_SEND]
(
  @NUM VARCHAR(14),
  @CLS VARCHAR(10),
  @OPER VARCHAR(30),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RET    INT,
    @STORE  INT,
    @STAT   INT,
    @GID    INT

  SET @RET = 0
  SELECT @STAT = STAT FROM PRMRTNPNTAGM(NOLOCK) WHERE NUM = @NUM
  IF @STAT = 0
  BEGIN
    SET @MSG = '未审核单据不能发送'
    RETURN 1
  END
  SELECT @STORE = USERGID FROM FASYSTEM(NOLOCK)
  IF (SELECT COUNT(*) FROM PRMRTNPNTAGMLACSTORE(NOLOCK) WHERE NUM = @NUM) = 1
  BEGIN
    IF (SELECT STOREGID FROM PRMRTNPNTAGMLACSTORE(NOLOCK) WHERE NUM = @NUM) = @STORE
    BEGIN
      SELECT @MSG = '生效单位只有本店，不能发送。'
      RETURN(1)
    END
  END

  DECLARE CDTL CURSOR FOR
    SELECT STOREGID FROM PRMRTNPNTAGMLACSTORE(NOLOCK)
    WHERE NUM = @NUM AND STOREGID <> @STORE

  OPEN CDTL
  FETCH NEXT FROM CDTL INTO @GID
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC @RET = SENDONEPRMRTNPNTAGM @NUM, @STORE, @GID, @MSG OUTPUT
    IF @RET <> 0
    BEGIN
      CLOSE CDTL
      DEALLOCATE CDTL
      RETURN(@RET)
    END
    FETCH NEXT FROM CDTL INTO @GID
  END
  CLOSE CDTL
  DEALLOCATE CDTL

  UPDATE PRMRTNPNTAGM SET SNDTIME = GETDATE() WHERE NUM = @NUM
  EXEC PRMRTNPNTAGM_ADD_LOG @NUM, @TOSTAT, '发送网络单据', @OPER;

  RETURN @RET
END
GO
