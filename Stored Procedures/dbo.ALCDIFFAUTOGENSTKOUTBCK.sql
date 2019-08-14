SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCDIFFAUTOGENSTKOUTBCK]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) --WITH ENCRYPTION		-- RETURN ERROR FROM 800
AS
BEGIN
DECLARE
	@GNUM CHAR(14),		@CLS CHAR(10),
	@SETTLENO INT,		@VENDOR INT,
   	@FILLERCODE VARCHAR(20),@FILLER INT,
   	@FILLERNAME VARCHAR(50),@PRICETYPE CHAR(20),
   	@LINE INT,@INPRCTAX INT,@TOTAL MONEY,
   	@RECCNT INT,		@TAX MONEY,
   	@STAT INT,		@ACTION CHAR(100),
   	@ZBGID INT,		@NUM10 CHAR(14),
   	@ZBNAME CHAR(50),	@RE INT

	IF NOT EXISTS(SELECT 1 FROM ALCDIFF M(NOLOCK), ALCDIFFDTL D(NOLOCK) WHERE M.STAT = 400
	  AND M.ATTITUDE = 0 AND D.QTY < 0 AND M.NUM = D.NUM AND M.NUM = @NUM
	  AND EXISTS(SELECT 1 FROM HDOPTION(NOLOCK) WHERE OPTIONCAPTION = '配货退货单据顺序'
	    AND OPTIONVALUE = '1')) RETURN 0

	SELECT @STAT = STAT FROM ALCDIFF(NOLOCK) WHERE NUM = @NUM

	SET @CLS = '配货'
	SET @NUM10 = RIGHT(@NUM, 10)

  	DECLARE @NUMMID VARCHAR(10),@NUMRIGHT VARCHAR(10),@NUMLEFT CHAR(10)
	SELECT @GNUM = MAX(NUM) FROM STKOUTBCK WHERE CLS = @CLS
	SET @NUMRIGHT = LTRIM(STR(RIGHT(@GNUM,9) + 1))
	SET @NUMMID = SUBSTRING('0000000000',1,9 - LEN(@NUMRIGHT))
	SET @NUMLEFT = LEFT(@GNUM,1)
	SET @GNUM = RTRIM(@NUMLEFT) + RTRIM(@NUMMID) + RTRIM(@NUMRIGHT)
 	IF @GNUM IS NULL SET @GNUM = '0000000001'

	SELECT @SETTLENO =  MAX(NO) FROM MONTHSETTLE(NOLOCK)

	SELECT @VENDOR = ZBGID FROM SYSTEM(NOLOCK)

	SELECT @ZBGID = ZBGID FROM SYSTEM(NOLOCK)

	--取得当前用户
	SET @FILLERCODE = SUSER_SNAME()
	WHILE CHARINDEX('_',@FILLERCODE) <> 0
	BEGIN
	  SET @FILLERCODE = SUBSTRING(@FILLERCODE,CHARINDEX('_',@FILLERCODE) + 1,LEN(@FILLERCODE))
	END
	SELECT @FILLER = GID, @FILLERNAME = NAME FROM EMPLOYEE(NOLOCK) WHERE CODE LIKE @FILLERCODE
	IF @FILLERNAME IS NULL
	BEGIN
	  SET @FILLERCODE = '-'
	  SET @FILLERNAME = '未知'
	END

	--取得商品价格种类
	EXEC OPTREADINT 43, 'PRICETYPE', 0, @PRICETYPE OUTPUT

	SELECT @PRICETYPE =
	  CASE @PRICETYPE
	    WHEN '0' THEN    'LSTINPRC'
	    WHEN '1' THEN    'INPRC'
	    WHEN '2' THEN    'RTLPRC'
	    WHEN '3' THEN    'CNTINPRC'
	    WHEN '4' THEN    'WHSPRC'
	    WHEN '5' THEN    'INVPRC'
	    WHEN '6' THEN    'LWTRTLPRC'
	    WHEN '7' THEN    'OLDINVPRC'
	    WHEN '8' THEN    'MBRPRC'
	    WHEN '9' THEN    'MKTINPRC'
	    WHEN '10' THEN   'MKTRTLPRC'
	    ELSE 'INPRC'
	  END

	INSERT INTO STKOUTBCKDTL(CLS,NUM,LINE,SETTLENO,GDGID,CASES,QTY,
	WSPRC,PRICE,TOTAL,TAX,WRH,INPRC,RTLPRC,VALIDDATE,SUBWRH,
	RCPQTY,RCPAMT,NOTE,ITEMNO,COST,QPCGID,QPCQTY,COSTPRC)
	SELECT @CLS,@GNUM,D.LINE,@SETTLENO,D.GDGID,ABS(D.CASES),ABS(D.QTY),
	0,0,0,0,D.WRH,0,0,NULL,NULL,0,0,D.NOTE,NULL,0,NULL,NULL,0
	FROM ALCDIFFDTL D(NOLOCK),ALCDIFF M(NOLOCK) WHERE M.NUM = @NUM AND M.NUM = D.NUM
	AND M.STAT = 400 AND M.ATTITUDE = 0 AND D.QTY < 0

	IF @@ERROR <> 0
    	BEGIN
        	SET @MSG = '由配货差异单：' + @NUM + '生成配货出货退货单失败'
        	RETURN 801
    	END

	-- 更新LINE
	DECLARE @I INT
	SET @I = 1
	DECLARE C_LINE CURSOR FOR
	SELECT LINE FROM STKOUTBCKDTL(NOLOCK) WHERE NUM = @GNUM AND CLS = @CLS
	OPEN C_LINE
	FETCH NEXT FROM C_LINE
	INTO @LINE
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  UPDATE STKOUTBCKDTL SET LINE = @I WHERE NUM = @GNUM AND CLS = @CLS AND LINE = @LINE
	  SET @I = @I + 1
	  FETCH NEXT FROM C_LINE
	  INTO @LINE
	END
	DEALLOCATE C_LINE

	-- 更新 STKOUTBCKDTL 中的INPRC,RTLPRC
	UPDATE STKOUTBCKDTL
	SET INPRC = B.INPRC, RTLPRC = B.RTLPRC
	FROM STKOUTBCKDTL A, GOODS B
	WHERE A.GDGID = B.GID AND A.NUM = @GNUM AND CLS = @CLS


	-- 更新 STKOUTBCKDTL 中的PRICE
	EXEC(' UPDATE STKOUTBCKDTL SET PRICE = B.'
	  + @PRICETYPE + ' FROM STKOUTBCKDTL A, GOODS B WHERE A.GDGID = B.GID AND A.CLS = '''+@CLS+''' AND A.NUM ='''+@GNUM+''' ')


	--是否去税
	  SELECT @INPRCTAX = INPRCTAX FROM [SYSTEM](NOLOCK)
	  IF @INPRCTAX = 1
	  BEGIN
	    -- 更新 STKOUTBCKDTL 中的TOTAL
	    UPDATE STKOUTBCKDTL
	    SET TOTAL = PRICE * QTY
	    WHERE NUM = @GNUM AND CLS = @CLS
	    --更新 STKOUTBCKDTL 中的TAX
	    UPDATE STKOUTBCKDTL
	    SET TAX = A.TOTAL - ROUND(A.TOTAL/(1+ (B.TAXRATE/100)), 4)
	    FROM STKOUTBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @GNUM AND A.CLS = @CLS
	  END ELSE
	  BEGIN
	    --更新 STKOUTBCKDTL 中的TAX
	    UPDATE STKOUTBCKDTL
	    SET TAX = ROUND(QTY*(
	      A.PRICE - A.PRICE /(1+ (GD.TAXRATE/100))
	      ),4)
	    FROM GOODS GD(NOLOCK) , STKOUTBCKDTL A
	    WHERE GD.GID = A.GDGID AND A.NUM = @GNUM AND A.CLS = @CLS
	    -- 更新 STKOUTBCKDTL 中的TOTAL
	    UPDATE STKOUTBCKDTL
	    SET TOTAL =ROUND(PRICE /(1+ (TAXRATE/100)) * QTY, 4)
	    FROM STKOUTBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @GNUM AND A.CLS = @CLS
	    --去税则重算PRICE
	    UPDATE STKOUTBCKDTL
	    SET PRICE = ROUND(PRICE /(1+ (TAXRATE/100)), 4)
	    FROM STKOUTBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @GNUM AND A.CLS = @CLS
	  END


	INSERT INTO STKOUTBCK(CLS,NUM,SETTLENO,CLIENT,
	BILLTO,OCRDATE,TOTAL,TAX,NOTE,FILDATE,FILLER,CHECKER,
	STAT,MODNUM,SLR,RECCNT,SRC,SRCNUM,SNDTIME,PRNTIME,FINISHED,
	WRH,PAYMODE,PRECHECKER,PRECHKDATE,GEN,GENBILL,GENCLS,GENNUM)
	SELECT @CLS,@GNUM,@SETTLENO,M.CLIENT,M.BILLTO,GETDATE(),0,0,
	M.NOTE + '(由配货差异单['+ @NUM +']导入)',GETDATE(),@FILLER,1,
	0,NULL,1,0,@ZBGID,NULL,NULL,NULL,0,M.WRH,NULL,NULL,NULL,NULL,NULL,'配货差异单',@NUM
	FROM ALCDIFF M(NOLOCK) WHERE M.NUM = @NUM AND M.STAT = 400 AND M.ATTITUDE = 0

	IF @@ERROR <> 0
    	BEGIN
        	SET @MSG = '由配货差异单：' + @NUM + '生成配货出货退货单失败'
        	RETURN 802
    	END

	--和计 STKOUTBCK 表中TOTAL,TAX
	SELECT @TOTAL = SUM(TOTAL), @TAX = SUM(TAX)
	FROM STKOUTBCKDTL(NOLOCK)
	WHERE NUM = @GNUM AND CLS = @CLS

	--更新 STKOUTBCK 中的TOTAL, TAX
	UPDATE STKOUTBCK
	SET TOTAL = @TOTAL, TAX = @TAX
	WHERE NUM = @GNUM AND CLS = @CLS

	--更新STKOUTBCK中的RECCNT
	SELECT @RECCNT = COUNT(*) FROM STKOUTBCKDTL(NOLOCK) WHERE NUM = @GNUM AND CLS = @CLS
	UPDATE STKOUTBCK SET RECCNT = @RECCNT WHERE NUM = @GNUM  AND CLS = @CLS

	--如果@OPER为1,生成已审核的单据
	IF @OPER = '1'
	BEGIN
	  EXEC @RE = STKOUTBCKCHK @CLS, @GNUM, 1, '' /*2005-05-30*/
	  IF @RE <> 0 RETURN @RE
	  SET @ACTION = '总部批准时自动生成已审核的配货出货退货单：' + @GNUM
	END
	ELSE SET @ACTION = '总部批准时自动生成未审核的配货出货退货单：' + @GNUM

	SELECT @ZBNAME = USERNAME FROM SYSTEM(NOLOCK)
	UPDATE ALCDIFF SET GENNOTE = GENNOTE + '[' + RTRIM(@ZBNAME) + '] 自动生成配货出货退货单：' + RTRIM(@GNUM) + '; '
	WHERE NUM = @NUM

	EXEC ALCDIFFADDLOG @NUM, @STAT, @ACTION, ''

	SET @MSG = '由配货差异单：' + @NUM + '生成配货出货退货单成功'
	RETURN 0

END
GO
