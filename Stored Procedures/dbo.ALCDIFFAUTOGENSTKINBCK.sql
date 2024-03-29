SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[ALCDIFFAUTOGENSTKINBCK]
(
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER CHAR(30),		-- '0'-生成未审核的单据;'1'-生成已审核的单据
  @MSG VARCHAR(255) OUTPUT
) --WITH ENCRYPTION		-- RETURN ERROR FROM 700
AS
BEGIN
DECLARE
  	@PNUM CHAR(14),		@CLS CHAR(10),
  	@NUM CHAR(14),		@SETTLENO INT,
  	@ZBGID INT,		@FILLERCODE VARCHAR(20),
  	@FILLER INT, 		@FILLERNAME VARCHAR(50),
  	@PRICETYPE CHAR(20),  	@LINE INT,
  	@INPRCTAX INT, 		@TOTAL MONEY,
 	@RECCNT INT,		@TAX MONEY,
 	@STAT INT,		@ACTION CHAR(100),
  	@CLIENTNAME CHAR(50),	@RE INT

	IF NOT EXISTS(SELECT 1 FROM NALCDIFF M(NOLOCK), NALCDIFFDTL D(NOLOCK) WHERE M.STAT = 400
  	  AND M.ATTITUDE = 0 AND D.QTY < 0 AND M.ID = D.ID AND M.ID = @BILL_ID
  	  AND M.SRC = @SRC_ID AND M.SRC = D.SRC
  	  AND EXISTS(SELECT 1 FROM HDOPTION(NOLOCK) WHERE OPTIONCAPTION = '配货退货单据顺序'
            AND OPTIONVALUE = '0')) RETURN 0

	SELECT @PNUM = NUM, @STAT = STAT FROM NALCDIFF(NOLOCK) WHERE ID = @BILL_ID AND SRC = @SRC_ID

	SET @CLS = '配货'

	DECLARE @NUMMID VARCHAR(10),@NUMRIGHT VARCHAR(10),@NUMLEFT CHAR(10)
	SELECT @NUM = MAX(NUM) FROM STKINBCK WHERE CLS = @CLS
	SET @NUMRIGHT = LTRIM(STR(RIGHT(@NUM,9) + 1))
	SET @NUMMID = SUBSTRING('0000000000',1,9 - LEN(@NUMRIGHT))
	SET @NUMLEFT = LEFT(@NUM,1)
	SET @NUM = RTRIM(@NUMLEFT) + RTRIM(@NUMMID) + RTRIM(@NUMRIGHT)
 	IF @NUM IS NULL SET @NUM = '0000000001'

	SELECT @SETTLENO =  MAX(NO) FROM MONTHSETTLE(NOLOCK)

	SELECT @ZBGID = ZBGID FROM SYSTEM(NOLOCK)

	--取得当前用户
	SET @FILLERCODE = SUSER_SNAME()
	WHILE CHARINDEX('_',@FILLERCODE) <> 0
	BEGIN
	  SET @FILLERCODE = SUBSTRING(@FILLERCODE, CHARINDEX('_', @FILLERCODE) + 1, LEN(@FILLERCODE))
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

	INSERT INTO STKINBCKDTL(CLS,NUM,LINE,SETTLENO,GDGID,CASES,QTY,
	PRICE,TOTAL,TAX,WRH,INPRC,RTLPRC,VALIDDATE,SUBWRH,NOTE,COST,BNUM)
	SELECT @CLS,@NUM,D.LINE,@SETTLENO,D.GDGID,ABS(D.CASES),ABS(D.QTY),
	0,0,0,D.WRH,0,0,NULL,NULL,D.NOTE,0,0
	FROM NALCDIFFDTL D(NOLOCK),NALCDIFF M(NOLOCK) WHERE D.ID = @BILL_ID AND D.SRC = @SRC_ID
	  AND M.STAT = 400 AND M.ATTITUDE = 0 AND D.QTY < 0 AND M.NUM = D.NUM

	IF @@ERROR <> 0
    	BEGIN
        	SET @MSG = '由配货差异单：' + @PNUM + '生成配货进货退货单失败'
        	RETURN 701
    	END

	-- 更新LINE
	DECLARE @I INT
	SET @I = 1
	DECLARE C_LINE CURSOR FOR
	SELECT LINE FROM STKINBCKDTL(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS
	OPEN C_LINE
	FETCH NEXT FROM C_LINE
	INTO @LINE
	WHILE @@FETCH_STATUS = 0
	BEGIN
	  UPDATE STKINBCKDTL SET LINE = @I WHERE NUM = @NUM AND CLS = @CLS AND LINE = @LINE
	  SET @I = @I + 1
	  FETCH NEXT FROM C_LINE
	  INTO @LINE
	END
	DEALLOCATE C_LINE

	-- 更新 STKINBCKDTL 中的INPRC,RTLPRC
	UPDATE STKINBCKDTL
	SET INPRC = B.INPRC, RTLPRC = B.RTLPRC
	FROM STKINBCKDTL A, GOODS B
	WHERE A.GDGID = B.GID AND A.NUM = @NUM AND CLS = @CLS


	-- 更新 STKINBCKDTL 中的PRICE
	EXEC('UPDATE STKINBCKDTL SET PRICE = B.'
	  + @PRICETYPE + ' FROM STKINBCKDTL A, GOODS B
	  WHERE A.GDGID = B.GID AND A.CLS = '''+ @CLS + ''' AND A.NUM = ''' + @NUM + ''' ')


	--是否去税
	  SELECT @INPRCTAX = INPRCTAX FROM [SYSTEM](NOLOCK)
	  IF @INPRCTAX = 1
	  BEGIN
	    -- 更新 STKINBCKDTL 中的TOTAL
	    UPDATE STKINBCKDTL
	    SET TOTAL = PRICE * QTY
	    WHERE NUM = @NUM AND CLS = @CLS
	    --更新 STKINBCKDTL 中的TAX
	    UPDATE STKINBCKDTL
	    SET TAX = A.TOTAL - ROUND(A.TOTAL/(1+ (B.TAXRATE/100)), 4)
	    FROM STKINBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @NUM AND A.CLS = @CLS
	  END ELSE
	  BEGIN
	    --更新 STKINBCKDTL 中的TAX
	    UPDATE STKINBCKDTL
	    SET TAX = ROUND(QTY*(
	      A.PRICE - A.PRICE /(1+ (GD.TAXRATE/100))
	      ),4)
	    FROM GOODS GD(NOLOCK) , STKINBCKDTL A
	    WHERE GD.GID = A.GDGID AND A.NUM = @NUM AND A.CLS = @CLS
	    -- 更新 STKINBCKDTL 中的TOTAL
	    UPDATE STKINBCKDTL
	    SET TOTAL =ROUND(PRICE /(1+ (TAXRATE/100)) * QTY, 4)
	    FROM STKINBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @NUM AND A.CLS = @CLS
	    --去税则重算PRICE
	    UPDATE STKINBCKDTL
	    SET PRICE = ROUND(PRICE /(1+ (TAXRATE/100)), 4)
	    FROM STKINBCKDTL A, GOODS B
	    WHERE A.GDGID = B.GID AND A.NUM = @NUM AND A.CLS = @CLS
	  END


	INSERT INTO STKINBCK(CLS,NUM,SETTLENO,VENDOR,VENDORNUM,
	BILLTO,OCRDATE,TOTAL,TAX,NOTE,FILDATE,FILLER,CHECKER,
	STAT,MODNUM,PSR,RECCNT,SRC,SRCNUM,SNDTIME,PRNTIME,FINISHED,
	CHKDATE,WRH,PRECHECKER,PRECHKDATE,GEN,GENBILL,GENCLS,GENNUM)
	SELECT @CLS,@NUM,@SETTLENO,@ZBGID,RIGHT(@PNUM,10),M.BILLTO,GETDATE(),0,0,
	M.NOTE + '(由配货差异单['+ @PNUM +']导入)',GETDATE(),@FILLER,1,0,NULL,@FILLER,
	0,M.CLIENT,NULL,NULL,NULL,0,NULL,M.WRH,NULL,NULL,NULL,NULL,'配货差异单',@PNUM
	FROM NALCDIFF M(NOLOCK) WHERE M.NUM = @PNUM AND M.STAT = 400 AND M.ATTITUDE = 0

	IF @@ERROR <> 0
    	BEGIN
        	SET @MSG = '由配货差异单：' + @PNUM + '生成配货进货退货单失败'
        	RETURN 702
    	END


	--和计 STKINBCK 表中TOTAL,TAX
	SELECT @TOTAL = SUM(TOTAL), @TAX = SUM(TAX)
	FROM STKINBCKDTL(NOLOCK)
	WHERE NUM = @NUM AND CLS = @CLS

	--更新 STKINBCK 中的TOTAL, TAX
	UPDATE STKINBCK
	SET TOTAL = @TOTAL, TAX = @TAX
	WHERE NUM = @NUM AND CLS = @CLS

	--更新STKINBCK中的RECCNT
	SELECT @RECCNT = COUNT(*) FROM STKINBCKDTL(NOLOCK) WHERE NUM = @NUM AND CLS = @CLS
	UPDATE STKINBCK SET RECCNT = @RECCNT WHERE NUM = @NUM  AND CLS = @CLS

	--如果@OPER为1,生成已审核的单据
	IF @OPER = '1'
	BEGIN
	  EXEC @RE = STKINBCKCHK @CLS, @NUM, 0  /*2005-05-30*/
	  IF @RE <> 0 RETURN @RE
	  SET @ACTION = '门店接收时自动生成已审核的配货进货退货单：' + @NUM
	END
	ELSE SET @ACTION = '门店接收时自动生成未审核的配货进货退货单：' + @NUM

	SELECT @CLIENTNAME = B.NAME FROM NALCDIFF A(NOLOCK), STORE B(NOLOCK)
	WHERE A.CLIENT = B.GID AND A.ID = @BILL_ID AND A.SRC = @SRC_ID

	UPDATE ALCDIFF SET GENNOTE = GENNOTE + '[' + RTRIM(@CLIENTNAME) + '] 自动生成配货进货退货单：' + RTRIM(@NUM) + '; '
	WHERE NUM = @PNUM

	EXEC ALCDIFFADDLOG @PNUM, @STAT, @ACTION, ''

        SET @MSG = '由配货差异单：' + @PNUM + '生成配货进货退货单成功'

	RETURN 0

END
GO
