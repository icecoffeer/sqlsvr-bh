SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OnlineSaleOrd_DoRemove](
  @Num char(14),
  @Msg varchar(255) output
)
as
begin
  --删除汇总和明细数据
  delete from OnlineSaleOrd where NUM = @Num
  delete from OnlineSaleOrdDTL where NUM = @Num
  delete from OnlineSaleOrdCurrency where NUM = @Num

  return(0)
end
GO
