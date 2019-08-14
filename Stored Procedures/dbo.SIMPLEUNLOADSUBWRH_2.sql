SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SIMPLEUNLOADSUBWRH_2]
  @PI_GDGID INT,
  @PI_WRH INT,
  @PI_SUBWRH INT,
  @PI_CODE CHAR(10),
  @PI_QTY INT,
  @PI_COST MONEY OUTPUT
AS
BEGIN

  DECLARE @NEWQTY MONEY, @DSPQTY MONEY, @BCKQTY MONEY,@NEWCOST MONEY
  DECLARE @PRICE MONEY

  IF NOT EXISTS ( SELECT * FROM SUBWRHINV WHERE WRH = @PI_WRH AND
	  SUBWRH = @PI_SUBWRH AND GDGID = @PI_GDGID )
  BEGIN
	SELECT @PRICE = INPRC FROM SUBWRH WHERE GID = @PI_SUBWRH AND GDGID = @PI_GDGID
	IF @@ROWCOUNT = 0
	BEGIN
		EXEC GETFIFODEFINPRC @PI_GDGID,@PRICE OUTPUT
	END

	SELECT @PI_COST = ROUND(@PI_QTY * @PRICE,2)

	INSERT INTO SUBWRHINV(WRH,SUBWRH,CODE,GDGID,QTY,LSTINPRC,COST) VALUES
		(@PI_WRH,@PI_SUBWRH,@PI_CODE,@PI_GDGID,-1 * @PI_QTY,@PRICE, -1 * @PI_COST)

	IF NOT EXISTS(SELECT 1 FROM SUBWRH WHERE GID = @PI_SUBWRH AND GDGID = @PI_GDGID)
	BEGIN
		INSERT INTO SUBWRH(GID,CODE,NAME,GDGID,INPRC,WRH) 
			VALUES (@PI_SUBWRH,@PI_CODE,@PI_CODE,@PI_GDGID,@PRICE,@PI_WRH)
	END
  END
  ELSE
  BEGIN
	SELECT @NEWQTY = QTY, @DSPQTY = ISNULL(DSPQTY,0), @BCKQTY = ISNULL(BCKQTY,0),@NEWCOST = COST
	FROM SUBWRHINV WHERE SUBWRH = @PI_SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH


	IF @NEWQTY < 0 
	BEGIN
		SELECT @PI_COST = ROUND(@NEWCOST * @PI_QTY / @NEWQTY,2)
		UPDATE SUBWRHINV SET QTY = QTY - @PI_QTY,COST = COST - @PI_COST 
			WHERE SUBWRH = @PI_SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH
	END
	ELSE
	BEGIN
		IF @NEWQTY < @PI_QTY
		BEGIN
		      RAISERROR( '货位库存不足', 16, 1)
		      RETURN 11
		END
		ELSE
		BEGIN
			IF @NEWQTY = @PI_QTY 
			BEGIN
				SELECT @PI_COST = @NEWCOST
				DELETE FROM SUBWRHINV WHERE WRH = @PI_WRH AND SUBWRH = @PI_SUBWRH AND GDGID = @PI_GDGID
			END
			ELSE
			BEGIN
				SELECT @PI_COST = ROUND(@NEWCOST * @PI_QTY / @NEWQTY,2)
				UPDATE SUBWRHINV SET QTY = QTY - @PI_QTY,COST = COST - @PI_COST 
					WHERE SUBWRH = @PI_SUBWRH AND GDGID = @PI_GDGID AND WRH = @PI_WRH

			END
		END
	END
  END
  RETURN 0
END
GO
