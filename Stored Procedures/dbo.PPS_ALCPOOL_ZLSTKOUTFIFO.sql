SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_ZLSTKOUTFIFO]
(
  @poErrMsg varchar(255) output
) as
begin
  declare @vGdgid int
  declare @vStoreGid int
  declare @vLine int
  declare @vInvQty decimal(24,4)
  declare @vRQty decimal(24,4)
  declare @vGDTotalQty decimal(24,4)
  declare @vQtyDiff decimal(24,4)
  declare @vQtyUse decimal(24,4)
  declare @vOp_AlcPoolDirOrderPolicy int
  declare @vOp_ClearPool int

  exec OptReadInt 500, '直流商品策略', 0, @vOp_AlcPoolDirOrderPolicy output

  --全部生成定单不作处理
  if @vOp_AlcPoolDirOrderPolicy = 0
    return 0

  --2根据实际配出情况，扣除差量数量，如果是0就要在清除时删除alcpool相应记录。
  truncate table ALCPOOLFIFOZL
  insert into ALCPOOLFIFOZL(STOREGID, GDGID, RQTY)
    select STOREGID, GDGID, 0
    from ALCPOOLTEMP(nolock) where ALCPOOLTEMP.ALC = '直流'
  update ALCPOOLFIFOZL set ALLQTY = QTY
  from ALCPOOLTEMP alct where alct.STOREGID = ALCPOOLFIFOZL.STOREGID
    and alct.GDGID = ALCPOOLFIFOZL.GDGID

  exec PPS_ALCPOOL_UPDATE_INVQTY
  declare c_fifo cursor for
    select alc.STOREGID, alc.GDGID, alc.LINE, alct.InvQty, alc.QTY
    from ALCPOOL alc(nolock), ALCPOOLTEMP alct(nolock)
    where alc.GDGID = alct.GDGID and alc.STOREGID = alct.STOREGID and alc.SRCGRP = alct.QTYFROM
      and alct.ALC = '直流'
    group by alc.STOREGID, alc.GDGID, alc.LINE, alc.QTY, alct.InvQty, alc.ORDTIME, alc.DMDDATE
    order by isnull(alc.ORDTIME, alc.DMDDATE)
  open c_fifo
  fetch next from c_fifo into @vStoreGid, @vGdgid, @vLine, @vInvQty, @vRQty
  while @@fetch_status = 0
  begin
    --该商品的当前配出数合计
    select @vGDTotalQty = sum(RQty) from ALCPOOLFIFOZL where Gdgid = @vGdgid
    set @vQtyDiff = @vInvQty - @vGDTotalQty
    --如果已经把库存配出完毕就跳过
    if @vQtyDiff <= 0
    begin
      fetch next from c_fifo into @vStoreGid, @vGdgid, @vLine, @vInvQty, @vRQty
      continue
    end
    --按照库存生成配出
    if @vQtyDiff > @vRQty
      set @vQtyUse = @vRQty
    else
      set @vQtyUse = @vQtyDiff

    update ALCPOOLFIFOZL set RQTY = @vQtyUse + RQTY
    where STOREGID = @vStoreGid and Gdgid = @vGdgid

    update ALCPOOL set QTY = QTY - @vQtyUse
    where STOREGID = @vStoreGid and GDGID = @vGdgid and LINE = @vLine
    fetch next from c_fifo into @vStoreGid, @vGdgid, @vLine, @vInvQty, @vRQty
  end
  close c_fifo
  deallocate c_fifo

  return(0);
end
GO
