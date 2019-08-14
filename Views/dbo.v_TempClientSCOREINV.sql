SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_TempClientSCOREINV]
as 
select c.CODE, c.NAME, sum(s.SCORE) score
from CLIENTH c, SCOREINV s
where c.GID = s.CARRIER 
GROUP BY c.code, c.name
GO
