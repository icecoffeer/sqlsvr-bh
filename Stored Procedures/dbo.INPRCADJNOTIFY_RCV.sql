SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_RCV](
  @SRC	INT,
  @ID	INT,
  @MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @NET_NUM CHAR(14),
    @RCV_GID INT,
    @NET_STAT SMALLINT,
    @NET_TYPE SMALLINT,
    @RE INT,
    @RCVFRCCHK INT,
    @OPER CHAR(30),
    @COUNTTRUE MONEY,
    @COUNTALL MONEY,
    @LOCALSTAT INT,
    @BCKSTAT INT,
    @GDGID INT,
    @REALQTY MONEY,
    @REALAMT MONEY

  SELECT  @RCV_GID = RCV, @NET_STAT = STAT, @NET_TYPE = NTYPE, @NET_NUM = NUM,
    @RCVFRCCHK = RCVFRCCHK
  FROM NINPRCADJNOTIFY(NOLOCK) WHERE ID = @ID AND SRC = @SRC

  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END

  IF (SELECT USERGID FROM SYSTEM(NOLOCK)) <>  @RCV_GID
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '接收单位不是本单位'
    RETURN 2
  END

  IF @NET_TYPE <> 1
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不在接收缓冲区中'
    RETURN 3
  END

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
    RETURN 4
  END

  IF (SELECT STAT FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM) <> 100
    AND (SELECT STAT FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM) <> 110
  BEGIN
    --RAISERROR('单据不是已审核', 16, 1)
    RETURN 0
  END

  DECLARE @FILLERCODE VARCHAR(20), @FILLER INT, @FILLERNAME VARCHAR(50)
  SET @FILLERCODE = SUSER_SNAME()
  WHILE CHARINDEX('_', @FILLERCODE) <> 0
  BEGIN
    SET @FILLERCODE = SUBSTRING(@FILLERCODE, CHARINDEX('_', @FILLERCODE) + 1, LEN(@FILLERCODE))
  END
  SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
  IF @FILLERNAME IS NULL
  BEGIN
    SET @FILLERCODE = '-'
    SET @FILLERNAME = '未知'
    SELECT @FILLER = GID FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
  END
  SET @OPER = RTRIM(ISNULL(@FILLERNAME,'')) + '[' + RTRIM(ISNULL(@FILLERCODE,'')) + ']'

  IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID <> ZBGID) --门店接收
  BEGIN
    IF NOT EXISTS(SELECT 1 FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM) --第一次接收
    BEGIN
      DELETE FROM INPRCADJNOTIFY WHERE NUM = @NET_NUM
      DELETE FROM INPRCADJNOTIFYDTL WHERE NUM = @NET_NUM
      DELETE FROM INPRCADJNOTIFYBCKDTL WHERE NUM = @NET_NUM

      INSERT INTO INPRCADJNOTIFY(NUM, SRCSTORE, STAT, BGNTIME, ENDTIME, SUBTIME, SUBEMP, SUBJECT,
        EXESTAT, MODIFIER, LSTUPDTIME, LSTRPLYTIME, SNDDATE, PRNTIME, NOTE, SRCNUM, SRCCLS,
        GENBILL, GENNUM, GENCLS, VENDOR, ADJMETHOD, CANPAY, DIFFPROCMETHOD, RCVFRCCHK,
        WAITFORFIN, FINEXP, FINISHED, FILLER, FILDATE, SETTLENO)
      SELECT NUM, SRCSTORE, 0, BGNTIME, ENDTIME, SUBTIME, SUBEMP, SUBJECT,
        EXESTAT, MODIFIER, LSTUPDTIME, LSTRPLYTIME, SNDDATE, PRNTIME, NOTE, SRCNUM, SRCCLS,
        GENBILL, GENNUM, GENCLS, VENDOR, ADJMETHOD, CANPAY, DIFFPROCMETHOD, RCVFRCCHK,
        WAITFORFIN, FINEXP, FINISHED, FILLER, FILDATE, SETTLENO
      FROM NINPRCADJNOTIFY(NOLOCK)
      WHERE SRC = @SRC AND ID = @ID

      INSERT INTO INPRCADJNOTIFYDTL(NUM, LINE, GDGID, DEFPRC, DIFFPRC, PLANQTY, NOTE, OLDINPRC, OLDRTLPRC, OLDCNTINPRC)
      SELECT NUM, LINE, GDGID, DEFPRC, DIFFPRC, PLANQTY, NOTE, OLDINPRC, OLDRTLPRC, OLDCNTINPRC
      FROM NINPRCADJNOTIFYDTL(NOLOCK)
      WHERE SRC = @SRC AND ID = @ID

      INSERT INTO INPRCADJNOTIFYBCKDTL(NUM, LINE, STOREGID, GDGID, DEFPRC, DIFFPRC, PLANQTY,
        QTY, OLDPRC, NEWPRC, NOTE, AMT, CNTAMT, CNTPRC, LACTIME)
      SELECT NUM, LINE, STOREGID, GDGID, DEFPRC, DIFFPRC, PLANQTY,
        QTY, OLDPRC, NEWPRC, NOTE, AMT, CNTAMT, CNTPRC, LACTIME
      FROM NINPRCADJNOTIFYBCKDTL(NOLOCK)
      WHERE SRC = @SRC AND ID = @ID

      --发送
      EXEC @RE = INPRCADJNOTIFY_SEND @NET_NUM, @OPER, NULL, 1, @MSG OUTPUT

      IF @RCVFRCCHK = 1
      BEGIN
        EXEC @RE = INPRCADJNOTIFY_CHECK @NET_NUM, @OPER, '', 100, @MSG OUTPUT
        IF @RE <> 0 RETURN @RE
      END
    END
    ELSE IF @NET_STAT = 100
      EXEC @RE = INPRCADJNOTIFY_SEND @NET_NUM, @OPER, NULL, 2, @MSG OUTPUT
    ELSE IF @NET_STAT = 110
    BEGIN
      SELECT @LOCALSTAT = STAT FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM
      IF (@LOCALSTAT = 0) OR (@LOCALSTAT = 100)
      BEGIN
        UPDATE INPRCADJNOTIFY SET STAT = 110 WHERE NUM = @NET_NUM
        --发送
        EXEC @RE = INPRCADJNOTIFY_SEND @NET_NUM, @OPER, NULL, 4, @MSG OUTPUT
      END
      ELSE IF @LOCALSTAT = 1200
      BEGIN
        UPDATE INPRCADJNOTIFY SET STAT = 110 WHERE NUM = @NET_NUM
        --发送
        EXEC @RE = INPRCADJNOTIFY_SEND @NET_NUM, @OPER, NULL, 3, @MSG OUTPUT
      END
    END
  END
  ELSE
  BEGIN
    UPDATE INPRCADJNOTIFY SET LSTRPLYTIME = GETDATE() WHERE NUM = @NET_NUM

    SELECT @BCKSTAT = STAT FROM NINPRCADJNOTIFYBCKDTL(NOLOCK) WHERE ID = @ID AND SRC = @SRC
    IF @BCKSTAT = 3 OR @BCKSTAT = 4 OR @BCKSTAT = 5 OR @BCKSTAT = 6 OR @BCKSTAT = 7
      DELETE FROM INPRCADJNOTIFYBCKDTL WHERE NUM = @NET_NUM AND STOREGID = @SRC

    INSERT INTO INPRCADJNOTIFYBCKDTL(NUM, LINE, STOREGID, GDGID, DEFPRC, DIFFPRC, PLANQTY,
      QTY, OLDPRC, NEWPRC, NOTE, STAT, AMT, CNTAMT, CNTPRC, LACTIME)
    SELECT NUM, LINE, STOREGID, GDGID, DEFPRC, DIFFPRC, PLANQTY,
      QTY, OLDPRC, NEWPRC, NOTE, STAT, AMT, CNTAMT, CNTPRC, LACTIME
    FROM NINPRCADJNOTIFYBCKDTL(NOLOCK)
    WHERE SRC = @SRC AND ID = @ID AND STAT IN (3, 4, 5, 6, 7)

    IF @BCKSTAT = 3 OR @BCKSTAT = 4 OR @BCKSTAT = 5 OR @BCKSTAT = 6 OR @BCKSTAT = 7
    BEGIN
      UPDATE INPRCADJNOTIFYLAC SET PROCSTAT = 1 WHERE NUM = @NET_NUM AND STOREGID = @SRC
      SELECT @COUNTALL = COUNT(*) FROM INPRCADJNOTIFYLAC(NOLOCK) WHERE NUM = @NET_NUM
      SELECT @COUNTTRUE = COUNT(*) FROM INPRCADJNOTIFYLAC(NOLOCK) WHERE NUM = @NET_NUM AND PROCSTAT = 1
      UPDATE INPRCADJNOTIFY SET EXESTAT = @COUNTTRUE / @COUNTALL WHERE NUM = @NET_NUM
    END

    UPDATE INPRCADJNOTIFYBCKDTL SET INPRCADJNOTIFYBCKDTL.STAT = N.STAT
    FROM NINPRCADJNOTIFYBCKDTL N(NOLOCK)
    WHERE INPRCADJNOTIFYBCKDTL.NUM = @NET_NUM AND INPRCADJNOTIFYBCKDTL.STOREGID = @SRC
      AND N.ID = @ID AND N.SRC = @SRC AND N.GDGID = INPRCADJNOTIFYBCKDTL.GDGID

    IF ((SELECT EXESTAT FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM) = 1) and
       ((SELECT STAT FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NET_NUM) <> 110)
    BEGIN
      UPDATE INPRCADJNOTIFY SET STAT = 300 WHERE NUM = @NET_NUM

      DECLARE C_LAC CURSOR FOR
      SELECT GDGID
      FROM INPRCADJNOTIFYDTL(NOLOCK)
      WHERE NUM = @NET_NUM
      ORDER BY LINE

      OPEN C_LAC
      FETCH NEXT FROM C_LAC INTO @GDGID
      WHILE @@FETCH_STATUS = 0
      BEGIN
        SELECT @REALQTY = SUM(B.QTY), @REALAMT = SUM(B.AMT)
        FROM INPRCADJNOTIFYBCKDTL B(NOLOCK)
        WHERE B.NUM = @NET_NUM AND B.GDGID = @GDGID

        UPDATE INPRCADJNOTIFYDTL SET REALQTY = @REALQTY, REALAMT = @REALAMT
        WHERE NUM = @NET_NUM AND GDGID = @GDGID

        FETCH NEXT FROM C_LAC INTO @GDGID
      END
      CLOSE C_LAC
      DEALLOCATE C_LAC

    END
  END

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '[接收]接收' + @NET_NUM + '单据失败'
    RETURN 5
  END

  DELETE FROM NINPRCADJNOTIFY WHERE ID = @ID AND SRC = @SRC
  DELETE FROM NINPRCADJNOTIFYDTL WHERE ID = @ID AND SRC = @SRC
  DELETE FROM NINPRCADJNOTIFYBCKDTL WHERE ID = @ID AND SRC = @SRC

  SET @MSG = '单据：' + @NET_NUM + '接收成功'

  RETURN 0
END
GO
