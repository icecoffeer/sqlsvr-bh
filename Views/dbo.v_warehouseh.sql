SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_warehouseh] as
  select * from warehouseh where gid in (
    select wrhgid from wrhemp where empgid = (
      select gid from employee where code = SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20)
))

GO
