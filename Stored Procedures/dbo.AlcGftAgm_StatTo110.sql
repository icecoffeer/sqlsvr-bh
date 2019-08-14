SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[AlcGftAgm_StatTo110]
(
  @piNum          char(14),
  @piToStat       int,
  @piOper         varchar(40),
  @poErrmsg       varchar(255) output  
)
with Encryption
as
begin
  --do nothing
  update AlcGftAgm set Stat = @piToStat where num = @piNum
  update ALcGftAgmDtl set Stat = 2 where num = @piNum
  delete from AlcGft where srcnum = @piNum
  return(0)
end
GO
