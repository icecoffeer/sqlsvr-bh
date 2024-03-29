SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[GETSUBWRH2LSTINPRC]
	@PI_GDGID INT,
	@PI_SUBWRH INT,
	@PI_INPRC MONEY OUTPUT,
	@PI_MODE SMALLINT OUTPUT
AS
BEGIN
	SELECT @PI_MODE = 0
	SELECT @PI_INPRC = INPRC FROM SUBWRH WHERE GID = @PI_SUBWRH
		AND GDGID = @PI_GDGID 
	
	IF @@ROWCOUNT = 0  SELECT @PI_MODE = -1

	RETURN 0
		
END
GO
