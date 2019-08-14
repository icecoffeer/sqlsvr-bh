SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create view [dbo].[V_GDSORTC] (GID, SORT, NAME) as
select a.GID, b.CODE, b.NAME
from GOODSH a, SORT b
where substring(a.SORT, 1,  4) = b.CODE
GO
