SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PrePay_SEND]
(
  @PINUM VARCHAR(14),
  @PIOPER VARCHAR(30), --该参数没有实际含义
  @POERR_MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @DEPT VARCHAR(10)
  DECLARE @VENDOR INT
  DECLARE @CLECENT INT
  DECLARE @SRC INT
  DECLARE @USERGID INT
  DECLARE @ID INT
  DECLARE @VRET INT
  DECLARE @CFLAG INT /*标示网络表的来源单位, 0=计算中心, 1=结算中心*/
  DECLARE @STAT INT
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SET @SRC = NULL
  SET @CLECENT = NULL
  SELECT @DEPT = DEPT, @VENDOR = VENDOR, @SRC = SRC, @CLECENT = CLECENT, @STAT = STAT 
   FROM CNTRPREPAY(NOLOCK)
  WHERE NUM = @PINUM
  
  IF @SRC IS NULL
  BEGIN
    --SET @POERR_MSG = '发送动作无效,本单不需要发送'
    RETURN 0
  END
  
  IF @USERGID = @SRC
  BEGIN  
    IF @CLECENT IS NULL OR @CLECENT = @USERGID
    BEGIN
      --SET @POERR_MSG = '发送动作无效,本单不需要发送'
      RETURN 0
    END
    
    IF @STAT NOT IN (100)
    BEGIN
  	  SET @POERR_MSG = '单据不是‘已审核’状态'
      RETURN 1
    END
    
    UPDATE CNTRPREPAY SET SNDTIME = GETDATE() WHERE NUM = @PINUM
    
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NCNTRPREPAY (Num, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr,
       Filler, Fildate, Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,
       PayFlag, CleCent, SndTime, SRC, ID, RCV, RCVTIME, TYPE, NSTAT, NNOTE, CFLAG)
    SELECT Num, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr, Filler, Fildate,
       Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,PayFlag, CleCent,
       SndTime, @USERGID, @ID, @CLECENT, NULL, 0, 0, NULL, 0--计算中心发出
    FROM CNTRPREPAY(NOLOCK)
    WHERE NUM = @PINUM
        
  END ELSE
  BEGIN
	  IF @SRC <> @CLECENT
	  BEGIN
	    IF @STAT NOT IN (100, 110, 300, 900)
      BEGIN
  	    SET @POERR_MSG = '单据不是‘已审核’‘已完成’‘审核后已作废’或‘已付款’状态'
  	    RETURN 1
      END
	    SET @CFLAG = 1
	  END ELSE
	  BEGIN
	    IF @STAT NOT IN (100)
      BEGIN
  	    SET @POERR_MSG = '单据不是‘已审核’状态'
        RETURN 1
      END
	    SET @CFLAG = 0
	  END
	  
	  UPDATE CNTRPREPAY SET SNDTIME = GETDATE() WHERE NUM = @PINUM
	  
	  EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NCNTRPREPAY (Num, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr,
       Filler, Fildate, Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,
       PayFlag, CleCent, SndTime, SRC, ID, RCV, RCVTIME, TYPE, NSTAT, NNOTE, CFLAG)
    SELECT Num, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr, Filler, Fildate,
       Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,PayFlag, CleCent,
       SndTime, @USERGID, @ID, @SRC, NULL, 0, 0, NULL, @CFLAG
    FROM CNTRPREPAY(NOLOCK)
    WHERE NUM = @PINUM
	END  

  RETURN 0
END
GO
