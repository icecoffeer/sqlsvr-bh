SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[GenVdrPayBill]
(@Oper VarChar(60),
 @StartDate DATETIME,
 @EndDate DATETIME,
 @VGID INT,
 @DEPT VARCHAR(20),
 @PAYPERIOD VARCHAR(20),
 @BILLNUM VARCHAR(64) OUTPUT )
 AS
BEGIN
  DECLARE @USEDEPT VARCHAR(20)
  DECLARE @RET INT
  SELECT @USEDEPT = '0'
  SELECT @USEDEPT = RTRIM(OptionValue) FROM HDOPTION WHERE MODULENO = 3304 AND OPTIONCAPTION = 'GenVdrPayUseDept'
  IF @USEDEPT = '0' 
    EXEC @RET = GenVdrPayBillNODEPT @Oper, @StartDate, @EndDate, @VGID, @DEPT, @PAYPERIOD, @BILLNUM OUTPUT
  ELSE
    EXEC @RET = GenVdrPayBillDEPT @Oper, @StartDate, @EndDate, @VGID, @DEPT, @PAYPERIOD, @BILLNUM OUTPUT  
  RETURN @RET
END
GO
