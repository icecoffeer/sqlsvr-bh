SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[VDRPAYRTN_NETDELETE](
  @BILL_ID INT,
  @SRC_ID INT,
  @OPER VARCHAR(50),
  @MSG VARCHAR(255) OUTPUT
) AS
BEGIN
  DELETE FROM NCTVDRPAYRTN WHERE SRC = @SRC_ID AND ID = @BILL_ID
  RETURN 0
END
GO