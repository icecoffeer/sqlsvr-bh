SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[SVIGETFIELD](
  @PID VARCHAR(1),
  @PVALUE VARCHAR(13),
  @PFD VARCHAR(80) OUTPUT	
)
AS
BEGIN
  IF @PID = '0' 
    SET @PFD = ' AND VDRCODE = ' + '''' + @PVALUE + ''''	
  ELSE IF @PID = '1' 
    SET @PFD = ' AND PSRCODE = ' + '''' + @PVALUE + ''''
  ELSE IF @PID = '2' 
    SET @PFD = ' AND WRHCODE = ' + '''' + @PVALUE + ''''
  ELSE IF @PID = '3' 
    SET @PFD = ' AND STCODE = ' + '''' + @PVALUE + ''''
  ELSE
    SET @PFD = ' '
  RETURN 0
END
GO
