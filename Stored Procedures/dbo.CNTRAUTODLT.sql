SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
CREATE PROCEDURE [dbo].[CNTRAUTODLT]
AS
BEGIN
  declare @vSysDate datetime
  select @vSysDate = getdate()
  exec PCT_CNTR_ON_SETTLEDAY @vSysDate
END
GO
