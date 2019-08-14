SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_APPLY_QTYPOLICY]
(
  @poErrMsg varchar(255) output
) as
begin
  declare @vOp_QtyPolicy int

  --根据数量策略计算数量
	exec OptReadInt 500, 'qtypolicy', 0, @vOp_QtyPolicy output
  if @vOp_QtyPolicy = 0
    update ALCPOOLTEMP set QTYFROM = (
      case when PSRALCQTY > ORDQTY then
        (case when PSRALCQTY > AUTOALCQTY then 1 else 3 end)
      else
        (case when ORDQTY > AUTOALCQTY then 2 else 3 end)
      end
    )
  else if @vOp_QtyPolicy = 1
    update ALCPOOLTEMP set QTYFROM = (
      case when PSRALCQTY > 0 then
        1
      else
        (case when ORDQTY > 0 then 2 else 3 end)
      end
    )
  else if @vOp_QtyPolicy = 2
    update ALCPOOLTEMP set QTYFROM = (
      case when ORDQTY > 0 then
        2
      else
        (case when PSRALCQTY > 0 then 1 else 3 end)
      end
    )
  update ALCPOOLTEMP set QTY = PSRALCQTY where QTYFROM = 1
  update ALCPOOLTEMP set QTY = ORDQTY where QTYFROM = 2
  update ALCPOOLTEMP set QTY = AUTOALCQTY where QTYFROM = 3

  return(0);
end
GO
