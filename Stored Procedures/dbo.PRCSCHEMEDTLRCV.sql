SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PRCSCHEMEDTLRCV]
(
  @OPER CHAR(30),
  @MSG VARCHAR(255) OUTPUT
) with encryption
AS
BEGIN
  DECLARE @RTN INT
  EXEC @RTN = STOREPRCSCHEMERCV @OPER, @MSG OUTPUT  
  RETURN(@RTN)
END
GO
