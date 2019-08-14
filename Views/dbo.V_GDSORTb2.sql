SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_GDSORTb2] (GID, SORT, NAME, DEPT, TAXRATE) as
select a.GID, b.CODE, b.NAME, a.f1, a.TAXRATE
from GOODSH a(nolock), SORT b(nolock)
where substring(a.SORT, 1,  3) = b.CODE
and f1 like (select rtrim(IDCARD) from employee (nolock) where code = SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))



GO
