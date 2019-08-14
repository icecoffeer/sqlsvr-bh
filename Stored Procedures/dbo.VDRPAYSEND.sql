SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VDRPAYSEND]
(
  @CLS CHAR(20),
  @NUM CHAR(14),
  @OPER CHAR(30),
  @TOSTAT INT,
  @MSG VARCHAR(255)	OUTPUT
)
AS
BEGIN
  DECLARE @SRC INT
  DECLARE @USERGID INT
  DECLARE @ID INT
  DECLARE @VRET INT
  DECLARE @MODNUM VARCHAR(14)
  DECLARE @STAT INT
  DECLARE @CHGNUM VARCHAR(14)
  
  SELECT @USERGID = USERGID FROM FASYSTEM(NOLOCK)
  SELECT @STAT = STAT, @MODNUM = MODNUM FROM VDRPAY(NOLOCK) WHERE NUM = @NUM
  SET @SRC = NULL
  SELECT @SRC = G.SRC FROM VDRPAYDTL V(NOLOCK), CHGBOOK G(NOLOCK) WHERE V.NUM = @NUM AND V.CHGNUM = G.NUM
  
  IF @SRC IS NULL OR @SRC = @USERGID
  BEGIN
    SET @MSG = '发送动作无效，本单不需要发送'
    RETURN -1
  END
  
  IF @STAT = 500 AND (@MODNUM IS NOT NULL OR @MODNUM <> '')
  BEGIN
    EXEC @VRET = VDRPAYSEND @CLS, @MODNUM, @OPER, 0, @MSG OUTPUT
    IF @VRET > 0 RETURN @VRET
  END
  
  DECLARE C CURSOR LOCAL FOR SELECT CHGNUM FROM VDRPAYDTL(NOLOCK) WHERE NUM = @NUM
  OPEN C
  FETCH NEXT FROM C INTO @CHGNUM
  WHILE @@FETCH_STATUS = 0
  BEGIN
    EXEC @VRET = CHKCHGBOOK_SEND @CHGNUM, @OPER, @MSG OUTPUT
    IF @VRET > 0 RETURN @VRET
    FETCH NEXT FROM C INTO @CHGNUM
  END
  CLOSE C
  DEALLOCATE C
  
  UPDATE VDRPAY SET SNDTIME = GETDATE() WHERE NUM = @NUM
  
  EXECUTE GETNETBILLID @ID OUTPUT
  INSERT INTO NVDRPAY (NUM, SETTLENO, FILDATE, FILLER, ACNTER, NOTE, STAT, PRNTIME, PAYTOTAL, 
    MODNUM, VGID, LSTUPDTIME, SETTLEACCOUNTNO, DEPT, ABOLISHRESON, STSTORE, SNDTIME, SRC, ID, 
    RCV, RCVTIME, NTYPE, NSTAT, NNOTE)
  SELECT NUM, SETTLENO, FILDATE, FILLER, ACNTER, NOTE, STAT, PRNTIME, PAYTOTAL, 
    MODNUM, VGID, LSTUPDTIME, SETTLEACCOUNTNO, DEPT, ABOLISHRESON, STSTORE, SNDTIME, @USERGID, @ID,
    @SRC, NULL, 0, 0, NULL
  FROM VDRPAY(NOLOCK)
  WHERE NUM = @NUM
  
  INSERT INTO NVDRPAYDTL (NUM, LINE, CHGNUM, SHOULDPAY, REALPAY, PAYTOTAL, NOPAYTOTAL, NOTE, SRC, ID)
  SELECT NUM, LINE, CHGNUM, SHOULDPAY, REALPAY, PAYTOTAL, NOPAYTOTAL, NOTE, @USERGID, @ID
  FROM VDRPAYDTL(NOLOCK)
  WHERE NUM = @NUM

  RETURN 0
END
GO