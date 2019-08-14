SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create view [dbo].[v_empgoodsh] as
select goodsh.* from goodsh(nolock)
where f1 like (select rtrim(IDCARD) from employee (nolock) where code = SUBSTRING(SUSER_NAME(), CHARINDEX('_', SUSER_NAME()) + 1, 20))


GO
