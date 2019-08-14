SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PAYRCV](
  @BILL_ID INT,
  @SRC_ID INT,
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DECLARE @RCV_GID INT
  DECLARE @NET_NUM VARCHAR(14)
  DECLARE @NET_MODNUM VARCHAR(14)
  DECLARE @NET_TYPE INT
  DECLARE @VRET INT
  DECLARE @NET_BILLTO INT
  DECLARE @NET_NOTE VARCHAR(255)
  DECLARE @BILL_ID1 INT
  DECLARE @SRC_ID1 INT
  DECLARE @CFLAG INT
  DECLARE @NEW_NUM VARCHAR(14)
  DECLARE @MAX_NUM VARCHAR(14)
  DECLARE @SRCNUM VARCHAR(14)
  --zz 090402
  DECLARE @NET_STAT INT
  DECLARE @SRC INT

  SELECT @RCV_GID = RCV, @NET_TYPE = TYPE, @NET_NUM = NUM, @NET_MODNUM = ISNULL(MODNUM, ''),
    @NET_BILLTO = BILLTO, @NET_NOTE = NOTE, @CFLAG = CFLAG, @NET_STAT = NSTAT, @SRC = SRC  --zz 090402
  FROM NPAY(NOLOCK) WHERE ID = @BILL_ID AND SRC = @SRC_ID
  IF @@ROWCOUNT = 0 OR @NET_NUM IS NULL
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '不存在'
    RETURN 1
  END
  
  IF @NET_MODNUM <> ''
  BEGIN
    SELECT @BILL_ID1 = ID, @SRC_ID1 = SRC FROM NPAY(NOLOCK) WHERE NUM = @NET_MODNUM ORDER BY ID DESC
    IF @@ROWCOUNT = 0
    BEGIN
      SET @MSG = '[接收]单据' +  @NET_NUM + '修正链不完整'
      RETURN 2
    END
    EXEC @VRET = PAYRCV @BILL_ID1, @SRC_ID1, @MSG OUTPUT
	IF @VRET > 0 RETURN @VRET
  END
  
  IF EXISTS(SELECT 1 FROM PAY(NOLOCK) WHERE SRCNUM = @NET_NUM and SRC = @SRC)  --多家门店时来源单号可能会重复 zz 090402
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

  IF NOT EXISTS(SELECT 1 FROM VENDOR(NOLOCK) WHERE GID = @NET_BILLTO)
  BEGIN
    SET @MSG = '[接收]单据' +  @NET_NUM + '结算单位在本地不存在'
    RETURN 6
  END
  
  IF @CFLAG = 0 --门店发出,结算中心接收
  BEGIN
  	SELECT @MAX_NUM = MAX(NUM) FROM PAY(NOLOCK)
    if @MAX_NUM IS NULL
      SELECT @NEW_NUM = '0000000001'
    else
      EXECUTE NEXTBN @ABN = @MAX_NUM, @NEWBN = @NEW_NUM output
    
    INSERT INTO PAY(NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT,
      MODNUM, FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
      DEPT, CLECENT, SNDTIME, SRC, SRCNUM, SETTLEDEPT)
    SELECT @NEW_NUM, SETTLENO, FILLER, FILDATE, CHECKER, WRH, BILLTO, AMT, STAT, MODNUM,
      FROMCLS, NOTE, PYTOTAL, PRNTIME, FROMNUM, PSR, ChkTag, OCRDATE, TAXRATELMT,
      DEPT, CLECENT, NULL, SRC, @NET_NUM, SETTLEDEPT
    FROM NPAY(NOLOCK)
      WHERE SRC = @SRC_ID AND ID = @BILL_ID
  END ELSE --结算中心回发,门店接收
  BEGIN
    DECLARE @PYTOTAL MONEY
  	
    SELECT @SRCNUM = SRCNUM, @PYTOTAL = PYTOTAL
  	 FROM NPAY(NOLOCK)
  	WHERE ID = @BILL_ID AND SRC = @SRC_ID
  	
  	IF NOT EXISTS(SELECT 1 FROM PAY WHERE NUM = @SRCNUM)
    BEGIN
  	  SET @MSG = '原单据' + @SRCNUM + '不存在或已被删除'
  	  RETURN 7
    END 

    /*UPDATE PAY SET PYTOTAL = @PYTOTAL
      WHERE NUM = @SRCNUM*/
    if @NET_STAT = 1  --回写付款金额
    begin 
     UPDATE PAY SET PYTOTAL = @PYTOTAL WHERE NUM = @SRCNUM
    end else --单据在结算中心被冲单
    begin
     SELECT @MAX_NUM = MAX(NUM) FROM PAY(NOLOCK)  
      if @MAX_NUM IS NULL SELECT @NEW_NUM = '0000000001'  
     else  
      EXECUTE NEXTBN @ABN = @MAX_NUM, @NEWBN = @NEW_NUM output
     --在门店执行冲单操作  
      EXEC @VRET = PAYDLTNUM @SRCNUM,1,@NEW_NUM
      IF @VRET > 0 RETURN @VRET
    end
  END
  DELETE FROM NPAY WHERE ID = @BILL_ID AND SRC = @SRC_ID  
  UPDATE PAY SET NOTE = @NET_NOTE WHERE NUM = @NET_NUM
    
  SET @MSG = '单据：' + @NET_NUM + '接收成功' + @MSG
  
  RETURN 0
END

GO
