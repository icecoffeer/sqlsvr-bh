SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKCHGBOOK_SEND]
(
  @PINUM VARCHAR(14),
  @PIOPER VARCHAR(30),
  @POERR_MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @DEPT VARCHAR(10)
  DECLARE @VENDOR INT
  DECLARE @CASHCENTER INT
  DECLARE @SRC INT
  DECLARE @USERGID INT
  DECLARE @ID INT
  DECLARE @MODNUM VARCHAR(14)
  DECLARE @VRET INT
  DECLARE @CFLAG INT
  DECLARE @NET_STAT INT --zz 090402

  --SELECT @VRET = 1--zz 090402
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CASHCENTER = NULL
  SELECT @DEPT = DEPT, @VENDOR = VENDOR, @MODNUM = IsNull(MODNUM, ''), @SRC = SRC,
    @CASHCENTER = CASHCENTER, @NET_STAT = STAT --zz 090402
  FROM CHGBOOK(NOLOCK) 
  WHERE NUM = @PINUM
  
  IF @SRC IS NULL
  BEGIN
    --SET @POERR_MSG = '发送动作无效，本单不需要发送'
    RETURN 0
  END
  
  IF @USERGID = @SRC
  BEGIN  
    IF @CASHCENTER IS NULL
    BEGIN
      --SET @POERR_MSG = '发送动作无效，本单不需要发送'
      RETURN 0
    END
    
    UPDATE CHGBOOK SET SNDTIME = GETDATE() WHERE NUM = @PINUM
    
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NCHGBOOK (NUM, VENDOR, CNTRNUM, CHGCODE, CALCTOTAL, CALCRATE, SHOULDAMT, 
      REALAMT, OCRDATE, SIGNDATE, SIGNER, FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO, 
      STAT, NOTE, CALCBEGIN, CALCEND, FIXNOTE, BTYPE, SRCNUM, SRCCLS, PRNTIME, MODNUM, 
      LSTUPDTIME, BILLTO, GATHERINGMODE, ACCOUNTTERM, PAYTOTAL, DEPT, PAYDIRECT, PAYDATE, 
      PSR, CNTRVERSION, GENDATE, STORE, ABOLISHRESON, TAXRATE, PAYUNIT, STSTORE, SNDTIME,
      SRC, CASHCENTER, ID, RCV, RCVTIME, NTYPE, NSTAT, NNOTE, CFLAG)
    SELECT NUM, VENDOR, CNTRNUM, CHGCODE, CALCTOTAL, CALCRATE, SHOULDAMT, 
      REALAMT, OCRDATE, SIGNDATE, SIGNER, FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO, 
      STAT, NOTE, CALCBEGIN, CALCEND, FIXNOTE, BTYPE, SRCNUM, SRCCLS, PRNTIME, MODNUM, 
      LSTUPDTIME, BILLTO, GATHERINGMODE, ACCOUNTTERM, PAYTOTAL, DEPT, PAYDIRECT, PAYDATE, 
      PSR, CNTRVERSION, GENDATE, STORE, ABOLISHRESON, TAXRATE, PAYUNIT, STSTORE, SNDTIME,
      @USERGID, CASHCENTER, @ID, @CASHCENTER, NULL, 0, 0, NULL, 0 --计算中心发出
    FROM CHGBOOK(NOLOCK)
    WHERE NUM = @PINUM
        
  END ELSE
  BEGIN
   --只有修正产生的新审核状态的单据发送时需要将对应的被修正单据发送 zz 090402
   IF @MODNUM <> '' and @NET_STAT = 500
     EXEC @VRET = CHKCHGBOOK_SEND @MODNUM, @PIOPER, @POERR_MSG OUTPUT
	   IF @VRET > 0 RETURN @VRET
	 ELSE BEGIN
	  IF @SRC <> @CASHCENTER
	    SET @CFLAG = 1
	  ELSE
	    SET @CFLAG = 0
	  
	  UPDATE CHGBOOK SET SNDTIME = GETDATE() WHERE NUM = @PINUM
	  
	  EXECUTE GETNETBILLID @ID OUTPUT
      INSERT INTO NCHGBOOK (NUM, VENDOR, CNTRNUM, CHGCODE, CALCTOTAL, CALCRATE, SHOULDAMT, 
        REALAMT, OCRDATE, SIGNDATE, SIGNER, FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO, 
        STAT, NOTE, CALCBEGIN, CALCEND, FIXNOTE, BTYPE, SRCNUM, SRCCLS, PRNTIME, MODNUM, 
        LSTUPDTIME, BILLTO, GATHERINGMODE, ACCOUNTTERM, PAYTOTAL, DEPT, PAYDIRECT, PAYDATE, 
        PSR, CNTRVERSION, GENDATE, STORE, ABOLISHRESON, TAXRATE, PAYUNIT, STSTORE, SNDTIME, 
        SRC, CASHCENTER, ID, RCV, RCVTIME, NTYPE, NSTAT, NNOTE, CFLAG)
      SELECT NUM, VENDOR, CNTRNUM, CHGCODE, CALCTOTAL, CALCRATE, SHOULDAMT, 
        REALAMT, OCRDATE, SIGNDATE, SIGNER, FILDATE, FILLER, CHKDATE, CHECKER, SETTLENO, 
        STAT, NOTE, CALCBEGIN, CALCEND, FIXNOTE, BTYPE, SRCNUM, SRCCLS, PRNTIME, MODNUM, 
        LSTUPDTIME, BILLTO, GATHERINGMODE, ACCOUNTTERM, PAYTOTAL, DEPT, PAYDIRECT, PAYDATE, 
        PSR, CNTRVERSION, GENDATE, STORE, ABOLISHRESON, TAXRATE, PAYUNIT, STSTORE, SNDTIME,
        @USERGID, CASHCENTER, @ID, @SRC, NULL, 0, 0, NULL, @CFLAG
      FROM CHGBOOK(NOLOCK)
      WHERE NUM = @PINUM 
            
	END	  
  END  
  
  RETURN 0
END

GO