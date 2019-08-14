SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_OUTDRPTI] AS			
	SELECT ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,		
	SUM(CQ1) CQ1, SUM(CQ2) CQ2, SUM(CQ3) CQ3, SUM(CQ4) CQ4, 		
	SUM(CQ5) CQ5, SUM(CQ6) CQ6, SUM(CQ7) CQ7,		
	SUM(CT1) CT1, SUM(CT2) CT2, SUM(CT3) CT3, SUM(CT4) CT4, 		
	SUM(CT5) CT5, SUM(CT6) CT6, SUM(CT7) CT7, SUM(CT91) CT91, SUM(CT92) CT92,		
	SUM(CI1) CI1, SUM(CI2) CI2, SUM(CI3) CI3, SUM(CI4) CI4, 		
	SUM(CI5) CI5, SUM(CI6) CI6, SUM(CI7) CI7,		
	SUM(CR1) CR1, SUM(CR2) CR2, SUM(CR3) CR3, SUM(CR4) CR4, 		
	SUM(CR5) CR5, SUM(CR6) CR6, SUM(CR7) CR7		
	FROM OUTDRPTI		
	GROUP BY ASTORE, ASETTLENO, ADATE, BGDGID, BWRH		

GO
