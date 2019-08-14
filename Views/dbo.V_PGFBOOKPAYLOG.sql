SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[V_PGFBOOKPAYLOG] (
  [PGFNUM],
  [PAYNUM],
  [TOTAL],
  [TIME],
  [CLS]
) as
SELECT PGFBOOK.NUM PGFNUM,
       CNTRPAYCASHDTL.NUM PAYNUM,
       CNTRPAYCASHDTL.PAYTOTAL TOTAL,
       CNTRPAYCASHCHKLOG.ATIME TIME,
       CNTRPAYCASHDTL.CHGTYPE CLS
  FROM PGFBOOK(NOLOCK), CNTRPAYCASHDTL(NOLOCK), CNTRPAYCASHCHKLOG(NOLOCK)
 WHERE PGFBOOK.NUM = CNTRPAYCASHDTL.IVCCODE
   AND CNTRPAYCASHDTL.NUM = CNTRPAYCASHCHKLOG.NUM
   AND CNTRPAYCASHCHKLOG.CHKFLAG = 900
GO