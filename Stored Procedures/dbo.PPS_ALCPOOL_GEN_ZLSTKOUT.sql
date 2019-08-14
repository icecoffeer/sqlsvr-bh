SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_GEN_ZLSTKOUT]
(
  @piOperGid integer,
  @poErrMsg varchar(255) output
) as
begin
  declare @vOp_AlcPoolDirOrderPolicy int
  declare @vOp_Out_BreakBill_Code int
  declare @vOp_Out_BreakBill_CodeLength int
  declare @vOp_Out_BreakBill_Name int
  declare @vOp_Out_BreakBill_Sort int
  declare @vOp_Out_BreakBill_BillTo int
  declare @vOp_Out_BreakBill_Wrh int
  declare @vOp_Out_BreakBill_Psr int
  declare @vOp_Out_BreakBill_F1 int
  declare @vOp_Out_BreakBill_F2 int
  declare @vOp_Out_BreakBill_F2Length int
  declare @vOp_RoundByAlcQty int
  declare @vStoreGid int
  declare @vGdGid int
  declare @vVendor int
  declare @vSort varchar(10)
  declare @vName varchar(50)
  declare @vWrh int
  declare @vPsr int
  declare @vF1 varchar(10)
  declare @vF2 varchar(10)
  declare @vQty money
  declare @vLastStoreGid int
  declare @vLastVdr int
  declare @vLastSort varchar(10)
  declare @vLastName varchar(50)
  declare @vLastWrh int
  declare @vLastPsr int
  declare @vLastF1 varchar(10)
  declare @vLastF2 varchar(10)
  declare @vFlag int
  declare @vQtyFrom int
  declare @vAlcQty money
  declare @m money

  exec OptReadInt 500, '直流商品策略', 0, @vOp_AlcPoolDirOrderPolicy output
  exec OptReadInt 500,  'Out_BreakBill_Code', 0, @vOp_Out_BreakBill_Code output
  exec OptReadInt 500, 'Out_BreakBill_CodeLength', 1, @vOp_Out_BreakBill_CodeLength output
  exec OptReadInt 500, 'Out_BreakBill_Name', 0, @vOp_Out_BreakBill_Name output
  exec OptReadInt 500, 'Out_BreakBill_Sort', 0, @vOp_Out_BreakBill_Sort output
  exec OptReadInt 500, 'Out_BreakBill_BillTo', 0, @vOp_Out_BreakBill_BillTo output
  exec OptReadInt 500, 'Out_BreakBill_Wrh', 0, @vOp_Out_BreakBill_Wrh output
  exec OptReadInt 500, 'Out_BreakBill_Psr', 0, @vOp_Out_BreakBill_Psr output
  exec OptReadInt 500, 'Out_BreakBill_F1', 0, @vOp_Out_BreakBill_F1 output
  exec OptReadInt 500, 'Out_BreakBill_F2',0,  @vOp_Out_BreakBill_F2 output
  exec OptReadStr 500, 'Out_BreakBill_F2Length', 1, @vOp_Out_BreakBill_F2Length output
	exec OptReadInt 500, 'roundbyalcqty', 0, @vOp_RoundByAlcQty output

  if @vOp_Out_BreakBill_Sort   = 0   update alcpooltemp set sort = ''
  if @vOp_Out_BreakBill_BillTo = 0   update alcpooltemp set vendor = 1
  if @vOp_Out_BreakBill_Code   = 0   update alcpooltemp set gdcode = ''
  if @vOp_Out_BreakBill_Name   = 0   update alcpooltemp set name = ''
  if @vOp_Out_BreakBill_Wrh    = 0   update alcpooltemp set wrh = 1
  if @vOp_Out_BreakBill_Psr    = 0   update alcpooltemp set psr = 1
  if @vOp_Out_BreakBill_F1     = 0   update alcpooltemp set f1 = ''
  if @vOp_Out_BreakBill_F2     = 0   update alcpooltemp set f2 = ''

--insert into alcpoolfifo
  if object_id('c_pool') is not null deallocate c_pool
  if @vOp_AlcPoolDirOrderPolicy = 1
  begin
    declare c_pool cursor for
    select STOREGID, GDGID, QTY, VENDOR, SORT, NAME, WRH, PSR, F1, F2, QTYFROM
	  from ALCPOOLTEMP where QTY > 0
    order by STOREGID, VENDOR, SORT, NAME, WRH, PSR, F1, F2
  end else if @vOp_AlcPoolDirOrderPolicy = 2
  begin
    exec PPS_ALCPOOL_UPDATE_INVQTY
    declare c_pool cursor for
      select STOREGID, GDGID, QTY, VENDOR, SORT, NAME, WRH, PSR, F1, F2, QTYFROM
      from ALCPOOLTEMP
      where GDGID not in (select GDGID from ALCPOOLTEMP
        group by GDGID, INVQTY having sum(QTY) > INVQTY)
      order by STOREGID, VENDOR, SORT, NAME, WRH, PSR, F1, F2
  end
