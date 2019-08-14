SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCRM_CARDRECYCLE_ADD_LOG](
  @piNum char(14),                    --单号
  @piStat int,                        --原状态
  @piToStat int,                      --现状态 
  @piOper varchar(30)                 --操作人
) as
begin
  declare @vItem int
  select @vItem = isnull(max(ITEMNO)+1, 1) from CRMCardRecycleLog(nolock) where NUM = @piNum
  insert into CRMCardRecycleLog(NUM, ITEMNO, FROMSTAT, TOSTAT, OPER, OPERTIME)
  values(@piNum, @vItem, @piStat, @piToStat, @piOper, getdate())
end
GO
