SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[RCVONESTORESCHEME]
(
  @SRC INT,
  @ID INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @RET INT,
    @USERGID INT,
    @ZBGID INT,
    @NUM VARCHAR(14),
    @RCV INT,
    @CUR_SETTLENO INT,
    @TYPE INT,
    @CNT INT,
    @N_NUM VARCHAR(14)

  SET @RET = 0
  SELECT @USERGID = USERGID, @ZBGID = ZBGID FROM FASYSTEM(NOLOCK)
  SELECT @CUR_SETTLENO = MAX(NO) FROM MONTHSETTLE
  SELECT @NUM = NUM, @RCV = RCV
  FROM NSTOREOPERSCHEME(NOLOCK) WHERE SRC = @SRC AND ID = @ID

  IF @USERGID = @ZBGID
  BEGIN
    SET @MSG = '总部不能接收门店经营方案。'
    EXEC NSTORESCHEME_REMOVE @SRC, @ID
    RETURN 0
  END

  IF @SRC <> @ZBGID
  BEGIN
    SET @MSG = '来源单位不是总部。'
    EXEC NSTORESCHEME_REMOVE @SRC, @ID
    RETURN 0
  END

  IF @RCV <> @USERGID
  BEGIN
    SET @MSG = '收到发送给其他单位的门店经营方案。'
    EXEC NSTORESCHEME_REMOVE @SRC, @ID
    RETURN 0
  END

  select @TYPE = TYPE from NSTOREOPERSCHEME(nolock) where SRC = @SRC and ID = @ID
  if @@ROWCOUNT < 1
  BEGIN
    SET @MSG = '未找到指定网络门店经营方案。'
    UPDATE NSTOREOPERSCHEME SET NSTAT = 1, NNOTE = @MSG WHERE SRC = @SRC and ID = @ID
    RETURN 1
  end;
  if @TYPE <> 1
  begin
    SET @MSG = '不是可接收单据'
    update NSTOREOPERSCHEME set NSTAT = 1,NNOTE = @MSG WHERE SRC = @SRC and ID = @ID
    RETURN 1
  end
  select @CNT = SUM(CASE WHEN X.LGID IS NULL THEN 1 ELSE 0 END)
    from NSTORESCHSORTGOODS N, GDXLATE X
    WHERE N.ID = @ID AND
      N.GDGID *= X.NGID
  if @CNT > 0
  BEGIN
    SET @MSG = '本地未包含商品资料'
    UPDATE NSTOREOPERSCHEME SET NSTAT = 1, NNOTE = @MSG WHERE SRC = @SRC and ID = @ID
    RETURN 1
  end
  SELECT @N_NUM = NUM FROM NSTOREOPERSCHEME(nolock) WHERE SRC = @SRC and ID = @ID
  IF EXISTS(SELECT 1 FROM STOREOPERSCHEME(nolock) WHERE NUM = @N_NUM)
  BEGIN
    SET @MSG = '该单据已被接收过,不允许重复接收'
    UPDATE NSTOREOPERSCHEME SET NSTAT = 1, NNOTE = @MSG WHERE SRC = @SRC and ID = @ID
    RETURN 1
  END

  --插入到当前表中
  EXEC @RET = STOREOPERSCHEME_DOREMOVE @NUM, @MSG OUTPUT
  IF @RET <> 0 RETURN @RET

  INSERT INTO STOREOPERSCHEME(NUM, STAT, SETTLENO, FILDATE, FILLER, SNDTIME, LSTUPDOPER, LSTUPDTIME,
    NOTE, RECCNT)
  SELECT NUM, 0, @CUR_SETTLENO, FILDATE, FILLER, SNDTIME, LSTUPDOPER, LSTUPDTIME,
    NOTE, RECCNT
  FROM NSTOREOPERSCHEME(NOLOCK)
  WHERE SRC = @SRC AND ID = @ID

  INSERT INTO STOREOPERSCHEMEDTL(NUM, LINE, SORTCODE, NOTE)
  SELECT NUM, LINE, SORTCODE, NOTE
  FROM NSTOREOPERSCHEMEDTL(NOLOCK)
  WHERE SRC = @SRC
    AND ID = @ID
    AND NUM = @NUM

  INSERT INTO STORESCHSORTGOODS(NUM, SORTCODE, GDGID, ISOPER, ISNECESSARY)
  SELECT NUM, SORTCODE, GDGID, ISOPER, ISNECESSARY
  FROM NSTORESCHSORTGOODS(NOLOCK)
  WHERE SRC = @SRC
    AND ID = @ID
    AND NUM = @NUM

  --门店接收时自动增加生效门店记录
  INSERT INTO SCHEMELAC(NUM, STOREGID)
  SELECT @NUM, @USERGID

  --门店接收后直接生效
  EXEC @RET = STOREOPERSCHEME_TO_100 @NUM, '网络交换', 100, @MSG output
  IF @RET <> 0
  BEGIN
    UPDATE NSTOREOPERSCHEME SET NNOTE = @MSG WHERE SRC = @SRC AND ID = @ID
    RETURN @RET
  END

  EXEC NSTORESCHEME_REMOVE @SRC, @ID
  RETURN @RET
END
GO
