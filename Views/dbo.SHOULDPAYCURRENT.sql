SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create view [dbo].[SHOULDPAYCURRENT] (
  [VDRGID],
  [SETTLENO],
  [CLS],
  [NUM],
  [LINE],
  [SHOULDPAYCLS],
  [SHOULDPAYNUM],
  [LFTTOTAL]
) as
select VDRGID, SETTLENO, CLS, NUM, LINE, SHOULDPAYCLS, SHOULDPAYNUM, (TOTAL - PYTOTAL) LFTTOTAL
from   SHOULDPAYRPT
where  PAYTAG = 0
  and  TOTAL - PYTOTAL > 0
GO