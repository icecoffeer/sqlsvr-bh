SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKGoodsApp_1600TO400]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @STAT INT, @I INT, @SSQL VARCHAR(255), @USERGID INT, @USERPROPERTY INT, @APPMODE VARCHAR(20),
	        @SRC INT
	SELECT @USERGID = USERGID FROM SYSTEM
	SELECT @USERPROPERTY = PROPERTY FROM STORE WHERE GID = @USERGID
	SELECT @STAT = STAT, @APPMODE = RTRIM(APPMODE), @SRC = SRC FROM GOODSAPP WHERE NUM = @NUM
	IF @USERPROPERTY & 16 <> 16
	BEGIN
		SET @MSG = '非总部不能批准'
		RAISERROR('非总部不能批准',16,1)
		RETURN(-1)
	END
	UPDATE GoodsApp SET
		STAT = 400,
		RATDATE = GETDATE(),
		RATOPER = @OPER,  --审批人
		LSTUPDTIME = GETDATE()
	WHERE NUM = @NUM
	EXEC GOODSAPPAPPLY @NUM, @MSG OUTPUT
	IF @@ERROR<>0
	BEGIN
		SET @MSG = '生效时错误:' + @MSG
		RAISERROR(@MSG,16,1)
		RETURN(-2)
	END
	UPDATE GOODSAPPDTL SET FLAG = 1 WHERE NUM = @NUM
	EXEC GOODSAPPADDLOG @NUM,400,'',@OPER
	RETURN 0
END
GO
