SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ChgBookDlt]
(
  @NUM	CHAR(14),
  @OPER	CHAR(30),
  @CLS	CHAR(10),  /* IS NULL 表示发送；IS NOT NULL 表示不发送 */
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
begin
	DECLARE @VVDRGID	INT
	DECLARE @VSTAT		INT
	DECLARE @VREALAMT	INT
	DECLARE @VRET		INT
	DECLARE @VGATHERINGMODE	CHAR(10)
	DECLARE	@VPAYTOTAL	MONEY
	DECLARE @SNDTIME DATETIME

	SELECT @VVDRGID = BILLTO,
		@VSTAT = STAT,
		@VREALAMT = REALAMT,
		@VGATHERINGMODE = GATHERINGMODE,
		@VPAYTOTAL = PAYTOTAL,
		@SNDTIME = SNDTIME
	FROM CHGBOOK(NOLOCK)
	WHERE NUM = @NUM
	
	IF @@ROWCOUNT = 0
	BEGIN
		SET @MSG = '费用单' + @NUM + '不存在.'
		RETURN 1
	END

	IF @VSTAT <> 500
	BEGIN
	    SET @MSG = '作废的不是已审核的单据.'
	    RETURN 1
	END
	
	IF @VPAYTOTAL > 0
	BEGIN
	    SET @MSG = '单据已被付款单或交款单录入并回写.'
	    RETURN 1
	END
  --090422 振华统一结算相关
  IF @VGATHERINGMODE = '冲扣货款' and EXISTS (SELECT 1 FROM CNTRPAYCASH a(NOLOCK),CNTRPAYCASHDTL B(NOLOCK)
    WHERE a.NUM = b.NUM AND a.STAT IN (100,900) AND b.chgtype = '费用单' and b.ivccode = @NUM)
  BEGIN
      SET @MSG = '单据已被付款单引用,不能作废.'
      RETURN 1
  END

	IF @SNDTIME IS NOT NULL 
	BEGIN
	    SET @MSG = '单据已经发送，不能作废.'
	    RETURN 1
	END
	
	UPDATE CHGBOOK SET
		STAT = 510,
		LSTUPDTIME = GETDATE(),
		NOTE = RTRIM(NOTE) + '作废人：' + @OPER
	WHERE NUM = @NUM
	--Fanduoyi 1298
	INSERT INTO CHGBOOKLOG(num, stat, modifier, time)
		VALUES(@num, 510, @oper, getdate())
		

	IF @CLS IS NULL OR @CLS = ''
	BEGIN
	  EXEC @VRET = CHKCHGBOOK_SEND @NUM, @OPER, @MSG OUTPUT
	  IF @VRET <= 0 SET @VRET = 0
	END
	       
	RETURN @VRET
END
GO