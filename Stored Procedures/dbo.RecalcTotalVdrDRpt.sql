SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcTotalVdrDRpt]
    @store int,
    @settleno int,
    @date datetime
as
begin
  exec RecalcVdrDRpt @store, @settleno, @date
  if @@error <> 0 return(@@error)

  exec RecalcStoreVdrDRpt @store, @settleno, @date
  if @@error <> 0 return(@@error)
end
GO
