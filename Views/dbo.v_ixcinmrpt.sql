SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_ixcinmrpt] (bgdgid, dqin) as 	
  select bgdgid, sum(dq1) 	
  from inmrpt 	
  where asettleno = (select max(no) from monthsettle)	
  group by bgdgid	

GO
