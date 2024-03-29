SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_YWRHPLAN] (YEAR, WRH, TOTAL, GP, GPRATE) AS			
	SELECT YEAR, WRH, SUM(TOTAL), SUM(GP), SUM(GP)/SUM(TOTAL)		
	FROM MWRHPLAN		
	GROUP BY YEAR, WRH		

GO
