SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_OUTDRPT] AS			
	SELECT ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,		
	SUM(DQ1) DQ1, SUM(DQ2) DQ2, SUM(DQ3) DQ3, SUM(DQ4) DQ4, 		
	SUM(DQ5) DQ5, SUM(DQ6) DQ6, SUM(DQ7) DQ7,		
	SUM(DT1) DT1, SUM(DT2) DT2, SUM(DT3) DT3, SUM(DT4) DT4, 		
	SUM(DT5) DT5, SUM(DT6) DT6, SUM(DT7) DT7, SUM(DT91) DT91, SUM(DT92) DT92,		
	SUM(DI1) DI1, SUM(DI2) DI2, SUM(DI3) DI3, SUM(DI4) DI4, 		
	SUM(DI5) DI5, SUM(DI6) DI6, SUM(DI7) DI7,		
	SUM(DR1) DR1, SUM(DR2) DR2, SUM(DR3) DR3, SUM(DR4) DR4, 		
	SUM(DR5) DR5, SUM(DR6) DR6, SUM(DR7) DR7		
	FROM OUTDRPT		
	GROUP BY ASTORE, ASETTLENO, ADATE, BGDGID, BWRH		

GO
