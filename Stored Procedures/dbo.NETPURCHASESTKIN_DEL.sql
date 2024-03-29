SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[NETPURCHASESTKIN_DEL] (
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DELETE FROM NPURCHASEORDER WHERE SRC = @SRC_ID AND ID = @BILL_ID
  DELETE FROM NPURCHASEORDERDTL WHERE SRC = @SRC_ID AND ID = @BILL_ID
  RETURN 0
END
GO
