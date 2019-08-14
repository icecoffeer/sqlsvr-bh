SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create view [dbo].[V_GDSORTB] (GID, SORT, NAME) as
select a.GID, b.CODE, b.NAME
from GOODSH a, SORT b
where substring(a.SORT, 1,  3) = b.CODE
GO
