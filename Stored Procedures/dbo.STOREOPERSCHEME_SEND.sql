SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[STOREOPERSCHEME_SEND]
(
  @CLS VARCHAR(10),
  @NUM VARCHAR(14),
  @OPER VARCHAR(30),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RET INT,
    @VNUM VARCHAR(14),
    @USERGID INT,
    @USERPROPERTY INT,
    @LACSTORE INT,
    @ROWCOUNT INT

  SET @RET = 0
  SELECT @USERGID = USERGID, @USERPROPERTY = USERPROPERTY FROM SYSTEM(NOLOCK)

  SELECT @VNUM = NUM FROM STOREOPERSCHEME(NOLOCK) WHERE NUM = @NUM
  IF @@ROWCOUNT = 0
  BEGIN
    SET @MSG = '门店经营方案单据没有保存。'
    RETURN 1
  END
  IF @USERPROPERTY & 16 <> 16
  BEGIN
    SET @MSG = '非总部不能发送。'
    RETURN 1
  END
  SELECT @LACSTORE = STOREGID FROM SCHEMELAC(NOLOCK) WHERE NUM = @NUM
  SET @ROWCOUNT = @@ROWCOUNT
  IF @ROWCOUNT = 0
  BEGIN
    SET @MSG = '没有选择生效门店。'
    RETURN 1
  END
  ELSE IF @ROWCOUNT = 1 AND @LACSTORE = @USERGID
  BEGIN
    SET @MSG = '生效门店只有本店。'
    RETURN 1
  END

  DECLARE C_SCHEMELAC CURSOR FOR
    SELECT STOREGID FROM SCHEMELAC(NOLOCK)
    WHERE NUM = @NUM
      AND STOREGID <> @USERGID

  OPEN C_SCHEMELAC
  FETCH NEXT FROM C_SCHEMELAC INTO @LACSTORE
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC @RET = SENDONESTORESCHEME @NUM, @USERGID, @LACSTORE, @MSG OUTPUT
    IF @RET <> 0 BREAK
    FETCH NEXT FROM C_SCHEMELAC INTO @LACSTORE
  END
  CLOSE C_SCHEMELAC
  DEALLOCATE C_SCHEMELAC

  IF @RET = 0
    UPDATE STOREOPERSCHEME SET SNDTIME = GETDATE(), LSTUPDTIME = GETDATE(), LSTUPDOPER = @OPER
      WHERE NUM = @NUM
  RETURN @RET
END
GO
