SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[CNTRAUTOGENCHGBOOK]
AS
BEGIN
  declare @vSysDate datetime
  select @vSysDate = convert(varchar, getdate(), 102)
  exec PCT_CHGBOOK_ON_SETTLEDAY @vSysDate
END
GO
