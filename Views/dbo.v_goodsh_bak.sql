SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_goodsh_bak] as
  select goodsh.* from goodsh(nolock), deptemp(nolock)
 where f1 = deptemp.deptcode
    and deptemp.empgid = (
      select gid from employee(nolock) where code = SUBSTRING(SUSER_NAME(), CHARINDEX('_', SUSER_NAME()) + 1, 20)
)



GO
