SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GoodsAppApplyDEL]
(
  @NUM CHAR(14),
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	DECLARE @STAT INT, @I INT, @SSQL VARCHAR(255), @USERGID INT, @USERPROPERTY INT, @APPMODE VARCHAR(20)
	DECLARE @GDCODE VARCHAR(20), @RATFLAG INT,
			@TMSG VARCHAR(100), @GID INT,
			@SUCCNT INT, @RET INT
    DECLARE @STOREGID INT,
  	        @SINGLEVDR SMALLINT,
            @QTY MONEY,
            @QTYAMT MONEY
	SET @RATFLAG = 0
	SET @SUCCNT = 0
	SET @MSG = ''
	SET @RET = 0
	SELECT @USERGID = USERGID FROM SYSTEM
	SELECT @USERPROPERTY = PROPERTY FROM STORE WHERE GID = @USERGID

	SELECT @STAT = STAT, @APPMODE = RTRIM(APPMODE) FROM GOODSAPP WHERE NUM = @NUM
	IF @APPMODE<>'删除'
	BEGIN
		SET @MSG = '单据更新模式不是删除'
		RAISERROR('单据更新模式不是删除',16,1)
		RETURN(-1)
	END
	IF NOT EXISTS(SELECT 1 FROM GOODSAPPLAC WHERE STOREGID = @USERGID AND NUM = @NUM)
	BEGIN
		SET @MSG = '生效单位中无本单位'
		RETURN(0)
	END
    IF OBJECT_ID('C_C') IS NOT NULL DEALLOCATE C_GFTSND
	DECLARE C_C CURSOR FOR
		SELECT CODE, GID FROM GOODSAPPDTL WHERE NUM = @NUM AND RATFLAG = 1
	OPEN C_C
	FETCH NEXT FROM C_C INTO @GDCODE, @GID
	WHILE @@FETCH_STATUS=0
	BEGIN
        SET @GDCODE = RTRIM(@GDCODE)
		SET @TMSG = ''
		--CHECK EXISTS
		IF NOT EXISTS(SELECT 1 FROM GOODS(NOLOCK) WHERE GID = @GID)
		BEGIN
			SET @TMSG = '该商品（内码）不存在'
			SET @MSG = @MSG + '[' + @GDCODE + ']' + @TMSG
		    UPDATE GOODSAPPDTL SET NOTE = @TMSG WHERE NUM = @NUM AND GID = @GID
		    FETCH NEXT FROM C_C INTO @GDCODE, @GID
		    CONTINUE
		END
		--CHECK TO DEL
		EXEC @RET = GoodsAppCheckCanDel @GID, @TMSG OUTPUT
		IF @RET<>0
		BEGIN
			SET @MSG = @MSG + '[' + @GDCODE + ']' + @TMSG
		    UPDATE GOODSAPPDTL SET NOTE = @TMSG WHERE NUM = @NUM AND GID = @GID
		    FETCH NEXT FROM C_C INTO @GDCODE, @GID
		    CONTINUE
		END
        --DELETE
        DELETE FROM GOODS WHERE GID = @GID
		IF @@ERROR <> 0
		BEGIN
			CLOSE C_C
			DEALLOCATE C_C
			RAISERROR('删除商品时发生错误。',16,1)
			RETURN(1)
		END
		SET @SUCCNT = @SUCCNT + 1
		FETCH NEXT FROM C_C INTO @GDCODE, @GID
	END
	CLOSE C_C
	DEALLOCATE C_C
	IF @MSG<>''
		SET @RET = 1
	ELSE
		SET @RET = 0
	SELECT @MSG = '要删除'+ CONVERT(VARCHAR,COUNT(1)) +'条，成功删除'+ CONVERT(VARCHAR,@SUCCNT) +'条。其中：'+@MSG
		FROM GOODSAPPDTL WHERE NUM = @NUM AND RATFLAG = 1
	UPDATE GOODSAPP SET NOTE = NOTE+ ' ' + @MSG WHERE NUM = @NUM
	RETURN 0
END
GO
