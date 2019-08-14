SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create view [dbo].[CRMCARDSTOREINVDTL] (
  [CARDNUM],
  [BYTIME],
  [CARDTYPE],
  [CARRIER],
  [STAT],
  [LSTUPDTIME],
  [VERSION],
  [MAKETIME],
  [SNDTIME],
  [INVSTAT],
  [STORE]
) as
SELECT CRMCARDINVDTL.*, CRMCARDSTOREINV.STORE STORE
FROM CRMCARDSTOREINV, CRMCARDINVDTL
WHERE CRMCARDINVDTL.CARDNUM = CRMCARDSTOREINV.CARDNUM
GO
