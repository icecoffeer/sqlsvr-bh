SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_goodsBak] as
select distinct g.*
	from goods g(nolock), deptemp d(nolock)
	where g.f1 like rtrim(d.deptcode) + '%'
		and d.empgid = (select gid 
				from employee(nolock) 
				where code = SUBSTRING(SUSER_NAME(), CHARINDEX('_', SUSER_NAME()) + 1, 20)
)


GO
