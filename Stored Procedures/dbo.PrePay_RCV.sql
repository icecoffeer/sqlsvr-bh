SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PrePay_RCV](
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER VARCHAR(50),
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE @RCV_GID INT
  DECLARE @NET_NUM VARCHAR(14)
  DECLARE @NET_TYPE INT
  DECLARE @VRET INT
  DECLARE @STAT INT
  DECLARE @NET_VENDOR INT
  DECLARE @NET_NOTE VARCHAR(255)
  DECLARE @CFLAG INT
  DECLARE @TOTALOFF MONEY
  DECLARE @PAYER VARCHAR(50)

  SELECT @RCV_GID = RCV, @NET_TYPE = TYPE, @NET_NUM = NUM, @NET_VENDOR = VENDOR,
    @NET_NOTE = NOTE, @CFLAG = CFLAG
  FROM NCNTRPREPAY(NOLOCK) WHERE ID = @BILL_ID AND SRC = @SRC_ID
  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END
  
  IF @CFLAG = 0
  BEGIN
    IF EXISTS(SELECT 1 FROM CNTRPREPAY(NOLOCK) WHERE NUM = @NET_NUM)
    BEGIN
      SET @MSG = '[接收]单据' +  @NET_NUM + '已经被接收'
      RETURN 3
    END
  END

  IF (SELECT MAX(USERGID) FROM FASYSTEM(NOLOCK)) <>  @RCV_GID
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '接收单位不是本单位'
    RETURN 4
  END

  IF @NET_TYPE <> 1
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不在接收缓冲区中'
    RETURN 5
  END

  IF NOT EXISTS(SELECT 1 FROM VENDOR(NOLOCK) WHERE GID = @NET_VENDOR)
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '结算单位在本地不存在'
    RETURN 6
  END
  
  IF @CFLAG = 0
  BEGIN    
    INSERT INTO CNTRPREPAY(NUM, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr,
       Filler, Fildate, Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,
       PayFlag, CleCent, SndTime, SRC)
    SELECT NUM, Vendor, Stat, Payer, Vdrrcver, Ocrdate, Note, Dept, Psr,
       Filler, Fildate, Checker, Total, TotalOff, ChkFlag, ABOLISHRESON, SETTLEACCOUNTNO,
       PayFlag, CleCent, NULL, SRC
    FROM NCNTRPREPAY(NOLOCK)
      WHERE SRC = @SRC_ID AND ID = @BILL_ID
  END ELSE
  BEGIN
    SELECT @PAYER = PAYER, @TOTALOFF = TOTALOFF, @STAT = STAT
  	 FROM NCNTRPREPAY(NOLOCK)
  	WHERE ID = @BILL_ID AND SRC = @SRC_ID

    UPDATE CNTRPREPAY SET TOTALOFF = @TOTALOFF, STAT = @STAT, PAYER = @PAYER
      WHERE NUM = @NET_NUM
  END
  DELETE FROM NCNTRPREPAY WHERE ID = @BILL_ID AND SRC = @SRC_ID
  UPDATE CNTRPREPAY SET NOTE = @NET_NOTE WHERE NUM = @NET_NUM
    
  SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG
  
  RETURN 0
END
GO