SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolSearchPool](
	@storegid	int,
	@goodscond	varchar(255),
	@DelFlag int = 0  --add by jinlei Q5350
)
as
begin
	declare
		@sqlstr varchar(2048),
		@gdgid	int,
		@qty	money,
		@defsortlen int,
		@order_sortlen int,
		@out_sortlen int,
		@psrdatediff int,
		@orddatediff int,
		@StoreGdAlcStrategry int,  --门店配货方式取法，任务单1334
		@GenAlcLimit int,		   --是否对没有分货员和配货员的配货池数据生成单据,任务单1536
		@SameSrcgrpProcMethod int,  --同来源数据（相同商品）的取数量策略，取值:0(Def)=合计, 1=最大值
		@BillSrcFilter Varchar(20)         --用于美益佳推荐报货

	select @defsortlen = alen from system(nolock)
	exec OptReadInt 500, 'order_sortlen', @defsortlen, @order_sortlen output
	exec OptReadInt 500, 'out_sortlen', @defsortlen, @out_sortlen output
	exec OptReadInt 500, 'psrdatediff', 0, @psrdatediff output
	exec OptReadInt 500, 'orddatediff', 0, @orddatediff output
	exec OptReadInt 500, 'GenAlcLimit', 0, @GenAlcLimit output
	exec OptReadInt 0, 'StoreGdAlcStrategy', 0, @StoreGdAlcStrategry output /*2003.11.18 by zyb*/
	exec OptReadInt 500, 'SameSrcgrpProcMethod', 0, @SameSrcgrpProcMethod output --Fanduoyi 20040909
	exec OptReadStr 500, 'BillSrcFilter', '', @BillSrcFilter output

  if @DelFlag = 0
  begin
    truncate table alcpoolhtemp
    truncate table alcpooltemp
  end
	-- begin add by hzl 2003-10-24
	if @GenAlcLimit = 0
	begin
		set @sqlstr = 'insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
			srcnum, srcline, note, aparter, alcer, isused)
			select alcpool.storegid, alcpool.gdgid, alcpool.line, alcpool.qty, alcpool.srcqty, alcpool.dmddate, alcpool.srcgrp,
			alcpool.srcbill, alcpool.srccls,alcpool.srcnum, alcpool.srcline, alcpool.note, aparter, alcer, 0
			from alcpool(nolock), goods(nolock)
			where alcpool.gdgid = goods.gid
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and goods.alc in (''直配'', ''统配'')'
		--Fanduoyi 2004.01.07 1583
		if @StoreGdAlcStrategry = 1
		set @sqlstr = 'insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
			srcnum, srcline, note, aparter, alcer, isused)
			select alcpool.storegid, alcpool.gdgid, alcpool.line, alcpool.qty, alcpool.srcqty, alcpool.dmddate, alcpool.srcgrp,
			alcpool.srcbill, alcpool.srccls,alcpool.srcnum, alcpool.srcline, alcpool.note, aparter, alcer, 0
			from alcpool(nolock) left join goods(nolock) on alcpool.gdgid = goods.gid
			     left join gdstore(nolock) on alcpool.storegid = gdstore.storegid and gdstore.gdgid = goods.gid
			where (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and isnull(gdstore.alc, goods.alc) in (''直配'', ''统配'')'

		if @goodscond is not null and @goodscond <> ''
			set @sqlstr = @sqlstr + ' and ' + @goodscond
		exec(@sqlstr)
		-- end add by hzl 2003-10-24

		set @sqlstr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, Name, wrh, Psr, F1, F2)
			select distinct ' + str(@storegid) + ', alcpool.gdgid, goods.code, goods.alc, goods.billto,
			case goods.alc when ''直配'' then left(goods.sort, ' + str(@order_sortlen) + ') else left(goods.sort, ' + str(@out_sortlen) + ') end,
			goods.name, goods.wrh, goods.psr, goods.F1, goods.F2
			from alcpool(nolock), goods(nolock)
			where alcpool.gdgid = goods.gid
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and goods.alc in (''直配'', ''统配'')'

		if @StoreGdAlcStrategry = 1
		set @sqlstr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, Name, wrh, Psr, F1, F2)
			select distinct ' + str(@storegid) + ', alcpool.gdgid, goods.code, isnull(gdstore.alc, goods.alc), goods.billto,
			case isnull(gdstore.alc, goods.alc) when ''直配'' then left(goods.sort, ' + str(@order_sortlen) + ') else left(goods.sort, ' + str(@out_sortlen) + ') end,
			goods.name, goods.wrh, goods.psr, goods.F1, goods.F2
			from alcpool(nolock) left join goods(nolock) on alcpool.gdgid = goods.gid
			     left join gdstore(nolock) on alcpool.storegid = gdstore.storegid and gdstore.gdgid = goods.gid
			where (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and isnull(gdstore.alc, goods.alc) in (''直配'', ''统配'')'

		if @goodscond is not null and @goodscond <> ''
			set @sqlstr = @sqlstr + ' and ' + @goodscond
		exec(@sqlstr)
		if @SameSrcgrpProcMethod = 0  --同一来源取合计 2005.01.13 3390
		begin
			update alcpooltemp
			set psralcqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 1
					and dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)
				)
			where storegid = @storegid

			if rtrim(@BillSrcFilter) = '非推荐报货'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) <> '推荐报货'
				)
				where storegid = @storegid
			else if rtrim(@BillSrcFilter) = '采购分货'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) like '采配%'
				)
				where storegid = @storegid
			else
			if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'

			    update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) = rtrim(@BillSrcFilter)
				)
				where storegid = @storegid
			else
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
				)
				where storegid = @storegid

			update alcpooltemp
			set autoalcqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 3)
			where storegid = @storegid
		end
		else if @SameSrcgrpProcMethod = 1  --同一来源取最大值 2005.01.13 3390
		begin
			update alcpooltemp
			set psralcqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 1
					and dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)
				)
			where storegid = @storegid

			if rtrim(@BillSrcFilter) = '非推荐报货'
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) <> '推荐报货'
				)
				where storegid = @storegid
		--ShenMin
			else if rtrim(@BillSrcFilter) = '采购分货'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) like '采配%'
				)
				where storegid = @storegid
			else
			if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) = rtrim(@BillSrcFilter)
				)
				where storegid = @storegid
			else
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
				)
				where storegid = @storegid

			update alcpooltemp
			set autoalcqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 3)
			where storegid = @storegid
		end

	end
	else begin
		set @sqlstr = 'insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
			srcnum, srcline, note, aparter, alcer, isused)
			select alcpool.storegid, alcpool.gdgid, alcpool.line, alcpool.qty, alcpool.srcqty, alcpool.dmddate, alcpool.srcgrp,
			alcpool.srcbill, alcpool.srccls,alcpool.srcnum, alcpool.srcline, alcpool.note, aparter, alcer, 0
			from alcpool(nolock), goods(nolock)
			where alcpool.gdgid = goods.gid and alcpool.Aparter is not null and alcpool.Alcer is not null
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and goods.alc in (''直配'', ''统配'')'
		--Fanduoyi 2004.01.07 1583
		if @StoreGdAlcStrategry = 1
		set @sqlstr = 'insert into alcpoolHtemp(storegid, gdgid, line, qty, srcqty, dmddate, srcgrp, srcbill, srccls,
			srcnum, srcline, note, aparter, alcer, isused)
			select alcpool.storegid, alcpool.gdgid, alcpool.line, alcpool.qty, alcpool.srcqty, alcpool.dmddate, alcpool.srcgrp,
			alcpool.srcbill, alcpool.srccls,alcpool.srcnum, alcpool.srcline, alcpool.note, aparter, alcer, 0
			from alcpool(nolock) left join goods(nolock) on alcpool.gdgid = goods.gid
			     left join gdstore(nolock) on alcpool.storegid = gdstore.storegid and gdstore.gdgid = goods.gid
			where alcpool.Aparter is not null and alcpool.Alcer is not null
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and isnull(gdstore.alc, goods.alc) in (''直配'', ''统配'')'

		if @goodscond is not null and @goodscond <> ''
			set @sqlstr = @sqlstr + ' and ' + @goodscond
		exec(@sqlstr)
		-- end add by hzl 2003-10-24

		set @sqlstr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, Name, wrh, Psr, F1, F2)
			select distinct ' + str(@storegid) + ', alcpool.gdgid, goods.code, goods.alc, goods.billto,
			case goods.alc when ''直配'' then left(goods.sort, ' + str(@order_sortlen) + ') else left(goods.sort, ' + str(@out_sortlen) + ') end,
			goods.name, goods.wrh, goods.psr, goods.F1, goods.F2
			from alcpool(nolock), goods(nolock)
			where alcpool.gdgid = goods.gid and alcpool.Aparter is not null and alcpool.Alcer is not null
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and goods.alc in (''直配'', ''统配'')'
		--Fanduoyi 2004.01.07 1583
		if @StoreGdAlcStrategry = 1
		set @sqlstr = 'insert into alcpooltemp(storegid, gdgid, gdcode, alc, vendor, sort, Name, wrh, Psr, F1, F2)
			select distinct ' + str(@storegid) + ', alcpool.gdgid, goods.code, isnull(gdstore.alc, goods.alc), goods.billto,
			case isnull(gdstore.alc, goods.alc) when ''直配'' then left(goods.sort, ' + str(@order_sortlen) + ') else left(goods.sort, ' + str(@out_sortlen) + ') end,
			goods.name, goods.wrh, goods.psr, goods.F1, goods.F2
			from alcpool(nolock) left join goods(nolock) on alcpool.gdgid = goods.gid
			     left join gdstore(nolock) on alcpool.storegid = gdstore.storegid and gdstore.gdgid = goods.gid
			where alcpool.Aparter is not null and alcpool.Alcer is not null
				and (((srcgrp = 1) and (alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@psrdatediff) + ', getdate()), 102)))
					or (alcpool.srcgrp = 2 and alcpool.dmddate <= convert(varchar(10), dateadd(day, ' + str(@orddatediff) + ', getdate()), 102))
					or (alcpool.srcgrp = 3))
				and alcpool.storegid = ' + str(@storegid) + '
				and isnull(gdstore.alc, goods.alc) in (''直配'', ''统配'')'

		if @goodscond is not null and @goodscond <> ''
			set @sqlstr = @sqlstr + ' and ' + @goodscond
		exec(@sqlstr)

		if @SameSrcgrpProcMethod = 0  --同一来源取合计 2005.01.13 3390
		begin
			update alcpooltemp
			set psralcqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 1
					and dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)
				)
			where storegid = @storegid

			if rtrim(@BillSrcFilter) = '非推荐报货'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) <> '推荐报货'
				)
				where storegid = @storegid
		--ShenMin
			else if rtrim(@BillSrcFilter) = '采购分货'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) like '采配%'
				)
				where storegid = @storegid
			else if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) = rtrim(@BillSrcFilter)
				)
				where storegid = @storegid
			else
				update alcpooltemp
				set ordqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
				)
				where storegid = @storegid

			update alcpooltemp
			set autoalcqty = (select isnull(sum(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 3)
			where storegid = @storegid
		end
		else if @SameSrcgrpProcMethod = 1  --同一来源取最大值 2005.01.13 3390
		begin
			update alcpooltemp
			set psralcqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 1
					and dmddate <= convert(varchar(10), dateadd(day, @psrdatediff, getdate()), 102)
				)
			where storegid = @storegid


			if rtrim(@BillSrcFilter) = '非推荐报货'
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) <> '推荐报货'
				)
				where storegid = @storegid
		--ShenMin
			else if rtrim(@BillSrcFilter) = '采购分货'
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) like '采配%'
				)
			else if rtrim(@BillSrcFilter) <> '' and rtrim(@BillSrcFilter) <> '（全部）'
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
					and rtrim(srcbill) = rtrim(@BillSrcFilter)
				)
				where storegid = @storegid
			else
				update alcpooltemp
				set ordqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 2
					and dmddate <= convert(varchar(10), dateadd(day, @orddatediff, getdate()), 102)
				)
				where storegid = @storegid

			update alcpooltemp
			set autoalcqty = (select isnull(max(qty), 0)
				from alcpool(nolock)
				where storegid = @storegid and alcpool.Aparter is not null and alcpool.Alcer is not null
					and gdgid = alcpooltemp.gdgid
					and srcgrp = 3)
			where storegid = @storegid
		end

	end
	--zyb
	if @StoreGdAlcStrategry = 1
		update alcpooltemp set alc = isnull(gdstore.alc, goods.alc)
		from alcpooltemp, gdstore(nolock), goods(nolock)
		where alcpooltemp.storegid = gdstore.storegid  --Fanduoyi 1760
		and alcpooltemp.gdgid = gdstore.gdgid
		and goods.gid = gdstore.gdgid
		and alcpooltemp.storegid = @storegid --add by jinlei Q5350

	return (0)
end
GO
