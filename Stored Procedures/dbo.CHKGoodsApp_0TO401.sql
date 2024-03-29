SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CHKGoodsApp_0TO401]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
	--TODO: 检查如果之前该门店已经有对这个商品的修改申请，那么必须要等到前一张申请批准或者作废后，才可以再次申请
	DECLARE @APPMODE VARCHAR(4)
	DECLARE @MODNUM VARCHAR(14), @OTHERBILL VARCHAR(14)
	DECLARE @GDDUMPDUJ INT
	SELECT @APPMODE = APPMODE FROM GOODSAPP WHERE NUM = @NUM
	SELECT @MODNUM = ISNULL(MODNUM,'') FROM GOODSAPP WHERE NUM = @NUM
	IF @APPMODE='修改'
	BEGIN
	  SET @OTHERBILL = ''
	  SELECT @OTHERBILL = MST.NUM FROM GOODSAPPDTL DTL(NOLOCK), GOODSAPP MST(NOLOCK)
		WHERE MST.NUM = DTL.NUM AND MST.NUM <> @NUM
		AND MST.NUM <> @MODNUM AND MST.STAT = 401
		AND ((DEADDATE IS NULL)
		  OR ((DEADDATE IS NOT NULL) AND (DEADDATE > CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )))
		AND DTL.CODE IN( SELECT CODE FROM GOODSAPPDTL(NOLOCK) WHERE NUM = @NUM )
	  IF RTRIM(@OTHERBILL) <> ''
	  BEGIN
		SET @MSG = '该单据中有商品正在被单据['+@OTHERBILL+']申请修改或者删除中，不能修改状态为请求总部批准。'
		RETURN 1
	  END
	END
	IF @APPMODE='删除'
	BEGIN
	  SET @OTHERBILL = ''
	  SELECT @OTHERBILL = MST.NUM   --, MST2.NUM, DTL.CODE, DTL2.CODE , LAC.STOREGID, LAC2.STOREGID
		FROM GOODSAPPDTL DTL(NOLOCK), GOODSAPP MST(NOLOCK), GOODSAPPLAC LAC(NOLOCK),
     		GOODSAPPDTL DTL2(NOLOCK), GOODSAPP MST2(NOLOCK), GOODSAPPLAC LAC2(NOLOCK)
		WHERE MST.APPMODE = '删除'
		AND MST.NUM = DTL.NUM AND LAC.NUM = MST.NUM
		AND MST2.NUM = DTL2.NUM AND LAC2.NUM = MST2.NUM
		AND MST.NUM <> @NUM AND MST.NUM <> @MODNUM AND MST.STAT = 401
		AND MST2.NUM = @NUM
		AND ((MST.DEADDATE IS NULL)
		  OR ((MST.DEADDATE IS NOT NULL)
		    AND (MST.DEADDATE > CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )))
		AND DTL2.CODE = DTL.CODE AND LAC2.STOREGID = LAC.STOREGID
	  IF RTRIM(@OTHERBILL) <> ''
	  BEGIN
		SET @MSG = '该单据中有商品正在被单据['+@OTHERBILL+']申请删除中，不能修改状态为请求总部批准。'
		RETURN 1
	  END
	  SET @OTHERBILL = ''
	  SELECT @OTHERBILL = MST.NUM FROM GOODSAPPDTL DTL(NOLOCK), GOODSAPP MST(NOLOCK)
		WHERE MST.APPMODE = '修改' AND MST.NUM = DTL.NUM AND MST.NUM <> @NUM
		AND MST.NUM <> @MODNUM AND MST.STAT = 401
		AND ((MST.DEADDATE IS NULL)
		  OR ((MST.DEADDATE IS NOT NULL)
		    AND (MST.DEADDATE > CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )))
		AND DTL.CODE IN( SELECT CODE FROM GOODSAPPDTL(NOLOCK) WHERE NUM = @NUM )
	  IF RTRIM(@OTHERBILL) <> ''
	  BEGIN
		SET @MSG = '该单据中有商品正在被单据['+@OTHERBILL+']申请修改中，不能修改状态为请求总部批准。'
		RETURN 1
	  END
	END
	IF @APPMODE = '新增'
	BEGIN
	  SET @OTHERBILL = ''
	  EXEC OPTREADINT 563, 'GDDUMPDUJ', 0, @GDDUMPDUJ OUTPUT
	  IF @GDDUMPDUJ = 0
	     SELECT @OTHERBILL = MST.NUM FROM GOODSAPPDTL DTL(NOLOCK), GOODSAPP MST(NOLOCK)
		WHERE MST.NUM = DTL.NUM AND MST.NUM <> @NUM AND MST.NUM <> @MODNUM AND MST.STAT = 401
		AND DTL.NAME IN( SELECT NAME FROM GOODSAPPDTL(NOLOCK) WHERE NUM = @NUM )
		AND ((MST.DEADDATE IS NULL)
		  OR ((MST.DEADDATE IS NOT NULL)
		    AND (MST.DEADDATE > CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )))
          ELSE
	     SELECT @OTHERBILL = MST.NUM FROM GOODSAPPDTL DTL(NOLOCK), GOODSAPP MST(NOLOCK)
		WHERE MST.NUM = DTL.NUM AND MST.NUM <> @NUM AND MST.NUM <> @MODNUM AND MST.STAT = 401
		AND LTRIM(RTRIM(DTL.NAME)) + LTRIM(RTRIM(DTL.MCODE)) IN
		  ( SELECT LTRIM(RTRIM(NAME)) + LTRIM(RTRIM(MCODE)) FROM GOODSAPPDTL(NOLOCK) WHERE NUM = @NUM )
		AND ((MST.DEADDATE IS NULL)
		  OR ((MST.DEADDATE IS NOT NULL)
		    AND (MST.DEADDATE > CONVERT(DATETIME, CONVERT(CHAR(10),GETDATE(),102)) )))
	  IF RTRIM(@OTHERBILL) <> ''
	  BEGIN
		SET @MSG = '该单据中有新商品(名称相同)正在被单据['+@OTHERBILL+']申请中，不能修改单据状态为请求总部批准。'
		RETURN 1
	  END
	END
	UPDATE GoodsApp SET
		STAT = 401,
		CHKDATE = GETDATE(),
		CHECKER = @OPER,
		LSTUPDTIME = GETDATE()
	WHERE NUM = @NUM
	EXEC GOODSAPPADDLOG @NUM,401,'',@OPER
	RETURN 0
END
GO
