SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_STAT_TO_1710](
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  update CTCNTR set STAT = 1710 where NUM = @piNum and VERSION = @piVersion
  return(0)
end
GO
