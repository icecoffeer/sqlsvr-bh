SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SVIGETNEXTNUM](
  @NUM VARCHAR(10) OUTPUT	
)
AS
BEGIN
  DECLARE @MNUM VARCHAR(10)
  SELECT @MNUM = MAX(NUM) FROM SVI
  IF (@@ROWCOUNT = 0) OR (@MNUM IS NULL) 
    SELECT @NUM = '0000000001'
  ELSE
    EXEC NEXTBN @MNUM, @NUM OUTPUT
  RETURN 0  
END
GO
