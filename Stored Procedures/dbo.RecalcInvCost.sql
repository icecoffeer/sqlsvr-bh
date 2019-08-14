SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RecalcInvCost]
    @store int,
    @settleno int,
    @date datetime,
    @mode int--是否需要重算库存调整日报的数量
as
begin
	declare @bill char(10), @cls char(10), @num char(12), 
		@stat int, @line int, @fildate datetime, @cnt integer,
		@gdgid int, @gdgid2 int, @wrh int, @qty money, @cost money,
		@invprc money, @invcost money, @price money, @qty2 money,
		@total money,@inprc money

	print '得到期初值'
	print '  rgdwrh ...'
	begin transaction
	if not exists (select 1 from rgdwrh )
	begin 
	--delete from rgdwrh 
	insert into rgdwrh (gdgid, wrh, qty,invprc, invcost,fildate)
		select bgdgid, bwrh, fq,finvprc, isnull(finvcost,0),@date
		from invdrpt,goods g
		where astore = @store and asettleno = @settleno and adate = dateadd(day, -1, @date)
		and g.gid = invdrpt.bgdgid and g.sale = 1
	end
	commit transaction

	print '库存调整日报'
   if @mode = 1
      begin 
	begin transaction
	exec RecalcInvChgDrpt @store, @settleno, @date
	delete from invchgdrpt 
	from goodsh g 
	where g.gid = bgdgid and g.sale = 1 
	and adate = @date and asettleno = @settleno and astore = @store
	insert into invchgdrpt 
	select rinvchgdrpt.* from rinvchgdrpt, goodsh g  where g.gid = bgdgid and g.sale = 1  
	and adate = @date and asettleno = @settleno and astore = @store
--重算后并没有转入到正式表，而只是放在rinvchgdrpt
	commit transaction
      end
      	
	print '搜索需要计算的单据'
	print '  stkin ...'
	begin transaction
--是否要加入LOSS
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'stkin', m.cls, m.num, m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty+d.loss, d.price,d.total
		from stkin m, stkindtl d, goodsh g
		where m.cls = d.cls and m.num = d.num 
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date) 
	commit transaction
	print '  diralc ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'diralc', m.cls, m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty,d.alcprc,d.ALCAMT
		from diralc m, diralcdtl d, goodsh g
		where m.cls = d.cls and m.num = d.num
		and g.gid = d.gdgid and g.sale = 1
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
		and m.cls in ('直配进', '直配进退')
	commit transaction
	print '  stkinbck ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'stkinbck', m.cls, m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty, d.inprc,d.cost
		from stkinbck m, stkinbckdtl d, goodsh g
		where m.cls = d.cls and m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7)
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction
	print '  stkout ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'stkout', m.cls, m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty,d.inprc, d.cost
		from stkout m, stkoutdtl d, goodsh g
		where m.cls = d.cls and m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction
	print '  stkoutbck ...'--之后考虑零售
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'stkoutbck', m.cls, m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty,d.price, d.total
		from stkoutbck m, stkoutbckdtl d, goodsh g
		where m.cls = d.cls and m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction
	print '  buy ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'buy', m.posno, m.flowno,1, d.itemno, m.fildate, d.gid, m.wrh, d.qty, d.inprc,d.cost
		from buy1 m, buy2 d, goodsh g
		where m.posno = d.posno and m.flowno = d.flowno
		and g.gid = d.gid and g.sale = 1 
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction
	print '  ls ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'ls', '损耗', m.num,m.stat, d.line, m.fildate, d.gdgid, m.wrh, d.qtyls,d.inprc, d.cost
		from ls m, lsdtl d, goodsh g
		where m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction
	print '  ovf ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'ovf', '溢余', m.num,m.stat, d.line, m.fildate, d.gdgid, m.wrh, d.qtyovf, d.inprc,d.cost
		from ovf m, ovfdtl d, goodsh g
		where m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
	commit transaction

	print '  ck ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'ck', '盘点', m.num,1, d.line, m.ckdate, d.gdgid, d.wrh, d.qty - d.acntqty, d.inprc,d.cost
		from ck m, ckdtl d, goodsh g
		where m.num = d.num
		and g.gid = d.gdgid and g.sale = 1
		and m.ckdate between @date and dateadd(day, 1, @date)
	commit transaction

	print '  xf ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'xf', '调拨出', m.num,m.stat, d.line, m.fildate, d.gdgid, m.fromwrh, d.qty ,d.inprc, d.cost
		from xf m, xfdtl d, goodsh g
		where m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and  m.stat not in (0, 7) 
		and m.outdate between @date and dateadd(day, 1, @date)			
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'xf', '调拨进', m.num,m.stat, d.line, m.indate, d.gdgid, m.towrh, d.qty ,d.price, d.cost
		from xf m, xfdtl d, goodsh g
		where m.num = d.num
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat = 9
		and m.indate between @date and dateadd(day, 1, @date)		
	commit transaction	

	print '  MXF ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'mxf', '门店调出', m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty ,fromprice, d.fromcost
		from mxf m, mxfdtl d, goodsh g
		where m.num = d.num and m.fromstore=@store 
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'mxf', '门店调入', m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty ,toprice, d.TOTOTAL
		from mxf m, mxfdtl d, goodsh g
		where m.num = d.num and m.tostore=@store 
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)		
	commit transaction	
	
	print '  GDINVCHG ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'GDINVCHG', '转出', m.num,m.stat, d.line, m.fildate, d.gdgid, d.wrh, d.qty , d.price,d.TOTAL
		from GDINVCHG m, GDINVCHGdtl d, goodsh g
		where m.num = d.num 
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)	
	commit transaction

	
	print '  prcadj ...'
	begin transaction
	insert into rbill(bill,cls,num,stat,line,fildate,gdgid,wrh,qty,price,cost)
		select 'prcadj', '库存价', m.num,m.stat, d.line, isnull(m.launch,m.fildate) fildate, d.gdgid, m.wrh, d.qty , d.oldprc,d.newprc
		from prcadj m, prcadjdtl d, goodsh g
		where m.num = d.num and m.cls = d.cls and m.cls = '库存价'
		and g.gid = d.gdgid and g.sale = 1 
		and m.stat = 5
		and m.fildate between @date and dateadd(day, 1, @date)	
	commit transaction	