/* FIFO处理
  if @vOp_AlcPoolDirOrderPolicy in (1, 2) --2005.04.11 1和2都采用差量配货方式
  begin
    exec PPS_ALCPOOL_UPDATE_INVQTY
    declare c_pool cursor for
      select alct.STOREGID, alct.GDGID, alcf.RQTY QTY, alct.VENDOR,
        alct.SORT, alct.NAME, alct.WRH, alct.PSR, alct.F1, alct.F2, alct.QTYFROM
  	  from ALCPOOLTEMP alct, ALCPOOLFIFOZL alcf
  	  where alct.STOREGID = alcf.STOREGID and alct.GDGID = alcf.GDGID
  	    and alcf.RQTY > 0
      order by alct.STOREGID, alct.VENDOR, alct.SORT, alct.NAME,
        alct.WRH, alct.PSR, alct.F1, alct.F2
  end
*/
  if @vOp_AlcPoolDirOrderPolicy in (1, 2)
  begin
    set @vLastStoreGid = -1
    set @vLastVdr = -1
    set @vLastSort = ''
    set @vLastName = ''
    set @vLastPsr = -1
    set @vLastF1 = ''
    set @vLastF1 = ''
    open c_pool
    fetch next from c_pool into @vStoreGid, @vGdGid, @vQty, @vVendor, @vSort, @vName, @vWrh, @vPsr, @vF1, @vF2, @vQtyFrom
    while @@fetch_status = 0
    begin
      --判断是否需要分单
      set @vFlag = 0
      if @vLastStoreGid <> @vStoreGid
        set @vFlag = 1
			if (@vOp_Out_BreakBill_BillTo = 1) and (@vVendor <> @vLastVdr)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_Sort = 1) and (@vSort <> @vLastSort)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_Name = 1) and (@vName <> @vLastName)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_Wrh = 1) and (@vWrh <> @vLastWrh)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_Psr =1 ) and (@vPsr <> @vLastPsr)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_F1 =1 ) and (@vF1 <> @vLastF1)
				set @vFlag = 1
			if (@vOp_Out_BreakBill_F2 = 1) and (left(@vF2, @vOp_Out_BreakBill_F2Length) <> @vLastF2)
				set @vFlag = 1

			--生成单据
      if @vFlag = 1
      begin
        if not exists(select 1 from ALCPOOLGENBILLS(nolock) where BILLNAME = '配货出货单'
          and FLAG = 0 and DTLCNT = 0)
          update ALCPOOLGENBILLS set FLAG = 1	where BILLNAME = '配货出货单' and FLAG = 0
      end

			if @vOp_RoundByAlcQty = 1	--按配货单位取整
			begin
				select @vAlcQty = ALCQTY from GOODS(nolock) where GID = @vGdGid
				if @vAlcQty is not null and @vAlcQty > 0
				begin
					set @m = @vQty / @vAlcQty
					if abs(@m - round(@m, 0, 1)) >= 0.5
						set @m = round(@m, 0, 1) + 1.0
					else
						set @m = round(@m, 0, 1)
					set @vQty = @m * @vAlcQty
				end
			end

      if @vQty > 0
      begin
        exec AlcPoolGenAllocOut @vStoreGid, @vGdGid, @vQty, @vQtyFrom, @piOperGid
        update alcpool set zlgenstat = 2 --3878
          where gdgid = @vGdGid --and srcgrp = @vQtyFrom
          and zlgenstat = 1 and alcpool.storegid in (select storegid from tmpalcpoolstore(nolock))
      end

      set @vLastStoreGid = @vStoreGid
      set @vLastVdr = @vVendor
      set @vLastSort = @vSort
      set @vLastName = @vName
      set @vLastWrh = @vWrh
      set @vLastPsr = @vPsr
      set @vLastF1 = @vF1
      set @vLastF2 = left(@vF2, @vOp_Out_BreakBill_F2Length)

      fetch next from c_pool into @vStoreGid, @vGdGid, @vQty, @vVendor, @vSort, @vName, @vWrh, @vPsr, @vF1, @vF2, @vQtyFrom
    end
    close c_pool
    deallocate c_pool
  end
  return(0);
end
GO
