SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[OVFFIFOCHK]
	@PI_NUM CHAR(10),
	@PI_LINE INT,
	@PI_WRH INT,
	@PI_GDGID INT,
	@PI_QTY MONEY,
	@PI_TOTAL MONEY,
	@PI_ERRMSG VARCHAR(200) OUTPUT
AS
BEGIN
	DECLARE @AMT MONEY,@NEWSUBWRH INT
		,@SUBWRH INT

	DECLARE @RETURN_STATUS INT

	IF @PI_QTY < 0
	BEGIN
		SELECT @PI_ERRMSG = '不允许为负数'
		RETURN 1005

	END

	EXEC CLEARTEMPSUBWRH @PI_GDGID,@PI_WRH

	IF EXISTS(SELECT 1 FROM OVFDTL2 WHERE  NUM = @PI_NUM AND LINE = @PI_LINE)
	BEGIN
		SELECT @PI_ERRMSG = '溢余单不能指定批次溢余'
		RETURN -1

	END

	EXEC @RETURN_STATUS = LOADINSUBWRH_2 @PI_GDGID,@PI_WRH,@PI_QTY,@PI_TOTAL
	IF @RETURN_STATUS <> 0 RETURN @RETURN_STATUS
	

	INSERT INTO OVFDTL2(NUM,LINE,SUBWRH,WRH,GDGID,QTY,COST,COSTADJ)
		SELECT @PI_NUM,@PI_LINE,SUBWRH,WRH,GDGID,QTY,COST,COSTADJ FROM TEMPSUBWRH
			WHERE SPID = @@SPID AND GDGID = @PI_GDGID AND WRH = @PI_WRH


	SELECT @NEWSUBWRH= MIN(SUBWRH) FROM TEMPSUBWRH WHERE SPID = @@SPID AND WRH = @PI_WRH AND GDGID = @PI_GDGID


	UPDATE OVFDTL SET COST = @PI_TOTAL,SUBWRH = @NEWSUBWRH
		WHERE NUM = @PI_NUM AND LINE = @PI_LINE

	EXEC CLEARTEMPSUBWRH @PI_GDGID,@PI_WRH

	RETURN 0

END
GO
