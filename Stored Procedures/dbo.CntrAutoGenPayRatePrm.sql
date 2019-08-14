SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[CntrAutoGenPayRatePrm]
AS
BEGIN
  declare @opt_ShowRateCond int
  EXEC OptReadInt 3004, 'ShowRateCond', 0, @opt_ShowRateCond output
  if @opt_ShowRateCond = 1
    exec PCT_CNTR_PAYRATECHANGE
END
GO
