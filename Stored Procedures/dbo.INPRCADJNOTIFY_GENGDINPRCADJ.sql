SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[INPRCADJNOTIFY_GENGDINPRCADJ](
  @NUM	CHAR(14),
  @GENNUM	CHAR(14) OUTPUT,
  @MSG	VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE
    @USERGID INT,
    @ADJMETHOD INT,
    @LINE INT,
    @GDGID INT,
    @DEFPRC MONEY,
    @PLANQTY MONEY,
    @SUMINVQTY MONEY,
    @OLDPRC MONEY,
    @INVQTY MONEY,
    @WRH INT,
    @DIFFPRC MONEY

  EXEC GENNEXTBILLNUMEX @PICLS = NULL, @PIBILL = 'GDINPRCADJ', @PONEWNUM = @GENNUM OUTPUT

  INSERT INTO GDINPRCADJ(NUM, SRC, STAT, LAUNCH, FILLER, FILLDATE, LSTUPDTIME,
    CHECKER, CHKDATE, SRCBILL, SRCNUM, SRCCLS, NOTE)
  SELECT @GENNUM, SRCSTORE, 0, BGNTIME, '未知[-]', GETDATE(), GETDATE(),
    NULL, NULL, 'INPRCADJNOTIFY', NUM, NULL, '由成本调整通知单生成'
  FROM INPRCADJNOTIFY(NOLOCK)
  WHERE NUM = @NUM

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '生成商品成本调整单失败'
    RETURN 1
  END

  SELECT @USERGID = USERGID FROM SYSTEM(NOLOCK)
  SELECT @ADJMETHOD = ADJMETHOD FROM INPRCADJNOTIFY(NOLOCK) WHERE NUM = @NUM

  IF @ADJMETHOD = 1 --指定价
  BEGIN
    SET @LINE = 1
    DECLARE C_LAC CURSOR FOR
    SELECT GDGID, DEFPRC, PLANQTY
    FROM INPRCADJNOTIFYDTL(NOLOCK)
    WHERE NUM = @NUM

    OPEN C_LAC
    FETCH NEXT FROM C_LAC INTO
      @GDGID, @DEFPRC, @PLANQTY
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT @SUMINVQTY = SUM(V.QTY) FROM INV V(NOLOCK), GDWRH W(NOLOCK)
      WHERE V.STORE = @USERGID AND V.WRH = W.WRH AND V.GDGID = @GDGID AND W.GDGID = @GDGID

      DECLARE C_LAC1 CURSOR FOR
      SELECT ISNULL(W.INVPRC, 0), ISNULL(V.QTY, 0), V.WRH
      FROM INV V(NOLOCK), GDWRH W(NOLOCK)
      WHERE V.STORE = @USERGID AND V.WRH = W.WRH AND V.GDGID = @GDGID AND W.GDGID = @GDGID

      OPEN C_LAC1
      FETCH NEXT FROM C_LAC1 INTO
        @OLDPRC, @INVQTY, @WRH
      WHILE @@FETCH_STATUS = 0
      BEGIN
        INSERT INTO GDINPRCADJDTL(NUM, LINE, GDGID, OLDPRC, NEWPRC, QTY, INVQTY,
          DIFFPRC, DIFFAMT, PREPRO, NOTE, WRH)
        VALUES(@GENNUM, @LINE, @GDGID, @OLDPRC, @DEFPRC, @PLANQTY, @INVQTY,
          @DEFPRC - @OLDPRC, (@DEFPRC - @OLDPRC) * @PLANQTY, 0, NULL, @WRH)

        UPDATE GDINPRCADJDTL SET DIFFAMT = DIFFPRC * @SUMINVQTY WHERE NUM = @GENNUM AND QTY = -1 AND LINE = @LINE
        UPDATE GDINPRCADJDTL SET QTY = @SUMINVQTY WHERE NUM = @GENNUM AND QTY = -1 AND LINE = @LINE

        SET @LINE = @LINE + 1

        FETCH NEXT FROM C_LAC1 INTO
          @OLDPRC, @INVQTY, @WRH
      END
      CLOSE C_LAC1
      DEALLOCATE C_LAC1

      FETCH NEXT FROM C_LAC INTO
        @GDGID, @DEFPRC, @PLANQTY
    END
    CLOSE C_LAC
    DEALLOCATE C_LAC

  END
  ELSE IF @ADJMETHOD = 0
  BEGIN
    SET @LINE = 1
    DECLARE C_LAC CURSOR FOR
    SELECT GDGID, DIFFPRC, PLANQTY
    FROM INPRCADJNOTIFYDTL(NOLOCK)
    WHERE NUM = @NUM

    OPEN C_LAC
    FETCH NEXT FROM C_LAC INTO
      @GDGID, @DIFFPRC, @PLANQTY
    WHILE @@FETCH_STATUS = 0
    BEGIN
      SELECT @SUMINVQTY = SUM(ABS(V.QTY)) FROM INV V(NOLOCK), GDWRH W(NOLOCK)
      WHERE V.STORE = @USERGID AND V.WRH = W.WRH AND V.GDGID = @GDGID AND W.GDGID = @GDGID

      DECLARE C_LAC1 CURSOR FOR
      SELECT ISNULL(W.INVPRC, 0), ISNULL(V.QTY, 0), V.WRH
      FROM INV V(NOLOCK), GDWRH W(NOLOCK)
      WHERE V.STORE = @USERGID AND V.WRH = W.WRH AND V.GDGID = @GDGID AND W.GDGID = @GDGID

      OPEN C_LAC1
      FETCH NEXT FROM C_LAC1 INTO
        @OLDPRC, @INVQTY, @WRH
      WHILE @@FETCH_STATUS = 0
      BEGIN
        INSERT INTO GDINPRCADJDTL(NUM, LINE, GDGID, OLDPRC, NEWPRC, QTY, INVQTY,
          DIFFPRC, DIFFAMT, PREPRO, NOTE, WRH)
        VALUES(@GENNUM, @LINE, @GDGID, @OLDPRC, @OLDPRC + @DIFFPRC, @PLANQTY, @INVQTY,
          @DIFFPRC, @DIFFPRC * @PLANQTY, 0, NULL, @WRH)

        UPDATE GDINPRCADJDTL SET DIFFAMT = DIFFPRC * @SUMINVQTY WHERE NUM = @GENNUM AND QTY = -1 AND LINE = @LINE
        UPDATE GDINPRCADJDTL SET QTY = @SUMINVQTY WHERE NUM = @GENNUM AND QTY = -1 AND LINE = @LINE

        SET @LINE = @LINE + 1

        FETCH NEXT FROM C_LAC1 INTO
          @OLDPRC, @INVQTY, @WRH
      END
      CLOSE C_LAC1
      DEALLOCATE C_LAC1

      FETCH NEXT FROM C_LAC INTO
        @GDGID, @DIFFPRC, @PLANQTY
    END
    CLOSE C_LAC
    DEALLOCATE C_LAC

  END

  IF @@ERROR <> 0
  BEGIN
    SET @MSG = '生成商品成本调整单失败'
    RETURN 2
  END

  RETURN 0
END
GO
