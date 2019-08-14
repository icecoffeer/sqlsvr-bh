SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_user]
as
select gid, code, idcard dept
from employee (nolock)
where code = SUBSTRING(SUSER_NAME(), CHARINDEX('_', SUSER_NAME()) + 1, 20)


GO
