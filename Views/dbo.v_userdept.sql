SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO


create view [dbo].[v_userdept]
as
select rtrim(IDCARD) dept from employee (nolock) where code = SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20)

GO
