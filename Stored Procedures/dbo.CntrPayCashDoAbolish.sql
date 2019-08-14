SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashDoAbolish] (
  @num char(14)
)
as
begin
  declare @return_status int
  select @return_status = 0

  return @return_status
end
GO
