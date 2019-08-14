SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_CTGDDISRULESET_ADD_LOG]
(
  @piNum varchar(14),
  @piStat int,
  @piToStat int,
  @piOper varchar(30),
  @poErrMsg varchar(255) output
) as	
begin
  declare @vItemNo int
  select @vItemNo = isnull(max(ITEMNO) + 1, 1) from PSCTGDDISRULESETLOG(nolock) where NUM = @piNum  

  insert into PSCTGDDISRULESETLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
    values(@piNum, @vItemNo, @piStat, @piToStat, @piOper, getdate())
end
GO
