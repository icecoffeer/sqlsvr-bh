SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[v_userdept2] 
as  
select rtrim(IDCARD) dept from employee (nolock), CurrentEmp(nolock) where gid = EmpGid and id = @@spid
GO
