SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_CLEAR_FROM_ZLORD]
(
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOp_ClearPool int
  declare @vPsrDateDiff int
  declare @vOrdDateDiff int
  declare @vPsrDate varchar(10)
  declare @vOrdDate varchar(10)
  declare @vUserGid int
  declare @vNum varchar(14)
  declare @vRcv int
  declare @vOp_AlcPoolDirOrderPolicy int

  exec OptReadInt 500, '直流商品策略', 0, @vOp_AlcPoolDirOrderPolicy output
  exec OptReadInt 500, '直流商品清除配货池', 0, @vOp_ClearPool output
  set @vOp_ClearPool = 0
  /*
  --FIFO部分配货处理
  --处理配出单（ALCPOOLGENBILLS.FLAG更新成3以后的清除就不会清理这部分单据商品）
  if @vOp_AlcPoolDirOrderPolicy in (1, 2)  --2005.4.11
  begin
    delete ALCPOOL from ALCPOOL alc, ALCPOOLTEMP alct
    where alc.GDGID = alct.GDGID and alc.STOREGID = alct.STOREGID
      and alc.QTY = 0 and alct.ALC = '直流'

    update ALCPOOLGENBILLS set FLAG = 3
    from ALCPOOLGENBILLS ab, STKOUTDTL stk, ALCPOOLTEMP at
    where BILLNAME like '配货出货单' and stk.CLS = '配货' and stk.NUM = ab.num
      and at.GDGID = stk.GDGID and at.ALC = '直流'
  end
  */
	exec OptReadInt 500, 'psrdatediff', 0, @vPsrDateDiff output
	exec OptReadInt 500, 'orddatediff', 0, @vOrdDateDiff output
  set @vPsrDate = convert(varchar(10), dateadd(day, @vPsrDateDiff, getdate()), 102)
  set @vOrdDate = convert(varchar(10), dateadd(day, @vOrdDateDiff, getdate()), 102)
  select @vUserGid = USERGID from SYSTEM(nolock)

  --处理定单
  if object_id('c_genbills') is not null deallocate c_genbills
	declare c_genbills cursor for
	select NUM from ALCPOOLGENBILLS where FLAG = 2 and BILLNAME = '定货单'
	for update
	open c_genbills
	fetch next from c_genbills into @vNum
	while @@fetch_status = 0
	begin
    select @vRcv = RECEIVER from ORD(nolock) where NUM = @vNum
    if @@rowcount > 0 and @vRcv = @vUserGid
    begin
      if @vOp_ClearPool = 0
      begin
        update ALCPOOLGENBILLS set FLAG = 3 where current of c_genbills
      end else
      begin
        delete from alcpool
        where storegid in (select storegid from tmpalcpoolstore(nolock))
          and gdgid in (select gdgid from orddtl(nolock)
            where flag = 0 and num = @vNum)
        and ((srcgrp = 1 and dmddate <= @vPsrDate)
  		    or (srcgrp = 2 and dmddate <= @vOrdDate)
          or (srcgrp = 3))
        update ALCPOOLGENBILLS set FLAG = 3 where current of c_genbills
      end
    end

    fetch next from c_genbills into @vNum
  end
  close c_genbills
  deallocate c_genbills

  return(0);
end
GO
