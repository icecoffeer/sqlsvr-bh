SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolGenOrd](
	@storegid int,
	@vendor int,
	@gdgid int,
	@qty money,
	@operator int,
	@from 	int
)
as
begin
	declare
		@num char(10),
		@settleno smallint,
		@src int,
		@line smallint,
		@price money,
		@wrh int,
		@taxrate money,
		@invqty money,
		@defprc	varchar(25),
		@prminprc	money,
		@sqlstr	varchar(255),
		@applygftagm smallint,
		@gftgid int,
		@gftqty money,
		@gftwrh int,
		@inqty money,
		@qpc money,
		@isltd int,
		@msg	varchar(255)
	declare @ExpType int, @ExpDays int
	exec optreadint 114, 'TransitDays', 0, @ExpType output
	if @ExpType = 1  --取供应商送货时间
		select @ExpDays = days from vendor(nolock) where gid = @vendor
	else
		exec optreadint 114, '有效期', 1, @ExpDays output
	if @ExpDays is null or @ExpDays <= 0
		set @ExpDays = 1
	exec OptReadInt 500, 'applygftagm', 0, @applygftagm output

	--限制定货和清场品判断  move here by zyb 2002.11.18 防止出现空单
	exec GetGoodsOutIsLtd @storegid, @gdgid, @isltd output
	if (@isltd & 2 = 2) or (@isltd & 8 = 8)
	begin
		set @msg = '商品' + str(@gdgid) + '是限制定货或清场品'
		exec AlcPoolWriteLog 1, 'SP:AlcPoolGenOrd', @msg
		return 0
	end

	--是否需要开始新的一张单据
	select @num = num, @line = dtlcnt from alcpoolgenbills(nolock)
		where billname = '定货单'
		and flag = 0
	if @num is null
	begin
		--抢占单号
		select @src = usergid from system(nolock)
		select @num = isnull(max(num), '0000000001') from ord(nolock)
		exec NEXTBN @num, @num output
		insert into ord(num, settleno, wrh, vendor, note, fildate,
			filler, stat, reccnt, src, receiver)
		values(@num, -1, 1, 1, '由配货池生成', getdate(),
			@operator, 0, 0, @src, @storegid)
		insert into autoalloclog(storegid, cls, num, oper, atime)
		values(@storegid, '定货', @num, @operator, getdate())

		--在生成单据表中记录
		insert into alcpoolgenbills(billname, num, dtlcnt, flag)
		values('定货单', @num, 0, 0)
	end

	--计算有关明细值
	select @line = isnull(@line, 0) + 1
	if @line = 1 --第一条商品，更改汇总信息
	begin
		select @wrh=wrh from goods(nolock) where gid = @gdgid --by zhouchunze
		update ord set
		  wrh = @wrh, vendor = @vendor, receiver = @storegid, ExpDate = getdate() + isnull(@ExpDays, 1)
		where num = @num
	end

	--取得进价
	exec GetGoodsPrmStkInPrc @vendor, @storegid, @gdgid, @prminprc output
	if @prminprc <= 0
	begin
		exec OptReadStr 500, 'OrdDefPrc', 'LSTINPRC', @defprc output
		if object_id('#tmp_prc') is not null drop table #tmp_prc
		create table #tmp_prc(prc money)
		set @sqlstr = 'insert into #tmp_prc select ' + @defprc
			+ ' from goods(nolock)'
			+ ' where gid = ' + ltrim(str(@gdgid))
		exec(@sqlstr)
		select @price = prc from #tmp_prc
		if @price is null
			select @price = 0
	end else
	  set @price = @prminprc

	select
		@wrh = wrh,
		@taxrate = taxrate
	from goods(nolock)
	where gid = @gdgid
	declare @vNewUserGid int
	select @vNewUserGid = USERGID from SYSTEM(nolock)
	select @invqty = isnull(AVLQTY, 0)
	from V_ALCINV(nolock)
	where gdgid = @gdgid and wrh = @wrh and store = @vNewUserGid
	if @invqty is null
		set @invqty = 0
	select @qpc = isnull(qpc, 1) from goods(nolock) where gid = @gdgid
	if @qpc = 0
		set @qpc = 1

	--插入一条明细
	if not exists(select 1 from orddtl
	               where num = @num and gdgid = @gdgid and fromgid = @gdgid and flag = 0)
  	insert into orddtl(settleno, num, line, gdgid, cases, qty, price,
  		total, tax, wrh, invqty, fromgid, flag)
  	values(-1, @num, @line, @gdgid, @qty / @qpc, @qty, @price,
  		convert(decimal(20, 2), @qty * @price),
  		convert(decimal(20, 2), @qty * @price * @taxrate / (100 + @taxrate)), @wrh,
  		@invqty, @gdgid, 0)
  else  --3878 当不同的@from时会产生重复dtl
    update orddtl set
      cases = (qty + @qty) / @qpc, qty = qty + @qty,
      total = convert(decimal(20, 2), (qty + @qty) * @price),
      tax = convert(decimal(20, 2), (qty + @qty) * @price * @taxrate / (100 + @taxrate))
    where num = @num and gdgid = @gdgid and fromgid = @gdgid and flag = 0

	--处理赠品
	if @applygftagm = 1
	begin
		if object_id('c_gft') is not null deallocate c_gft
		declare c_gft cursor for
		select g.gid, g.wrh, f.inqty, f.gftqty
		from gift f(nolock)
		left join goods g(nolock) on f.gftgid = g.gid
		left join goods h(nolock) on f.gdgid = h.gid
		where f.lstid in (
			select max(lstid) from gift
			where gdgid = @gdgid
				and vendor = @vendor
				and start < getdate()
				and finish > getdate()
				and storegid = (select usergid from system(nolock))
				group by gdgid, gftgid
			)
			and f.storegid = (select usergid from system(nolock))
		open c_gft
		fetch next from c_gft into @gftgid, @gftwrh, @inqty, @gftqty
		while @@fetch_status = 0
		begin
			set @line = @line + 1
    	if not exists(select 1 from orddtl
	               where num = @num and gdgid = @gftgid and fromgid = @gdgid and flag = 1)
  			insert into orddtl(settleno, num, line, gdgid, qty, price,
  				total, tax, wrh, fromgid, flag)
  			values(-1, @num, @line, @gftgid, floor(@qty/@inqty)* @gftqty, 0,
  			  0, 0, @gftwrh, @gdgid, 1)
  		else
        update orddtl set
          qty = qty + floor(@qty/@inqty)* @gftqty
        where num = @num and gdgid = @gftgid and fromgid = @gdgid and flag = 1
			fetch next from c_gft into @gftgid, @gftwrh, @inqty, @gftqty
		end
		close c_gft
		deallocate c_gft
	end

	--增加生成单据表中单据明细记录数
	update alcpoolgenbills
		set dtlcnt = @line
	where billname = '定货单'
		and flag = 0

	-- add by hzl 2003-10-24
	if @qty >0
		update alcpoolhtemp set gennum = @num, gencls = '定货单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and srcgrp = @from
	else
		update alcpoolhtemp set gennum = @num, gencls = '定货单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and qty = 0

	return (0)
end
GO
