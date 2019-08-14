SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_PROCTASKPSCPDTL] (
  [NUM],
  [PSCPCODE],
  [PSCPGID],
  [PSCPQTY]
) as
SELECT DISTINCT NUM, PSCPCODE, PSCPGID, PSCPQTY
FROM PROCTASKPROD(nolock)
GO
