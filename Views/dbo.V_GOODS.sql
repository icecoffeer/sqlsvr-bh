SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE view [dbo].[V_GOODS] as             --YANG 2015.03.10
  select * FROM GOODS(NOLOCK)
WHERE  f1 like (select rtrim(IDCARD)
from EMPLOYEE(nolock) where code = dbo.SUSER_SNAMEex()) --YANG 2015.03.10
GO
