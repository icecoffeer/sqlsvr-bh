SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_STAT_TO_510](
  @piNum char(14),
  @piVersion int,
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
begin
  declare @vRet int
  
  update CTCNTR set STAT = 510 where NUM = @piNum and VERSION = @piVersion
  
  exec @vRet = PCT_CNTR_SEND @piNum, @piVersion, @piOperGid, @poErrMsg output
  if @vRet > 0 return(@vRet)
  
  return(0)
end
GO
