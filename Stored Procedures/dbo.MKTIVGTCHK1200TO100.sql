SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[MKTIVGTCHK1200TO100]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS	 CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
AS
BEGIN
  DECLARE @VSTAT INT
  SELECT @VSTAT = STAT FROM PSMKTIVGT WHERE NUM = @NUM;
  IF @VSTAT <> 1200
  BEGIN
    SET @MSG = @NUM + '该单据已审核或已作废！'
    RETURN(1)
  END
  UPDATE PSMktIvgt 
  SET STAT = 100, CHKDATE = GETDATE(),CHECKER = @OPER, LSTUPDTIME = GETDATE()
  WHERE NUM = @NUM
  EXEC MktIvgtADDLOG @NUM, 100, '', @OPER
  RETURN 0
END
GO
