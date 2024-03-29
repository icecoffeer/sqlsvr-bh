SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_INDRPT] AS			
  SELECT ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,			
    SUM(DQ1) DQ1, SUM(DQ2) DQ2, SUM(DQ3) DQ3, SUM(DQ4) DQ4,			
    SUM(DT1) DT1, SUM(DT2) DT2, SUM(DT3) DT3, SUM(DT4) DT4,			
    SUM(DI1) DI1, SUM(DI2) DI2, SUM(DI3) DI3, SUM(DI4) DI4,			
    SUM(DR1) DR1, SUM(DR2) DR2, SUM(DR3) DR3, SUM(DR4) DR4			
  FROM INDRPT			
  GROUP BY ASTORE, ASETTLENO, ADATE, BGDGID, BWRH			

GO
