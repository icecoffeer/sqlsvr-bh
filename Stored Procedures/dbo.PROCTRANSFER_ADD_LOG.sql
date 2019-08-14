SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PROCTRANSFER_ADD_LOG](
  @piNum varchar(14),                 --单号
  @piStat int,                        --原状态
  @piToStat int,                      --现状态
  @piOper varchar(80)                 --操作人
) as
begin
  declare @vItem int

  select @vItem = isnull(max(ITEMNO)+1, 1) FROM ProcTransferLog(nolock) where NUM = @piNum
  insert into ProcTransferLog(Num, ItemNo, FromStat, ToStat, Oper, OperTime)
    values(@piNum, @vItem, @piStat, @piToStat, @piOper, getdate())
end
GO
