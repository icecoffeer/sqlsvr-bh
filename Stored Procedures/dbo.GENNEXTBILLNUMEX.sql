SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GENNEXTBILLNUMEX]
	@PICLS	VARCHAR(10),
	@PIBILL	VARCHAR(100),
	@PONEWNUM VARCHAR(14) OUTPUT
AS
BEGIN
	DECLARE 
	@V_CMD		VARCHAR(255) 
	,@V_STORECODE	CHAR(10) 
	,@V_STOREGID	INT 
	,@V_MONTHFLAG VARCHAR(6) 
  	,@V_NUM       VARCHAR(14) 
  	,@V_RET		INT 

	SELECT @V_MONTHFLAG = RTRIM(CONVERT(CHAR(6),GETDATE(), 12)) 
	SELECT @V_STORECODE = USERCODE,@V_STOREGID = USERGID FROM SYSTEM 
	SELECT @V_STORECODE = RIGHT('0000' + LTRIM(RTRIM(@V_STORECODE)), 4)

  	IF (@PICLS IS NULL) OR (RTRIM(@PICLS) = '')  
    	SELECT @V_CMD = 'DECLARE CUR_GETNEXTBILLNUMEX CURSOR FOR SELECT MAX(NUM) FROM '
		+ @PIBILL + ' WHERE NUM LIKE ''' + rtrim(@V_STORECODE) + @V_MONTHFLAG +'%''' 
  	ELSE
	   	SELECT @V_CMD = 'DECLARE CUR_GETNEXTBILLNUMEX CURSOR FOR SELECT MAX(NUM) FROM ' 
		+ @PIBILL + ' WHERE CLS = ''' + @PICLS + ''' AND NUM LIKE ''' + rtrim(@V_STORECODE) + @V_MONTHFLAG +'%''' 

	EXEC(@V_CMD)
	OPEN CUR_GETNEXTBILLNUMEX
	FETCH NEXT FROM CUR_GETNEXTBILLNUMEX INTO @V_NUM
	IF @@FETCH_STATUS = 0 
	BEGIN
		IF @V_NUM IS NULL OR SUBSTRING(@V_NUM, 5, 6) <> @V_MONTHFLAG  
			SELECT @V_NUM = rtrim(@V_STORECODE) + @V_MONTHFLAG + '0000' 
	END ELSE BEGIN
		SELECT @V_NUM =rtrim(@V_STORECODE) + @V_MONTHFLAG + '0000' 
	END
	CLOSE CUR_GETNEXTBILLNUMEX
	DEALLOCATE CUR_GETNEXTBILLNUMEX

	EXEC @V_RET = NEXTBN2 @V_NUM, @PONEWNUM OUTPUT
	RETURN(@V_RET) 
END
GO
