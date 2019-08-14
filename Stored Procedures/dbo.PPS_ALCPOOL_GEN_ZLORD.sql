SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_GEN_ZLORD]
(
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOp_AlcPoolDirOrderPolicy int
  declare @vOp_ClearPool int
  declare @vOp_OrderBreakBySort int
  declare @vOp_RoundByCases int
  declare @vOp_SortLen int
  declare @vLastVdr int
  declare @vLastSort varchar(10)
  declare @vGdGid int
  declare @vQty money
  declare @vVendor int
  declare @vSort varchar(10)
  declare @vFlag int
  declare @vUserGid int
  declare @vQtyFrom int
  declare @vQpc money
  declare @m money
  declare @vOp_OrderBreakByTaxRate int --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
  declare @vTaxRate money  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
  declare @vLastTaxRate money  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分

  exec OptReadInt 500, '直流商品策略', 0, @vOp_AlcPoolDirOrderPolicy output
  exec OptReadInt 500, '直流商品清除配货池', 0, @vOp_ClearPool output
  set @vOp_ClearPool = 0
	exec OptReadInt 500, 'order_breakbysort', 0, @vOp_OrderBreakBySort output
  exec OptReadInt 500, 'order_sortlen', 0, @vOp_SortLen output
	exec OptReadInt 500, 'roundbycases', 0, @vOp_RoundByCases output

  exec OptReadInt 500, 'order_breakbyTaxRate', 0, @vOp_OrderBreakByTaxRate output --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
  select @vUserGid = USERGID from SYSTEM(nolock)

  if @vOp_OrderBreakBySort   = 0   update alcpooltemp set sort = ''
  if @vOp_OrderBreakBySort = 0 update alcpooltemp set TaxRate = 0  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分

  if object_id('c_pool') is not null deallocate c_pool
  if @vOp_AlcPoolDirOrderPolicy = 0
  begin
    declare c_pool cursor for
    select GDGID, sum(QTY), VENDOR, SORT, QTYFROM, TAXRATE
    from ALCPOOLTEMP
    group by VENDOR, GDGID, SORT, QTYFROM, INVQTY, TAXRATE
    order by VENDOR, SORT
  end else if @vOp_AlcPoolDirOrderPolicy = 2
  begin
    exec PPS_ALCPOOL_UPDATE_INVQTY
    declare c_pool cursor for
    select GDGID, sum(QTY), VENDOR, SORT, QTYFROM, TAXRATE --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
    from ALCPOOLTEMP
    group by VENDOR, GDGID, SORT, QTYFROM, INVQTY, TAXRATE  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
    having sum(QTY) > INVQTY and sum(QTY) > 0
    order by VENDOR, SORT, TAXRATE  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
/* FIFO处理
    exec PPS_ALCPOOL_UPDATE_INVQTY
    declare c_pool cursor for
      select alct.GDGID, sum(alcf.ALLQTY - alcf.RQTY), alct.VENDOR, alct.SORT, alct.QTYFROM
      from ALCPOOLTEMP alct, ALCPOOLFIFOZL alcf
      where alct.STOREGID = alcf.STOREGID and alct.GDGID = alcf.GDGID
      group by alct.VENDOR, alct.GDGID, alct.SORT, alct.QTYFROM, alct.INVQTY
      having sum(alcf.ALLQTY - alcf.RQTY) > 0 and sum(alct.QTY) > 0
      order by alct.VENDOR, alct.SORT
*/
  end
  if @vOp_AlcPoolDirOrderPolicy in (0, 2)
  begin
    set @vLastVdr = -1
    set @vLastSort = ''
    open c_pool
    fetch next from c_pool into @vGdGid, @vQty, @vVendor, @vSort, @vQtyFrom, @vTaxRate  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
    while @@fetch_status = 0
    begin
      --判断是否需要分单
      select @vFlag = 0
      if @vVendor <> @vLastVdr	--定单按供应商分单
        set @vFlag = 1
      if (@vOp_OrderBreakBySort = 1)
        and (substring(@vSort, 1, @vOp_SortLen) <> substring(@vLastSort, 1, @vOp_SortLen))--按类别分单
        set @vFlag = 1

      if (@vOp_OrderBreakByTaxRate = 1)  --ShenMin 定单按税率分单
        and @vTaxRate <> @vLastTaxRate
        set @vFlag = 1

      if @vFlag = 1
      begin
        if not exists(select 1 from ALCPOOLGENBILLS(nolock) where BILLNAME = '定货单'
          and FLAG = 0 and DTLCNT = 0)  --判断是否上一张单据是否空单据
        begin
          update ALCPOOLGENBILLS set FLAG = 1	where BILLNAME = '定货单' and FLAG = 0
        end
			end

			if @vOp_RoundByCases = 1	--按箱数取整
			begin
				select @vQpc = qpc from goods(nolock)
				where gid = @vGdGid
				if @vQpc is not null and @vQpc > 0
				begin
					set @m = @vQty / @vQpc
					if abs(@m - round(@m, 0, 1)) >= 1e-4
					begin
						set @m = round(@m, 0, 1) + 1.0
						set @vQty = @m * @vQpc
					end
				end
			end
			--生成定单
      if @vQty > 0
      begin
        exec AlcPoolGenOrd @vUserGid, @vVendor, @vGdGid, @vQty, @piOperGid, @vQtyFrom
        --if @vOp_ClearPool = 0 --todo:防止下次生成配出时主键冲突，该机制无法记录一条记录多次配出的情况,该情况暂时不处理
          --delete from ALCPOOLHTEMP where GDGID = @vGdGid

        update alcpool set zlgenstat = 1 --3878
        where gdgid = @vGdGid --and srcgrp = @vQtyFrom
          and alcpool.storegid in (select storegid from tmpalcpoolstore(nolock))
      end
			set @vLastVdr = @vVendor
      set @vLastSort = @vSort
      set @vLastTaxRate = @vTaxRate --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
      fetch next from c_pool into @vGdGid, @vQty, @vVendor, @vSort, @vQtyFrom, @vTaxRate  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
    end
    close c_pool
    deallocate c_pool
  end

  return(0);
end
GO
