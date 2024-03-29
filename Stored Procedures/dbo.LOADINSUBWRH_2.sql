SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[LOADINSUBWRH_2]
  @PI_GDGID INT,
  @PI_WRH INT,
  @PI_QTY INT,
  @PI_TOTAL MONEY,
  @PI_LOADMODE INT = 0/*0表示处理负数批次库存，１表示不处理负数批次库存*/

AS
BEGIN
  DECLARE @NEWQTY MONEY, @DSPQTY MONEY, @BCKQTY MONEY,@NEWCOST MONEY
  DECLARE @SUBWRH INT,@CODE CHAR(10)
  DECLARE @ERR VARCHAR(200)
  
  DECLARE @FQTY MONEY,@FCOST MONEY,@FSUBWRH INT--用于负数批次核对
  DECLARE @DIFFCOST MONEY,@LSTINPRC MONEY
  DECLARE @ADATE DATETIME,@SETTLENO INT
  DECLARE @RETURN_STATUS INT

  DECLARE @GETLSTINPRCMODE SMALLINT,@NEWLSTINPRC MONEY
  DECLARE @ADJAMT MONEY

  DECLARE @BILL CHAR(10),  @BILLCLS	CHAR(10),  @BILLNUM	CHAR(10),  @BILLLINE	INT


  IF @PI_QTY = 0 
	RETURN 0

  IF NOT EXISTS(SELECT 1 FROM TEMPSUBWRH WHERE SPID = @@SPID AND WRH = @PI_WRH AND GDGID = @PI_GDGID)
  BEGIN
	IF @PI_QTY<0
	BEGIN
		RAISERROR( '不允许负库存批次入库', 16, 1)
		RETURN 11
	END
	SELECT @LSTINPRC = @PI_TOTAL/@PI_QTY
	--新增SUBWRH和CODE
	EXEC GETSUBWRHBATCH_2 @PI_GDGID,@LSTINPRC,@SUBWRH OUTPUT,@CODE OUTPUT,@ERR OUTPUT
	IF RTRIM(ISNULL(@ERR,'')) <> '' 
	BEGIN
		RAISERROR( @ERR, 16, 1)
		RETURN 11
	END



	INSERT INTO SUBWRHINV( WRH, SUBWRH, CODE, GDGID,QTY,LSTINPRC,COST ) 
		VALUES ( @PI_WRH, @SUBWRH,@CODE,@PI_GDGID,@PI_QTY,@PI_TOTAL/@PI_QTY,@PI_TOTAL)


	INSERT INTO TEMPSUBWRH(SPID,SUBWRH,WRH,GDGID,QTY,COST) 
		VALUES(@@SPID,@SUBWRH,@PI_WRH,@PI_GDGID,@PI_QTY,@PI_TOTAL)
  END
  ELSE
  BEGIN
	--使用旧的SUBWRH，新增CODE
	DECLARE CUR_LOADINSUBWRH CURSOR FOR
		SELECT SUBWRH,QTY,COST,BILL,CLS,NUM,LINE FROM TEMPSUBWRH WHERE SPID = @@SPID AND WRH=@PI_WRH AND GDGID = @PI_GDGID
	OPEN CUR_LOADINSUBWRH
	FETCH NEXT FROM CUR_LOADINSUBWRH INTO @SUBWRH,@PI_QTY,@PI_TOTAL,@BILL,@BILLCLS,@BILLNUM,@BILLLINE
	WHILE @@FETCH_STATUS = 0
	BEGIN
		IF @PI_QTY<0
		BEGIN
			RAISERROR( '不允许负库存批次入库', 16, 1)
			CLOSE CUR_LOADINSUBWRH
			DEALLOCATE CUR_LOADINSUBWRH

			RETURN 11
		END

		SELECT @RETURN_STATUS = 0,@LSTINPRC = @PI_TOTAL / @PI_QTY
		SELECT @NEWLSTINPRC = @LSTINPRC
		EXEC @RETURN_STATUS = INSSUBWRHBATCH_2 @PI_GDGID,@SUBWRH,@CODE OUTPUT,@NEWLSTINPRC OUTPUT,@ERR OUTPUT
		IF @RETURN_STATUS <> 0 
		BEGIN
			RAISERROR( @ERR, 16, 1)
			CLOSE CUR_LOADINSUBWRH
			DEALLOCATE CUR_LOADINSUBWRH
			RETURN 11
		END
		
		EXEC @RETURN_STATUS = GETSUBWRH2LSTINPRC @PI_GDGID,@SUBWRH,@NEWLSTINPRC OUTPUT,@GETLSTINPRCMODE OUTPUT
		IF @RETURN_STATUS <> 0 
		BEGIN
			RAISERROR( @ERR, 16, 1)
			CLOSE CUR_LOADINSUBWRH
			DEALLOCATE CUR_LOADINSUBWRH
			RETURN 11
		END

                IF @BILL IS NOT NULL
                BEGIN
                        SELECT @ADJAMT = SUM(ADJALCAMT) FROM IPA2DTL 
				WHERE BILL = @BILL and BILLCLS = @BILLCLS and BILLNUM = @BILLNUM and BILLLINE = @BILLLINE and SUBWRH = @SUBWRH
			SELECT @PI_TOTAL = @PI_TOTAL + ISNULL(@ADJAMT,0)
			UPDATE TEMPSUBWRH SET COST = COST + ISNULL(@ADJAMT,0) WHERE CURRENT OF CUR_LOADINSUBWRH
                END
		ELSE IF @LSTINPRC <> @NEWLSTINPRC 
		BEGIN
			SELECT @PI_TOTAL = ROUND(@PI_QTY * @NEWLSTINPRC,2)
			UPDATE TEMPSUBWRH SET COST = @PI_TOTAL WHERE CURRENT OF CUR_LOADINSUBWRH
		END

		IF NOT EXISTS ( SELECT * FROM SUBWRHINV WHERE WRH = @PI_WRH AND
			SUBWRH = @SUBWRH AND GDGID = @PI_GDGID )
		BEGIN
			INSERT INTO SUBWRHINV(WRH,SUBWRH,CODE,GDGID) VALUES (@PI_WRH,@SUBWRH,@CODE,@PI_GDGID)
			
		END
		

		SELECT @NEWQTY = QTY + @PI_QTY , @DSPQTY = ISNULL(DSPQTY,0), @BCKQTY = ISNULL(BCKQTY,0),@NEWCOST = COST + @PI_TOTAL
			FROM SUBWRHINV WHERE SUBWRH = @SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH

		IF @NEWQTY <> 0  OR @DSPQTY <> 0 OR @BCKQTY <> 0
		BEGIN
			UPDATE SUBWRHINV SET QTY = @NEWQTY, COST = @NEWCOST,LSTINPRC = @NEWCOST / @NEWQTY 
				WHERE SUBWRH = @SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH
		END
		ELSE
		BEGIN
			DELETE FROM SUBWRHINV WHERE SUBWRH = @SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH
		END

		FETCH NEXT FROM CUR_LOADINSUBWRH INTO @SUBWRH,@PI_QTY,@PI_TOTAL,@BILL,@BILLCLS,@BILLNUM,@BILLLINE
	END

	CLOSE CUR_LOADINSUBWRH
	DEALLOCATE CUR_LOADINSUBWRH
  END

  IF @PI_LOADMODE = 1 RETURN 0/*如果不处理负数库存，则停止*/

  --处理负数批次问题
  IF NOT EXISTS(SELECT 1 FROM SUBWRHINV WHERE WRH = @PI_WRH AND GDGID = @PI_GDGID AND QTY < 0 )
  BEGIN
	RETURN 0
  END
  
  SELECT @SETTLENO = MAX(NO) FROM MONTHSETTLE
  SELECT @ADATE = CONVERT(DATETIME,CONVERT(VARCHAR(10),GETDATE(),102))
  DECLARE CUR_LOADINSUBWRH CURSOR
	FOR SELECT SUBWRH,QTY,COST FROM TEMPSUBWRH WHERE SPID = @@SPID AND WRH=@PI_WRH AND GDGID = @PI_GDGID

  OPEN CUR_LOADINSUBWRH
  FETCH NEXT FROM CUR_LOADINSUBWRH INTO @SUBWRH,@PI_QTY,@PI_TOTAL
  WHILE @@FETCH_STATUS = 0
  BEGIN
	SELECT @DIFFCOST = 0

	WHILE @PI_QTY >0
	BEGIN
		SELECT @FSUBWRH = 0,@CODE = '',@FQTY = 0,@FCOST = 0
		SELECT @CODE = MIN(CODE) FROM SUBWRHINV WHERE WRH = @PI_WRH AND GDGID = @PI_GDGID AND QTY < 0
		
		IF ISNULL(@CODE,'') = ''
		BEGIN
			BREAK
		END
		SELECT @FSUBWRH = SUBWRH,@FQTY = QTY,@FCOST = COST FROM SUBWRHINV 
			WHERE WRH=@PI_WRH AND GDGID =@PI_GDGID AND CODE = @CODE
		IF ABS(@FQTY) <= @PI_QTY
		BEGIN
			SELECT @DIFFCOST=@DIFFCOST + (ROUND(@PI_TOTAL * ABS(@FQTY)/@PI_QTY,2) -ABS(@FCOST))
			SELECT @PI_TOTAL = @PI_TOTAL - ROUND(@PI_TOTAL * ABS(@FQTY)/@PI_QTY,2)
			SELECT @PI_QTY = @PI_QTY - ABS(@FQTY)
			DELETE FROM SUBWRHINV WHERE WRH=@PI_WRH AND GDGID =@PI_GDGID AND CODE = @CODE
		END
		ELSE
		BEGIN
			SELECT @DIFFCOST=@DIFFCOST + @PI_TOTAL - ROUND(ABS(@FCOST) * @PI_QTY / ABS(@FQTY),2)

			UPDATE SUBWRHINV SET QTY = QTY + @PI_QTY ,COST = COST + ROUND(ABS(@FCOST) * @PI_QTY / ABS(@FQTY),2)
				WHERE WRH=@PI_WRH AND GDGID =@PI_GDGID AND CODE = @CODE
			
			SELECT @PI_TOTAL = 0
			SELECT @PI_QTY = 0

		END
	END
	IF @DIFFCOST <> 0
	BEGIN
		EXEC ADDDIFFCOSTTORPT @PI_GDGID,@PI_WRH,@DIFFCOST,@ADATE,@SETTLENO
	END
	UPDATE TEMPSUBWRH SET COSTADJ = @DIFFCOST 
		WHERE SPID = @@SPID AND WRH = @PI_WRH AND GDGID = @PI_GDGID AND SUBWRH = @SUBWRH

	UPDATE SUBWRHINV SET QTY = @PI_QTY,COST = @PI_TOTAL 
		WHERE WRH = @PI_WRH AND GDGID = @PI_GDGID AND SUBWRH = @SUBWRH

	DELETE FROM SUBWRHINV WHERE WRH = @PI_WRH AND GDGID = @PI_GDGID AND SUBWRH = @SUBWRH
		AND QTY = 0 AND COST = 0 AND ISNULL(DSPQTY,0) = 0 AND ISNULL(BCKQTY,0) = 0


	FETCH NEXT FROM CUR_LOADINSUBWRH INTO @SUBWRH,@PI_QTY,@PI_TOTAL
  END
  CLOSE CUR_LOADINSUBWRH
  DEALLOCATE CUR_LOADINSUBWRH

  RETURN 0
END
GO
