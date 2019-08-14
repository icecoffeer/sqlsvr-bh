SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ADD_LOG]
(
  @piNum varchar(14),
  @piStat int,
  @piToStat int,
  @piOper varchar(30)
) as
begin
  declare @vItemNo int

  select @vItemNo = isnull(max(ITEMNO)+1, 1) from  PS3REDBLUECARDLOG(nolock) where NUM = @piNum

  insert into  PS3REDBLUECARDLOG(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
    values(@piNum, @vItemNo, @piStat, @piToStat, @piOper, getdate())
end
GO
