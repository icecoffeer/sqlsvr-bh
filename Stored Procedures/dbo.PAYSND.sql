SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PAYSND]
(
  @PINUM VARCHAR(10),
  @POERR_MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @BILLTO INT
  DECLARE @CLECENT INT
  DECLARE @SRC INT
  DECLARE @USERGID INT
  DECLARE @MODNUM VARCHAR(10)
  DECLARE @ID INT
  DECLARE @VRET INT
  DECLARE @CFLAG INT /*标示网络表的来源单位, 0=计算中心, 1=结算中心*/
  DECLARE @STAT INT
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CLECENT = NULL
  SELECT @BILLTO = BILLTO, @SRC = SRC, @CLECENT = CLECENT, @STAT = STAT, @MODNUM = IsNull(MODNUM, '')
   FROM PAY(NOLOCK)
  WHERE NUM = @PINUM
  
  IF @STAT NOT IN (1, 2) --被修正单也可以发送
  BEGIN
    SET @POERR_MSG = '单据不是允许发送状态'
    RETURN 1
  END
  
  IF @SRC IS NULL
  BEGIN
    SET @POERR_MSG = '发送动作无效,本单不需要发送'
    RETURN -1
  END
  
  IF @USERGID = @SRC--门店
  BEGIN  
    IF @CLECENT IS NULL OR @CLECENT = @USERGID
    BEGIN
      SET @POERR_MSG = '发送动作无效,本单不需要发送'
      RETURN -1
    END
    
    UPDATE PAY SET SNDTIME = GETDATE() WHERE NUM = @PINUM
    
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NPAY (NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT,
       MODNUM, FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
       DEPT, CLECENT, SNDTIME, SRC, SRCNUM, ID, RCV, RCVTIME, TYPE,
       NSTAT, NNOTE, CFLAG, SETTLEDEPT)
    SELECT NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT,
       MODNUM, FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
       DEPT, CLECENT, SNDTIME, @USERGID, SRCNUM, @ID, @CLECENT, NULL, 
       0, 0, NULL, 0, SETTLEDEPT--计算中心发出
    FROM PAY(NOLOCK)
    WHERE NUM = @PINUM
  END ELSE --结算中心
  BEGIN
    --只有修正单据产生的新审核状态结算单发送时需要发送被修正单据
    IF @MODNUM <> '' and @STAT = 1 
      EXEC @VRET = PAYSND @MODNUM, @POERR_MSG OUTPUT
	    IF @VRET > 0 RETURN @VRET
    ELSE
    BEGIN
      IF @SRC <> @CLECENT SET @CFLAG = 1 ELSE SET @CFLAG = 0

      UPDATE PAY SET SNDTIME = GETDATE() WHERE NUM = @PINUM

      EXECUTE GETNETBILLID @ID OUTPUT
      INSERT INTO NPAY (NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT,
        MODNUM, FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
        DEPT, CLECENT, SNDTIME, SRC, SRCNUM, ID, RCV, RCVTIME, TYPE,
        NSTAT, NNOTE, CFLAG, SETTLEDEPT)
      SELECT NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT,
        MODNUM, FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
        DEPT, CLECENT, SNDTIME, @USERGID, SRCNUM, @ID, @SRC, NULL, 0,
        0, NULL, @CFLAG, SETTLEDEPT
      FROM PAY(NOLOCK)
      WHERE NUM = @PINUM
    END
  END  

  RETURN 0
END

GO
