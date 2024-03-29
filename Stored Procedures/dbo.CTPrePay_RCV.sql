SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CTPrePay_RCV](
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
  DECLARE @VTOTAL MONEY
  DECLARE @VPREPAYNUM VARCHAR(14)

  SELECT @RCV_GID = RCV, @NET_TYPE = TYPE, @NET_NUM = NUM, @NET_VENDOR = VENDOR,
    @NET_NOTE = NOTE, @CFLAG = CFLAG
  FROM NCTPREPAYRTN(NOLOCK) WHERE ID = @BILL_ID AND SRC = @SRC_ID
  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END
  
  IF @CFLAG = 0
  BEGIN
    IF EXISTS(SELECT 1 FROM CTPREPAYRTN(NOLOCK) WHERE NUM = @NET_NUM)
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
    INSERT INTO CTPREPAYRTN(NUM, VENDOR, STAT, FILLER, FILDATE, CHECKER, CHKDATE, OCRDATE,
      DEPT, PSR, TOTAL, PREPAYNUM, NOTE, LSTUPDTIME, LASTMODIFIER, CLECENT, SNDTIME, SRC)
    SELECT NUM, VENDOR, STAT, FILLER, FILDATE, CHECKER, CHKDATE, OCRDATE, DEPT, PSR, TOTAL,
      PREPAYNUM, NOTE, LSTUPDTIME, LASTMODIFIER, CLECENT, NULL, SRC
    FROM NCTPREPAYRTN(NOLOCK)
      WHERE SRC = @SRC_ID AND ID = @BILL_ID
  END ELSE
  BEGIN
    SELECT @VPREPAYNUM = PREPAYNUM, @VTOTAL = TOTAL, @STAT = STAT
     FROM NCTPREPAYRTN(NOLOCK)
  	WHERE ID = @BILL_ID AND SRC = @SRC_ID

    UPDATE CTPREPAYRTN SET STAT = @STAT
      WHERE NUM = @NET_NUM

    UPDATE CNTRPREPAY SET TOTALOFF = TOTALOFF + @VTOTAL WHERE NUM = @VPREPAYNUM
    UPDATE CNTRPREPAY SET STAT = 300 WHERE NUM = @VPREPAYNUM AND TOTALOFF >= TOTAL
  END
  DELETE FROM NCTPREPAYRTN WHERE ID = @BILL_ID AND SRC = @SRC_ID
  UPDATE CTPREPAYRTN SET NOTE = @NET_NOTE WHERE NUM = @NET_NUM

  SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG

  RETURN 0
END
GO
