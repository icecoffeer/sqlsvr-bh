SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VDRPAYRTN_RCV](
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER VARCHAR(50),
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE @RCV_GID INT
  DECLARE @NET_STAT INT
  DECLARE @NET_NUM VARCHAR(14)
  DECLARE @NET_TYPE INT
  DECLARE @VRET INT
  DECLARE @OPERGID INT
  
  SELECT @RCV_GID = RCV, @NET_STAT = STAT, @NET_TYPE = NTYPE, @NET_NUM = NUM
  FROM NCTVDRPAYRTN(NOLOCK) WHERE ID = @BILL_ID AND SRC = @SRC_ID
  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END
  
  IF EXISTS(SELECT 1 FROM CTVDRPAYRTN(NOLOCK) WHERE NUM = @NET_NUM AND STAT = @NET_STAT)
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '已经被接收'
    RETURN 3
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
  
  DELETE FROM CTVDRPAYRTN WHERE NUM = @NET_NUM
  
  INSERT INTO CTVDRPAYRTN(NUM, VENDOR, STAT, FILLER, FILDATE, CHECKER, CHKDATE, OCRDATE, DEPT, 
    TOTAL, VDRPAYNUM, NOTE, LSTUPDTIME, LASTMODIFIER, SNDTIME, SRC)
  SELECT NUM, VENDOR, 0, FILLER, FILDATE, CHECKER, CHKDATE, OCRDATE, DEPT, 
    TOTAL, VDRPAYNUM, NOTE, LSTUPDTIME, LASTMODIFIER, SNDTIME, SRC
  FROM NCTVDRPAYRTN(NOLOCK)
  WHERE SRC = @SRC_ID AND ID = @BILL_ID
  
  EXEC @VRET = VDRPAYRTN_NETDELETE @BILL_ID, @SRC_ID, @OPER, @MSG OUTPUT
  IF @VRET <> 0 RETURN @VRET
  
  SELECT @OPERGID = GID FROM EMPLOYEE(NOLOCK) WHERE @OPER = RTRIM(NAME) + '[' + RTRIM(CODE) + ']'
  EXEC @VRET = PCT_VDRPAYRTN_ON_MODIFY @NET_NUM, 900, @OPERGID, @MSG OUTPUT
  IF @VRET <> 0 RETURN @VRET
    
  SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG
  
  RETURN 0
END
GO
