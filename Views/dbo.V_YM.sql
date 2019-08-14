SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE VIEW [dbo].[V_YM] AS			
select max(y.no) yno, m.no mno			
from yearsettle y, monthsettle m			
where y.no <= m.no			
group by m.no			

GO
