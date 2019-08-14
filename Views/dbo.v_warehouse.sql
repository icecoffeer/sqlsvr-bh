SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_warehouse] as
  select * from warehouse where gid in (
    select wrhgid from wrhemp where empgid = (
      select gid from employee where code = SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20)
))


GO
