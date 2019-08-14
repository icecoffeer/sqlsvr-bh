SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create view [dbo].[CHECKINPOOL] (
  [ID],
  [FILLTIME],
  [OPERATOR],
  [CASHIER],
  [STORENO],
  [THEDATE],
  [FROMDATE],
  [AMOUNT],
  [REALAMOUNT],
  [RETAILAMT],
  [MILKAMT],
  [PUCAMT],
  [BILLCOUNT]
) as
SELECT ID, FILLTIME, OPERATOR, CASHIER, STORENO, THEDATE, FROMDATE, AMOUNT, REALAMOUNT, RETAILAMT, MILKAMT, PUCAMT, BILLCOUNT
	FROM CHECKINPOOLS
GO
