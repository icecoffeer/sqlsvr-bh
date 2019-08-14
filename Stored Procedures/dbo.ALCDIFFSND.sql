SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCDIFFSND]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),	-- 0-总部; 1-门店
  @TOSTAT INT,		-- 未使用
  @MSG VARCHAR(255) OUTPUT
) --WITH ENCRYPTION		-- RETURN ERROR FROM 600
AS
BEGIN
    DECLARE
      @SRC INT,       	@ID  INT,
      @RCV INT, 	@STAT SMALLINT

    SELECT @STAT = STAT
    FROM ALCDIFF(NOLOCK) WHERE NUM = @NUM

--CHECK
    IF @STAT <> 401 AND @STAT <> 400 AND @STAT <> 210 AND @STAT <> 300
    BEGIN
      SET @MSG = '[发送]单据' + @NUM + '不是请求总部批准、总部批准或进行中作废、已完成状态'
      RETURN 601
    END

    IF @STAT = 401
    BEGIN
      /*IF EXISTS(SELECT 1 FROM ALCDIFF(NOLOCK) WHERE NUM = @NUM AND SNDTIME IS NOT NULL)
      BEGIN
        SET @MSG = '[发送]单据' + @NUM + '不能重复发送'
        RETURN 602
      END*/ -- 允许重复发送请求总部批准的单据
      IF EXISTS(SELECT 1 FROM SYSTEM(NOLOCK) WHERE USERGID = ZBGID)
      BEGIN
        SET @MSG = '[发送]单据' + @NUM + ':请求总部批准的单据总部不能发送'
        RETURN 603
      END
    END

--BEGIN TO SEND
    IF @CLS = '0' --总部
    BEGIN
      SELECT @RCV = CLIENT FROM ALCDIFF(NOLOCK) WHERE NUM = @NUM
      SELECT @SRC = GID FROM STORE(NOLOCK) WHERE CODE IN (SELECT USERCODE FROM SYSTEM(NOLOCK))
    END ELSE
    BEGIN
      SELECT @SRC = CLIENT FROM ALCDIFF(NOLOCK) WHERE NUM = @NUM
      SELECT @RCV = ZBGID FROM SYSTEM(NOLOCK)
    END

    UPDATE ALCDIFF SET SNDTIME = GETDATE() WHERE NUM = @NUM

    EXECUTE GETNETBILLID @ID OUTPUT

    INSERT INTO NALCDIFF(ID, NUM, SETTLENO, CLIENT, BILLTO, WRH, FILLER, FILDATE,
      REQOPER, REQDATE, CHECKER, CHKDATE, CANCELER, CACLDATE, LSTUPDTIME, STAT, NOTE,
      RECCNT, SNDTIME, PRNTIME, CAUSE, ATTITUDE, ALCFROM, GENNOTE, GENSTAT,
      NSTAT, RCV, RCVTIME, TYPE, NNOTE, SRC)
    SELECT @ID, NUM, SETTLENO, CLIENT, BILLTO, WRH, FILLER, FILDATE,
      REQOPER, REQDATE, CHECKER, CHKDATE, CANCELER, CACLDATE, LSTUPDTIME, STAT, NOTE,
      RECCNT, GETDATE(), PRNTIME, CAUSE, ATTITUDE, ALCFROM, GENNOTE, GENSTAT,
      0, @RCV, NULL, 0, NULL, @SRC
    FROM ALCDIFF(NOLOCK)
    WHERE NUM = @NUM

    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送' + @NUM + '单据失败'
        RETURN 604
    END

    INSERT INTO NALCDIFFDTL (SRC, ID, NUM, LINE, GDGID, SRCNUM, CASES, QTY, WRH, NOTE)
    SELECT @SRC, @ID, NUM, LINE, GDGID, SRCNUM, CASES, QTY, WRH, NOTE
    FROM ALCDIFFDTL(NOLOCK)
    WHERE NUM = @NUM

    IF @@ERROR <> 0
    BEGIN
        SET @MSG = '发送' + @NUM+ '单据失败'
        RETURN 605
    END

    EXEC ALCDIFFADDLOG @NUM, @STAT, '发送', ''

    SET @MSG = '发送' + @NUM+ '单据成功'

    RETURN 0
END
GO