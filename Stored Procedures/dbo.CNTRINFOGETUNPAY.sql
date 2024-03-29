SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[CNTRINFOGETUNPAY] (
    @BDATE DATETIME,
    @GTYPE INT,
    @VDR INT,
    @DEPT VARCHAR(10),
    @SVALUE VARCHAR(20) OUTPUT
)
AS
BEGIN
  DECLARE @AMOUNT MONEY
  DECLARE @SettleDeptMethod	INT
  EXEC OPTREADINT 0,'AutoGetSettleDeptMethod',1,@SettleDeptMethod OUTPUT
  
  IF @GTYPE = 1
  BEGIN
    IF @DEPT = '' OR @DEPT IS NULL
      SELECT @AMOUNT = SUM(DT3 - DT4) FROM VDRDRPT WHERE BVDRGID = @VDR AND ADATE = @BDATE
    ELSE BEGIN
	IF @SettleDeptMethod = 1 
	BEGIN
      		SELECT @AMOUNT = SUM(DT3 - DT4) FROM VDRDRPT, GOODSH 
        	WHERE BVDRGID = @VDR AND ADATE = @BDATE AND BGDGID = GID 
        	AND F1 IN (SELECT DEPTCODE FROM SETELLEDEPTDEPT WHERE CODE = @DEPT)
        END
	IF @SettleDeptMethod = 2
	BEGIN
      		SELECT @AMOUNT = SUM(DT3 - DT4) FROM VDRDRPT, GOODSH 
        	WHERE BVDRGID = @VDR 
        END
    END
  END
  ELSE
  BEGIN
    IF @DEPT = '' OR @DEPT IS NULL
      SELECT @AMOUNT = SUM(DT2) FROM OSBAL WHERE VDRGID = @VDR AND DATE < @BDATE
    ELSE BEGIN
	IF @SettleDeptMethod = 1 
	BEGIN
		SELECT @AMOUNT = SUM(DT2) FROM OSBAL, GOODSH
         	WHERE VDRGID = @VDR AND DATE < @BDATE AND GDGID = GID 
        	AND F1 IN (SELECT DEPTCODE FROM SETELLEDEPTDEPT WHERE CODE = @DEPT)
        END
	IF @SettleDeptMethod = 2
	BEGIN
		SELECT @AMOUNT = SUM(DT2) FROM OSBAL, GOODSH
         	WHERE VDRGID = @VDR AND DATE < @BDATE AND GDGID = GID 
        END
    END
  END
  IF @@ROWCOUNT = 0 OR @AMOUNT IS NULL
    SELECT @AMOUNT = 0.00
  SELECT @SVALUE = CAST(@AMOUNT AS VARCHAR(20))
  RETURN 0
END
GO
