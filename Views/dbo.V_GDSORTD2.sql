SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_GDSORTD2] (GID, SORT, NAME, DEPT) as
select a.GID, b.CODE, b.NAME, a.f1
from GOODSH a, SORT b
where substring(a.SORT, 1,  8) = b.CODE
and f1 like (select rtrim(IDCARD) from employee (nolock) where code = SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))



GO
