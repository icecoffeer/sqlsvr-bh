SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[DepIn_SEND]
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
   FROM CNTRDPTBILL(NOLOCK)
  WHERE NUM = @PINUM AND CLS = '收'
  
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
    
    UPDATE CNTRDPTBILL SET SNDTIME = GETDATE() WHERE NUM = @PINUM AND CLS = '收'
    
    EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NCNTRDPTBILL(NUM, CLS, VENDOR, TOTAL, TOTALOFF, STAT, VDROPER, OPER, FILLER,
      FILDATE, CHECKER, PAYER, NOTE, DEPT, STSTORE, PSR, CLECENT, SNDTIME, SRC, ID, RCV,
      RCVTIME, TYPE, NSTAT, NNOTE, CFLAG)
    SELECT NUM, CLS, VENDOR, TOTAL, TOTALOFF, STAT, VDROPER, OPER, FILLER, FILDATE, CHECKER,
      PAYER, NOTE, DEPT, STSTORE, PSR, CLECENT, SNDTIME, @USERGID, @ID, @CLECENT, NULL, 0, 0,
      NULL, 0 --计算中心发出
    FROM CNTRDPTBILL(NOLOCK)
    WHERE NUM = @PINUM AND CLS = '收'
        
  END ELSE
  BEGIN
	  IF @SRC <> @CLECENT
	  BEGIN
	    IF @STAT NOT IN (100, 1800, 2400)
      BEGIN
  	    SET @POERR_MSG = '单据不是‘已审核’‘已收款’或‘已退款’状态'
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
	  
	  UPDATE CNTRDPTBILL SET SNDTIME = GETDATE() WHERE NUM = @PINUM AND CLS = '收'
	  
	  EXECUTE GETNETBILLID @ID OUTPUT
    INSERT INTO NCNTRDPTBILL(NUM, CLS, VENDOR, TOTAL, TOTALOFF, STAT, VDROPER, OPER, FILLER,
      FILDATE, CHECKER, PAYER, NOTE, DEPT, STSTORE, PSR, CLECENT, SNDTIME, SRC, ID, RCV,
      RCVTIME, TYPE, NSTAT, NNOTE, CFLAG)
    SELECT NUM, CLS, VENDOR, TOTAL, TOTALOFF, STAT, VDROPER, OPER, FILLER, FILDATE, CHECKER,
      PAYER, NOTE, DEPT, STSTORE, PSR, CLECENT, SNDTIME, @USERGID, @ID, @SRC, NULL, 0, 0,
      NULL, @CFLAG
    FROM CNTRDPTBILL(NOLOCK)
    WHERE NUM = @PINUM AND CLS = '收'
	END

  RETURN 0
END
GO