--还缺少process、inprcadj、rtl、rtlbck等



	print '清除报告库存成本调整额'
	begin transaction
	update invchgdrpt set di3 = 0
		from goodsh g
		where g.gid = bgdgid and g.sale = 1 
		and astore = @store and asettleno = @settleno and adate = @date
	commit transaction

	print '顺序计算库存成本'
	set @cnt = 0
	declare c cursor for
		select bill, cls, num,stat, line, fildate, gdgid, wrh, qty,isnull(price,0), cost
		from rbill
		where fildate between @date and dateadd(day, 1, @date)
		order by fildate,stat desc
		for read only
	open c
	fetch next from c into @bill, @cls, @num,@stat, @line, @fildate, @gdgid, @wrh, @qty,@price, @cost
	while @@fetch_status = 0
	begin
		set @cnt = @cnt + 1
		if @cnt / 500 * 500 = @cnt
			print '  已完成' + convert(char(10), @cnt) + convert(char, @fildate, 120) 
		begin transaction
		if (@bill = 'stkin')  and @stat in (1,2,6)--包括自营进、配进、调入
		begin
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh, @date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,isnull(@cost,0),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkindtl set inprc = @inprc where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			
		end
		if (@bill = 'stkin')  and @stat in (3,4)--包括自营进、配进、调入
		begin
			select @cost = -total ,@inprc = inprc,@qty = -qty
				from stkindtl
				where cls = @cls and line = @line
				and num = (select modnum from stkin where cls = @cls and num = @num)
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh, @date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			update stkindtl set inprc = @inprc where num = @num and cls = @cls and line = @line
		end
		else if @bill = 'diralc' and @cls = '直配进' and @stat in (1,2,6)
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update diralcdtl set inprc = @inprc where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh, @date
			update diralcdtl set cost = @cost
				where cls = @cls and num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'diralc' and @cls = '直配进' and @stat in (3,4)
		begin
			select @cost = -COST ,@inprc = inprc,@qty = -qty
				from diralcdtl
				where cls = @cls and line = @line
				and num = (select modnum from diralc where cls = @cls and num = @num)
			update diralcdtl set inprc = @inprc
				where cls = @cls and num = @num and line = @line
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh, @date
			update diralcdtl set cost = @cost
				where cls = @cls and num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkinbck' and @stat in (1,2,6)--这里的@inprc可能会为，原因是没有进货先退货
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkinbckdtl set inprc = @inprc where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			exec r_updinvprc '进货退货', @gdgid, @qty, 0, @wrh,@date, @cost output
			update stkinbckdtl set cost = @cost
				where cls = @cls and num = @num and line = @line
		end
		else if @bill = 'diralc' and @cls = '直配进退' and @stat in (1,2,6)--这里的@inprc可能会为，原因是没有进货先退货
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkinbckdtl set inprc = @inprc where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			exec r_updinvprc '进货退货', @gdgid, @qty, 0, @wrh, @date,@cost output
			update diralcdtl set cost = @cost
				where cls = @cls and num = @num and line = @line
		end
		else if @bill = 'stkinbck' and @stat in (3,4)	--冲单
		begin
			select @cost = COST ,@inprc = inprc
				from stkinbckdtl
				where cls = @cls and line = @line
				and num = (select modnum from stkinbck where cls = @cls and num = @num)
			set @qty2 = -@qty
			update stkinbckdtl set inprc = @inprc,cost=@cost where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			exec r_updinvprc '进货', @gdgid, @qty2, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'diralc' and @cls = '直配进退' and @stat in (3,4)	--冲单
		begin
			select @cost = COST, @inprc = inprc
				from diralcdtl
				where cls = @cls and line = @line
				and num = (select modnum from diralc where cls = @cls and num = @num)
			set @qty2 = -@qty
			update diralcdtl set inprc = @inprc,cost = @cost where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			exec r_updinvprc '进货', @gdgid, @qty2, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkout' and @stat in (1,2,6)--这里的@inprc可能会为null，原因是没有进货就配货
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkoutdtl set inprc = @inprc where num = @num and cls = @cls and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh,-@qty, @price,-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			exec r_updinvprc '销售', @gdgid, @qty, 0, @wrh,@date, @cost output
			update stkoutdtl set cost = @cost
				where cls = @cls and num = @num and line = @line
		end
		else if @bill = 'buy'
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update buy2 set inprc = @inprc where posno = @cls and flowno = @num and itemno = @line
			exec r_updinvprc '零售', @gdgid, @qty, 0, @wrh,@date, @cost output
			update buy2 set cost = isnull(@cost,@qty*@price)
				where posno = @cls and flowno = @num and itemno = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,isnull(-@cost,-@qty*@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkout' and @stat in (3,4)	--冲单
		begin
			select @cost = COST, @inprc = inprc
				from stkoutdtl
				where cls = @cls and line = @line
				and num = (select modnum from stkout where cls = @cls and num = @num)
			set @qty2 = -@qty
			update stkoutdtl set inprc = @inprc,cost =-@cost where num = @num and cls = @cls and line = @line-- and gdgid = @gdgid
			exec r_updinvprc '进货', @gdgid, @qty2, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkoutbck'  and @cls = '配货' and @stat in (1,2,6)--配货退货，COST就为发生额
		begin
			
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkoutbckdtl set inprc = @inprc ,cost = @cost where cls = @cls and num = @num and line = @line
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkoutbck'  and @cls in ('配货','批发') and @stat in (3,4)--传入的为负数
		begin
			
			select @cost = -TOTAL, @inprc = inprc,@qty = -qty
				from stkoutbckdtl
				where cls = @cls and line = @line
				and num = (select modnum from stkoutbck where cls = @cls and num = @num)
			update stkoutbckdtl set inprc = @inprc ,cost = @cost where  cls = @cls and num = @num and line = @line
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @inprc,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'stkoutbck'  and @cls = '批发' and @stat in (1,2,6)--暂时不考虑@CLS为零售的退货单
		begin
			
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update stkoutbckdtl set inprc = @inprc where cls = @cls and num = @num and line = @line
			exec r_updinvprc '销售退货', @gdgid, @qty, 0, @wrh,@date, @cost output
			update stkoutbckdtl set cost = isnull(@cost,@qty*@inprc)
				where cls = @cls and num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @inprc,isnull(@cost,@qty*@inprc),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'ls' and @stat not in (3,4)
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update lsdtl set inprc = @inprc where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, isnull(@inprc,@price),-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			exec r_updinvprc '销售', @gdgid, @qty, 0, @wrh, @date,@cost output
			update lsdtl set cost = @cost
				where num = @num and line = @line
		end
		else if @bill = 'ls' and @stat  in (3,4)	--冲单,传入的为正数
		begin
			select @cost = COST,@inprc = inprc
				from lsdtl
				where line = @line
				and num = (select modnum from ls where num = @num)
			set @qty2 = -@qty
			update lsdtl set inprc = @inprc ,cost = -@cost where num = @num and line = @line
			exec r_updinvprc '进货', @gdgid, @qty2, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @inprc,@cost,@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'ovf' and @stat not in (3,4)
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update ovfdtl set inprc = @inprc where num = @num and line = @line
			exec r_updinvprc '销售退货', @gdgid, @qty, 0, @wrh,@date, @cost output
			update ovfdtl set cost = isnull(@cost,@qty*inprc)
				where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, isnull(@inprc,@price),@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'ovf' and @stat  in (3,4)	--冲单,传入的为负数
		begin
			select @cost = -COST,@inprc = inprc, @qty = -qtyovf
				from ovfdtl
				where line = @line
				and num = (select modnum from ovf where num = @num)
			update ovfdtl set inprc = @inprc,cost = @cost where num = @num and line = @line
			exec r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @inprc,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'ck'--考虑到取不到快照时的核算价，就取盘入时前一天的核算价为快照核算价
		begin
			select @inprc = isnull(invprc,@price) from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = dateadd(day,-1,@date)
			if @@rowcount > 0
			   update ckdtl set inprc = @inprc where num = @num and line = @line
			select @price = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update ckdtl set inprc2 = @price where num = @num and line = @line
			if @qty<>0
			   exec r_updinvprc '盘点', @gdgid, @qty, 0, @wrh, @date,@cost output
			if (isnull(@cost,0)-isnull(@qty*@inprc,0))<>0
			insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I)
			  values(@date, @settleno,@wrh,@gdgid,@qty,@cost - @qty*@inprc) 
			update ckdtl set cost = isnull(@cost,@qty*@inprc)
				where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @inprc,isnull(@cost,@qty*@inprc),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'xf' and @cls='调拨出'
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh 
			if @@rowcount > 0
			   update xfdtl set inprc = @inprc where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, isnull(@inprc,@price),-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			execute r_updinvprc '内部调拨出', @gdgid, @qty, 0, @wrh,@date, @cost output
		        execute r_updinvprc '内部调拨进', @GDGID, @QTY, @cost, -100,@date 
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = -100 and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, -100, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = -100 and fildate=@date					
			update xfdtl set cost = @cost
				where num = @num and line = @line
		end
		else if @bill = 'xf' and @cls='调拨进'
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = dateadd(day,-1,@date)
			if @@rowcount > 0
			   update xfdtl set inprc = @inprc where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = -100 and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, -100, -@qty, isnull(@inprc,@price),-@qty*isnull(@inprc,@price),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = -100 and fildate=@date
			execute r_updinvprc '内部调拨出', @gdgid, @qty, 0, -100, @date,@cost output
		        execute r_updinvprc '内部调拨进', @GDGID, @QTY, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh =@wrh  and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,@cost,@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date					
			update xfdtl set cost = @cost
				where num = @num and line = @line
		end	
		else if @bill = 'mxf' and @cls='门店调出' and @stat not in (3,4)
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update mxfdtl set inprc = @inprc where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,isnull(-@cost,0),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			execute r_updinvprc '销售', @gdgid, @qty, 0, @wrh,@date, @cost output 
			update mxfdtl set fromcost = isnull(@cost,qty*inprc)
				where num = @num and line = @line
                end
		else if @bill = 'mxf' and @cls='门店调出' and @stat in (3,4)--冲单，传入的是正数
		begin
			select @cost = fromcost ,@inprc = inprc ,@qty = qty
			from mxfdtl where line = @line 
			and num = (select modnum from mxf where num = @num)
		update mxfdtl set inprc = @inprc,fromcost = -@cost where num = @num and line = @line
			execute r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
		if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,isnull(@cost,0),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end	
		else if @bill = 'mxf' and @cls='门店调入' and @stat not in (3,4)
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update mxfdtl set inprc = @inprc where num = @num and line = @line
			execute r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
			update mxfdtl set tocost = isnull(@cost,qty*inprc)--,tocost =isnull(@cost,qty*inprc)
				where num = @num and line = @line
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,isnull(@cost,0),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		else if @bill = 'mxf' and @cls='门店调入' and @stat  in (3,4)--冲单 传入为负数
		begin
			select @cost = -tototal ,@inprc = inprc ,@qty = -qty
			from mxfdtl where line = @line 
			and num = (select modnum from mxf where num = @num)
			update mxfdtl set inprc = @inprc,tocost = @cost where num = @num and line = @line
			execute r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, @qty, @price,isnull(@cost,0),@date)
			else
				update rgdwrh set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
		end
		/*else if @bill = 'GDINVCHG' and @stat not in (3,4)--先不考虑库存转移，因为库存转移过程还有问题
		begin
			select @inprc = invprc from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate = @date
			if @@rowcount > 0
			   update GDINVCHGdtl set inprc = @inprc where num = @num and line = @line
			execute r_updinvprc '销售', @gdgid, @qty, 0, @wrh,@date,@cost output
			if not exists (select 1 from rgdwrh where gdgid = @gdgid and wrh = @wrh and fildate=@date)
				insert into rgdwrh (gdgid, wrh, qty, invprc,invcost,fildate)
					values (@gdgid, @wrh, -@qty, @price,isnull(-@cost,0),@date)
			else
				update rgdwrh set qty = qty - @qty
					where gdgid = @gdgid and wrh = @wrh and fildate=@date
			select @qty = qty2 ,@wrh = wrh2 ,@gdgid = gdgid2 from gdinvchgdtl	
                               where num = @num and line = @line
                        execute r_updinvprc '进货', @gdgid, @qty, @cost, @wrh,@date       
			if not exists (select 1 from RINV  where gdgid = @gdgid and wrh = @wrh and fildate = @date)
				insert into RINV  (gdgid, wrh, qty, store,fildate)
					values (@gdgid, @wrh, @qty, @store,@date)
			else
				update RINV  set qty = qty + @qty
					where gdgid = @gdgid and wrh = @wrh and fildate = @date
		end*/
		else if @bill = 'prcadj' and @cls='库存价' --这里的@cost为newprc,@qty为当时的库存数
		begin
			select @price = invprc from rgdwrh where wrh = @wrh and fildate = @date and gdgid = @gdgid
			update prcadjdtl set oldprc = @price where num =@num and cls = @cls and line = @line
			update rgdwrh set invprc = @cost,invcost = @qty * @cost
			if (isnull(@qty*@cost,0)-isnull(@qty*@price,0))<>0
			insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
      			   values (@date,@settleno,@wrh,@gdgid,@qty,@qty*@cost - @qty*@price)
		end
		commit transaction
                fetch next from c into @bill, @cls, @num,@stat, @line, @fildate, @gdgid, @wrh, @qty,@price, @cost
	end
	close c
	deallocate c
	print '  共完成' + convert(char(10), @cnt)
	
	print '进货日报'
	begin transaction
	exec RecalcInDRpt @store, @settleno, @date
	delete from indrpt where adate = @date and asettleno = @settleno and astore = @store
	insert into indrpt 
	select * from rindrpt  where adate = @date and asettleno = @settleno and astore = @store	
	commit transaction
	
	print '出货日报'
	begin transaction
	exec RecalcOutDrpt @store, @settleno, @date
	delete from outdrpt where adate = @date and asettleno = @settleno and astore = @store
	insert into outdrpt 
	select * from routdrpt  where adate = @date and asettleno = @settleno and astore = @store	
	commit transaction

	print '库存调整日报 - 损溢成本'
	begin transaction
	update invchgdrpt set di1 = 0
		where astore = @store and asettleno = @settleno and adate = @date
	declare c cursor for
		select d.gdgid, m.wrh, sum(d.cost)
		from ls m, lsdtl d
		where m.num = d.num and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
		group by d.gdgid, m.wrh
		for read only
	open c
	fetch next from c into @gdgid, @wrh, @cost
	while @@fetch_status = 0
	begin
		update invchgdrpt set di1 = -@cost
			where astore = @store and asettleno = @settleno and adate = @date
			and bgdgid = @gdgid and bwrh = @wrh
		fetch next from c into @gdgid, @wrh, @cost
	end
	close c
	deallocate c
	declare c cursor for
		select d.gdgid, m.wrh, sum(d.cost)
		from ovf m, ovfdtl d
		where m.num = d.num and m.stat not in (0, 7) 
		and m.fildate between @date and dateadd(day, 1, @date)
		group by d.gdgid, m.wrh
		for read only
	open c
	fetch next from c into @gdgid, @wrh, @cost
	while @@fetch_status = 0
	begin
		update invchgdrpt set di1 = di1 + @cost
			where astore = @store and asettleno = @settleno and adate = @date
			and bgdgid = @gdgid and bwrh = @wrh
		fetch next from c into @gdgid, @wrh, @cost
	end
	close c
	deallocate c
	commit transaction
	
	print '库存调整日报 - 盈亏成本'
	begin transaction
	update invchgdrpt set di2 = 0
		where astore = @store and asettleno = @settleno and adate = @date
	declare c cursor for
		select d.gdgid, d.wrh, sum(d.cost)
		from ck m, ckdtl d
		where m.num = d.num
		and m.ckdate between @date and dateadd(day, 1, @date)
		group by d.gdgid, d.wrh		--modified by linbo
		for read only
	open c
	fetch next from c into @gdgid, @wrh, @cost
	while @@fetch_status = 0	--modified by linbo
	begin
		update invchgdrpt set di2 = @cost
			where astore = @store and asettleno = @settleno and adate = @date
			and bgdgid = @gdgid and bwrh = @wrh
		fetch next from c into @gdgid, @wrh, @cost
	end
	close c
	deallocate c
	commit transaction

	print '转入库存成本调整到R表中'
	begin transaction	
         insert into rinvchgdrpt
            select invchgdrpt.* from invchgdrpt, goodsh g  where g.gid = bgdgid and g.sale = 1  
	    and adate = @date and asettleno = @settleno and astore = @store	
	commit transaction	

	print '库存日报'
	begin transaction
	exec RecalcInvDrpt @store, @settleno, @date
	delete from invdrpt where adate = @date and asettleno = @settleno and astore = @store
	insert into invdrpt 
	select * from rinvdrpt  where adate = @date and asettleno = @settleno and astore = @store	
	commit transaction	

--修改INV表的数量
    if  @mode = 1
      begin
	print '库存数量'
	begin transaction
	declare c cursor for
		select r.gdgid, r.wrh, sum(r.qty), sum(r.qty*g.rtlprc)
		from rgdwrh r,goodsh g
		where fildate = @date
		and g.gid = r.gdgid
		group by r.gdgid, r.wrh
	open c
	fetch next from c into @gdgid, @wrh, @qty, @total
	while @@fetch_status = 0
	begin
		update inv set
			qty = @qty, total = @total 
			where store = @store and   @date = convert(char(10),getdate(),102)
			and gdgid = @gdgid and wrh = @wrh
		fetch next from c into @gdgid, @wrh, @qty, @total
	end
	close c
	deallocate c
	update inv set qty = 0, total = 0
		where store = @store and   @date = convert(char(10),getdate(),102)
		and not exists (select 1 from rgdwrh i where gdgid = i.gdgid and wrh = i.wrh and @date = convert(char(10),getdate(),102) ) 
	commit transaction
     end

end
GO
