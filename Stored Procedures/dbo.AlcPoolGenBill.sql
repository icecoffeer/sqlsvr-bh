SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolGenBill](
	@storegid int,
	@goodscond varchar(255),
	@operator int,
  @orderby varchar(255)
)
as
begin
	declare
		@sqlstr varchar(1024), @line   int, @maxline int,
                @i int, @s varchar(255), @msg	varchar(1024), @from int,
		@alccoef money, @order_breakbysort int, @bill4jmstore smallint, @qtypolicy smallint, @roundbyalcqty smallint,
		@roundbycases smallint,	@alcsortbygdcode smallint, @max_out_dtl_cnt smallint, @ALCPOOLGENALCMETHOD int,
		@cur_out_dtl_cnt smallint, @num char(10), @billname varchar(20), @total money, @tax money,
		@reccnt smallint, @settleno money, @qpc money, @alcqty money, @m money, @shouldnew smallint,
		@srcgrp smallint, @ALCQTY2Match smallint, @salcqty int, @salcqstart int,
		--以下分单用
		@psralcqty money, @ordqty money, @autoalcqty money, @qty money, @gdgid int,
		@vdr int, @lastvdr int, @sort varchar(10), @lastsort varchar(10), @Name char(50),
		@wrh int, @Psr Int, @F1 varChar(64), @F2 varchar(64), @F3 varchar(64), @code char(13),
		@lastcode varchar(13), @lastname char(50), @lastwrh int, @lastPsr int,
		@lastF1 varchar(64), @lastF2 varchar(64), @lastF3 varchar(64),
		@out_breakbyCode int, @out_breakbyCodeLen char(50), @out_breakByName int, @breakbysort2 int,
		@out_breakbywrh int, @out_breakByBillto int, @out_breakBypsr int, @out_breakByF1 int, @out_breakByF2 int, @order_BreakByF3 int,
		@out_breakByF2Len char(50), @out_breakbysort int, @srcbill char(10),
		@BillSrcFilter Varchar(20),         --用于美益佳推荐报货
		@OPT_METHOD INT,
		@Order_BreakByTaxRate int, --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
		@TaxRate money, @LastTaxRate money   --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分


	--读取选项
	exec OptReadInt 0, 'ALCPOOLGENALCMETHOD', 0, @AlcpoolgenalcMethod output
	exec OptReadStr 500, 'alccoef', '1', @s output
	set @alccoef = convert(money, @s)
	exec OptReadInt 500, 'order_breakbysort', 0, @order_breakbysort output
	exec OptReadInt 500, 'Order_BreakByTaxRate', 0, @Order_BreakByTaxRate output  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分

	exec OptReadInt 500, 'bill4jmstore', 0, @bill4jmstore output
	exec OptReadInt 500, 'qtypolicy', 0, @qtypolicy output
	exec OptReadInt 500, 'roundbyalcqty', 0, @roundbyalcqty output
	exec OptReadInt 500, 'roundbycases', 0, @roundbycases output
	exec OptReadInt 500, 'max_out_dtl_cnt', 10000, @max_out_dtl_cnt output
	exec OptReadInt 500, 'alcsortbygdcode', 1, @alcsortbygdcode output
	exec OptReadInt 500,  'Out_BreakBill_Code', 0, @out_breakbycode output
	if @out_breakbycode = 1
		exec OptReadStr 500, 'Out_BreakBill_CodeLength', '1', @out_breakByCodeLen output
	exec OptReadInt 500, 'Out_BreakBill_Name', 0, @out_breakByName output
	exec OptReadInt 500, 'Out_BreakBill_Sort', 0, @out_breakBySort output
        exec OptReadInt 500, 'Out_BreakBill_BillTo', 0, @out_breakByBillto output
	exec OptReadInt 500, 'Out_BreakBill_Wrh', 0, @out_breakByWrh output
	exec OptReadInt 500, 'Out_BreakBill_Psr', 0, @out_breakByPsr output
	exec OptReadInt 500, 'Out_BreakBill_F1', 0, @out_breakByF1 output
	exec OptReadInt 500, 'Out_BreakBill_F2',0,  @out_breakByF2 output
   exec OptReadInt 500, 'Order_BreakBill_F3', 0, @order_breakByF3 output
	exec OptReadStr 500, 'BillSrcFilter', '', @BillSrcFilter output
	EXEC OPTREADINT 0, 'AVLINVAVGMETHOD', 0, @OPT_METHOD OUTPUT
	exec OptReadInt 90, 'ALCQTY2Match', 0, @ALCQTY2Match OUTPUT

	if @out_breakByF2 = 1
		exec OptReadStr 500, 'Out_BreakBill_F2Length', '1', @out_breakByF2Len output

  IF @OPT_METHOD = 0
  begin
	  --搜索配货池
	  set @msg = '搜索配货池, STORE:' + str(@storegid)
		  + ', GOODSCOND:' + @goodscond
	  exec AlcPoolWriteLog 0, 'SP:AlcPoolGenBill', @msg
	  exec AlcPoolSearchPool @storegid, @goodscond
	end

	--生成定单
	exec AlcPoolWriteLog 0, 'SP:AlcPoolGenBill', '生成定单'
	select @lastvdr = -1
	select @lastsort = ''
   select @lastF3 = ''
	if object_id('c_pool') is not null deallocate c_pool
	declare c_pool cursor for
	select gdgid, psralcqty, ordqty, autoalcqty, vendor, t.sort, t.TAXRATE, g.F3  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
	from alcpooltemp t, goods g
	where t.storegid = @storegid and g.Gid = t.gdgid
		and t.alc = '直配'
	order by vendor, t.sort, t.taxrate  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
	open c_pool
	fetch next from c_pool into @gdgid, @psralcqty, @ordqty, @autoalcqty, @vdr, @sort, @TaxRate, @f3 --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
	while @@fetch_status = 0
	begin
		--计算商品数量
		select @qty = @psralcqty
		if @qtypolicy = 0
		begin
			if @ordqty > @qty	set @qty = @ordqty
			if @autoalcqty > @qty	set @qty = @autoalcqty
		end else if @qtypolicy = 1
		begin
			if @qty = 0		set @qty = @ordqty
			if @qty = 0		set @qty = @autoalcqty
		end else if @qtypolicy = 2
		begin
			set @qty = @ordqty
			if @qty = 0		set @qty = @psralcqty
			if @qty = 0		set @qty = @autoalcqty
		end

		if @qty > 0	--2004.03.19 zyb
		begin
			--数量处理
			set @qty = @qty * @alccoef
			if @roundbycases = 1	--按箱数取整
			begin
				select @qpc = qpc from goods(nolock)
				where gid = @gdgid
				if @qpc is not null and @qpc > 0
				begin
					set @m = @qty / @qpc
					if abs(@m - round(@m, 0, 1)) >= 1e-4
					begin
						set @m = round(@m, 0, 1) + 1.0
						set @qty = @m * @qpc
					end
				end
			end
		end

		if @qty > 0	--2004.03.19 zyb
		begin
			--判断是否需要分单
			select @shouldnew = 0
			if @vdr <> @lastvdr	--定单按供应商分单
				set @shouldnew = 1
          if @f3 <> @lastf3
             set @shouldnew = 1
			if (@order_breakbysort = 1)	--按类别分单
				and (@sort <> @lastsort)
				set @shouldnew = 1
		--2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
			if (@order_breakbyTaxRate = 1)	--定单按税率分单
				and (@TaxRate <> @lastTaxRate)
				set @shouldnew = 1

			if @shouldnew = 1
			begin
				if not exists(select 1 from alcpoolgenbills(nolock) where billname = '定货单'
					and flag = 0 and dtlcnt = 0)--判断是否上一张单据是否空单据
				begin
					update alcpoolgenbills set flag = 1
					where billname = '定货单' and flag = 0
				end
			end

			--生成定单
			exec AlcPoolGenOrd @storegid, @vdr, @gdgid, @qty, @operator, @from -- add by hzl 2003-10-24

			set @lastvdr = @vdr
			set @lastsort = @sort
			set @lastTaxRate = @TaxRate  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
          set @lastF3 = @f3
		end

		fetch next from c_pool into @gdgid, @psralcqty, @ordqty, @autoalcqty, @vdr, @sort, @TaxRate, @f3  --2006.3.3, Edited by ShenMin, Q6276, 配货池对于定单的拆分增加按商品税率拆分
	end
	close c_pool
	deallocate c_pool

	if @@error <> 0 return 1

	--生成配货出货单和批发单
        if @out_breakbysort   = 0   update alcpooltemp set sort = ''  where storegid = @storegid
        if @out_breakbybillto = 0   update alcpooltemp set vendor = 1  where storegid = @storegid
        if @out_breakbycode   = 0   update alcpooltemp set gdcode = ''  where storegid = @storegid
        if @out_breakbyname   = 0   update alcpooltemp set name = ''  where storegid = @storegid
        if @out_breakbywrh    = 0   update alcpooltemp set wrh = 1  where storegid = @storegid
        if @out_breakbypsr    = 0   update alcpooltemp set psr = 1  where storegid = @storegid
        if @out_breakbyf1     = 0   update alcpooltemp set f1 = ''  where storegid = @storegid
        if @out_breakbyf2     = 0   update alcpooltemp set f2 = ''  where storegid = @storegid
	exec AlcPoolWriteLog 0, 'SP:AlcPoolGenBill', '生成配出单和批发单'
	select @lastsort = ''
	if object_id('c_pool') is not null deallocate c_pool
	declare c_pool cursor for
	select gdgid, psralcqty, ordqty, autoalcqty, vendor, sort, name, wrh, Psr, F1, F2--, SRCBILL --2003.05.29 Modified by wang xin
	from alcpooltemp
	where storegid = @storegid and alc = '统配'
	order by vendor, sort, gdcode, name, wrh, psr,f1,f2
	open c_pool
	fetch next from c_pool into @gdgid, @psralcqty, @ordqty, @autoalcqty, @vdr, @sort, @Name, @wrh, @psr, @f1, @f2--, @srcbill --2003.05.29 Modified by wang xin
	while @@fetch_status = 0
	begin
		--计算商品数量
		select @qty = @psralcqty
		select @from = 1
		if @qtypolicy = 0
		begin
			if @ordqty > @qty
			begin
				set @qty = @ordqty
				set @from = 2
			end
			if @autoalcqty > @qty
			begin
				set @qty = @autoalcqty
				set @from = 3
			end
		end else if @qtypolicy = 1
		begin
			if @qty = 0
			begin
				set @qty = @ordqty
				set @from = 2
			end
			if @qty = 0
			begin
				set @qty = @autoalcqty
				set @from = 3
			end
		end else if @qtypolicy = 2
		begin
			set @qty = @ordqty
			set @from = 2
			if @qty = 0
			begin
				set @qty = @psralcqty
				set @from = 1
			end
			if @qty = 0
			begin
				set @qty = @autoalcqty
				set @from = 3
			end
		end

		if @qty > 0  --2004.03.19 zyb
		begin
			--数量处理
			set @qty = @qty * @alccoef
			if @roundbyalcqty = 1	--按配货单位取整
			begin
				select @alcqty = alcqty from goods(nolock)
				where gid = @gdgid
				if @alcqty is not null and @alcqty > 0
				begin
					set @m = @qty / @alcqty
					if abs(@m - round(@m, 0, 1)) >= 0.5/*2003.06.17*/
						set @m = round(@m, 0, 1) + 1.0
					else
						set @m = round(@m, 0, 1)
					set @qty = @m * @alcqty
				end
				
				if @ALCQTY2Match = 1 --按第二配货单位取整
			  begin
			    set @salcqty = null
			    set @salcqstart = null
			    select @salcqty = salcqty, @salcqstart = salcqstart from gdstore(nolock)
			      where storegid = @storegid and gdgid = @gdgid
			    if @salcqty is null
			    begin
			      select @salcqty = salcqty, @salcqstart = salcqstart from goods(nolock)
			        where gid = @gdgid
			    end
			    if @salcqty is not null and @salcqty > 0
			    begin
			  	  if @qty > @salcqstart
			      begin
			    	  set @m = @qty / @salcqty
		  	    	if abs(@m - round(@m, 0, 1)) >= 0.5
			      	  set @m = round(@m, 0, 1) + 1.0
			      	else
			      	  set @m = round(@m, 0, 1)
			    	  set @qty = @m * @salcqty
			      end
			    end
			  end
			
			end		
		end

		if @qty > 0 --2004.03.19 zyb
		begin
			--判断是否需要分单
			set @shouldnew = 0
			if (@out_breakbybillto = 1) and (@vdr <> @lastvdr)	--按供应商分单
				set @shouldnew = 1
			if (@out_breakbysort = 1) and (@sort <> @lastsort)
				set @shouldnew = 1
			if (@out_breakbycode = 1) and (left(@code, @out_breakbycodelen) <> @lastcode)
				set @shouldnew =1
			if (@out_breakbyname = 1) and (@name <> @lastname)
				set @shouldnew = 1
			if (@out_breakbywrh = 1) and (@wrh <> @lastwrh)
				set @shouldnew = 1
			if (@out_breakbypsr =1 ) and (@psr <> @lastpsr)
				set @shouldnew = 1
			if (@out_breakbyF1 =1 ) and (@f1 <> @lastF1)
				set @shouldNew = 1
			if (@out_breakbyF2 = 1) and (left(@F2, @out_breakByF2Len) <> @lastF2)
				set @shouldnew = 1

			--生成单据
			if exists(select 1 from store(nolock) where gid = @storegid
				and property & 4 = 4) and @bill4jmstore = 1--对加盟店生成批发单
			begin
				select @cur_out_dtl_cnt = dtlcnt from alcpoolgenbills(nolock)
				where billname = '批发单' and flag = 0
				if (@shouldnew = 1) or (isnull(@cur_out_dtl_cnt, 0) >= @max_out_dtl_cnt)
					update alcpoolgenbills set flag = 1 where billname = '批发单' and flag = 0
				exec AlcPoolGenWholeSale @storegid, @gdgid, @qty, @from, @operator
			end if @ALCPOOLGENALCMETHOD = 0	--配出
			begin
				select @cur_out_dtl_cnt = dtlcnt from alcpoolgenbills(nolock)
				where billname = '配货出货单' and flag = 0
				if (@shouldnew = 1) or (isnull(@cur_out_dtl_cnt, 0) >= @max_out_dtl_cnt)
					update alcpoolgenbills set flag = 1 where billname = '配货出货单' and flag = 0
				exec AlcPoolGenAllocOut @storegid, @gdgid, @qty,@from, @operator, @BillSrcFilter
			end else
			begin
				select @cur_out_dtl_cnt = dtlcnt from alcpoolgenbills(nolock)
				where billname = '配货通知单' and flag = 0
				if (@shouldnew = 1) or (isnull(@cur_out_dtl_cnt, 0) >= @max_out_dtl_cnt)
					update alcpoolgenbills set flag = 1 where billname = '配货通知单' and flag = 0
				exec AlcPoolGenDistNotify @storegid,@gdgid,@qty,@operator,@From
			end

			set @lastvdr = @vdr
			set @lastsort = @sort
			select @lastcode = left(@code, @out_breakbycodelen)
			select @lastname = @name
			select @lastwrh = @wrh
			select @lastpsr = @psr
			select @lastF1 = @F1
			select @lastF2 = left(@f2, @out_breakbyf2len)
		end
		fetch next from c_pool into @gdgid, @psralcqty, @ordqty, @autoalcqty, @vdr, @sort,@Name, @wrh, @psr, @f1, @f2--, @srcbill
	end
	close c_pool
	deallocate c_pool
	if @@error <> 0 return 1

       --对已经生成的配货出货单明细进行排序
       if @orderby is not null and @orderby <>''
       begin
       if object_id('c_genbilldtl')is not null deallocate c_genbilldtl
        declare c_genbilldtl cursor for
        select num from alcpoolgenbills
                   where billname = '配货出货单'and flag in (0,1)
        for read only
        open c_genbilldtl
        fetch next from c_genbilldtl into @num
        while @@fetch_status = 0
        begin
           if object_id('tempdb..#temp') is not null drop table #temp
           set @sqlstr='
           select identity(int, 10001, 1) as id, stkoutdtl.line into #temp
           from stkoutdtl(nolock), goods(nolock)
           where stkoutdtl.cls = ''配货''
           and stkoutdtl.gdgid = goods.gid
           and stkoutdtl.num ='''+@num +''''
           + ' order by '+ @orderby
           + ' update stkoutdtl set line = #temp.id -10000
           from stkoutdtl, #temp where stkoutdtl.line = #temp.line and stkoutdtl.num = '''+@num+''''+' and stkoutdtl.cls = ''配货'''
         exec(@sqlstr)
            fetch next from c_genbilldtl into @num
        end
        close c_genbilldtl
        deallocate c_genbilldtl
	end

	--更新单据汇总及生成单据表
	exec AlcPoolWriteLog 0, 'SP:AlcPoolGenBill', '更新单据汇总'
	select @settleno = max(no) from monthsettle(nolock)
	if object_id('c_genbills') is not null deallocate c_genbills
	declare c_genbills cursor for
	select billname, num from alcpoolgenbills where flag in (0, 1)
	for update
	open c_genbills
	fetch next from c_genbills into @billname, @num
	while @@fetch_status = 0
	begin
		if @billname = '定货单'
		begin
			select
				@total = isnull(sum(total), 0),
				@tax = isnull(sum(tax), 0),
				@reccnt = count(*)
			from orddtl(nolock)
			where num = @num
			if @reccnt = 0
			begin
				delete from orddtl where num = @num
				delete from ord where num = @num
			end else
			begin
				update orddtl set
					settleno = @settleno
				where num = @num
				update ord set
					settleno = @settleno,
					total = @total,
					tax = @tax,
					reccnt = @reccnt
				where num = @num
			end
		end else if @billname = '配货出货单'
		begin
			select
				@total = isnull(sum(total), 0),
				@tax = isnull(sum(tax), 0),
				@reccnt = count(*)
			from stkoutdtl(nolock)
			where num = @num and cls = '配货'
			if @reccnt = 0
			begin
				delete from stkoutdtl where num = @num and cls = '配货'
				delete from stkout where num = @num and cls = '配货'
			end else
			begin
				update stkoutdtl set
					settleno = @settleno
				where num = @num and cls = '配货'
				update stkout set
					settleno = @settleno,
					total = @total,
					tax = @tax,
					reccnt = @reccnt
				where num = @num and cls = '配货'
			end
		end else if @billname = '批发单'
		begin
			select
				@total = isnull(sum(total), 0),
				@tax = isnull(sum(tax), 0),
				@reccnt = count(*)
			from stkoutdtl(nolock)
			where num = @num and cls = '批发'
			if @reccnt = 0
			begin
				delete from stkoutdtl where num = @num and cls = '批发'
				delete from stkout where num = @num and cls = '批发'
			end else
			begin
				update stkoutdtl set
					settleno = @settleno
				where num = @num and cls = '批发'
				update stkout set
					settleno = @settleno,
					total = @total,
					tax = @tax,
					reccnt = @reccnt
				where num = @num and cls = '批发'
			end
		end else if @billname = '配货通知单'
		begin
			select 	@reccnt = count(*)
			from DistNotifydtl(nolock)
			where num = @num

			update DistNotifydtl set
				settleno = @settleno
			where num = @num

			update DistNotify set
				settleno = @settleno,
				reccnt = @reccnt
			where num = @num
		end


		update alcpoolgenbills set flag = 2 where current of c_genbills
		fetch next from c_genbills into @billname, @num
	end
	close c_genbills
	deallocate c_genbills

--add by hzl 2003-10-24
	set @sqlstr='insert into alcpoolH(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
		srcnum, srcline, gennum, gentime, gencls, aparter, alcer, note )
		select storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
		srcnum, srcline, gennum, gentime, gencls, aparter, alcer, note
		from alcpoolhtemp(nolock)
		where gennum <> ''-'' and storegid = ' + str(@storegid) --edited by jinlei Q5350
	exec(@sqlstr)

	return (0)
end
GO
