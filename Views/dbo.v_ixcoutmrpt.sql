SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_ixcoutmrpt] (bgdgid, dqxs, dtxs) as 	
  select bgdgid, sum(dq1+dq2), sum(dt1+dt2) 	
  from outmrpt 	
  where asettleno = (select max(no) from monthsettle)			
  group by bgdgid			

GO
