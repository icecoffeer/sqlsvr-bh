SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolGenWholeSale](
	@storegid	int,
	@gdgid	int,
	@qty	money,
	@from	int,
	@operator	int
)
as
begin
	declare
		@num char(10),
		@settleno smallint,
		@usergid int,
		@line smallint,
		@price money,
		@wrh int,
		@taxrate money,
		@invqty money,
		@wsprc	money,
		@inprc	money,
		@rtlprc	money,
		@zbgid	int,
		@qpc money,
		@isltd	int,
		@msg varchar(255)

	--限制配货和清场品
	exec GetGoodsOutIsLtd @storegid, @gdgid, @isltd output
	if (@isltd & 1 = 1) or (@isltd & 8 = 8)
	begin
		set @msg = '商品' + str(@gdgid) + '是限制配货商品'
		exec AlcPoolWriteLog 1, 'SP:AlcPoolGenWholeSale', @msg
		return 0
	end

	--是否需要开始一张新的单据
	select @num = num, @line = dtlcnt from alcpoolgenbills(nolock)
		where billname = '批发单'
		and flag = 0
	if @num is null
	begin
		--抢占单号
		select @usergid = usergid, @zbgid = zbgid from system(nolock)
		select @num = isnull(max(num), '0000000001') from stkout(nolock) where cls = '批发'
		exec NEXTBN @num, @num output
		insert into stkout(cls, num, settleno,wrh, client, billto, ocrdate,
			total, tax, fildate, filler, stat, reccnt, src, note)
		values('批发', @num, -1, 1, @storegid, @storegid, getdate(),
			0, 0,  getdate(), @operator, 0, 0, @usergid, '由配货池生成')
		insert into autoalloclog(storegid, cls, num, oper, atime)
		values(@storegid, '批发', @num, @operator, getdate())

		--在生成单据表中记录
		insert into alcpoolgenbills(billname, num, dtlcnt, flag)
		values('批发单', @num, 0, 0)
	end

	--计算有关变量
	select @line = isnull(@line, 0) + 1
	if @line = 1 --第一条商品，更改汇总信息
	begin
		select @wrh=wrh from goods(nolock) where gid = @gdgid --by zhouchunze
		update stkout set wrh = @wrh where num = @num and cls = '批发'
	end

	select
		@wrh = wrh,
		@taxrate = taxrate,
		@wsprc	= whsprc,
		@inprc	= inprc,
		@rtlprc	= rtlprc
	from goods(nolock)
	where gid = @gdgid
	exec GetStoreOutPrc @storegid, @gdgid, @wrh, @price output
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
	insert into stkoutdtl(cls, num, line, settleno, gdgid, cases, qty, price,
		wsprc, total, tax, inprc, rtlprc, wrh, invqty)
	values('批发', @num, @line, -1, @gdgid, @qty / @qpc, @qty, @price, @wsprc,
		convert(decimal(20, 2), @qty * @price),
		convert(decimal(20, 2), @qty * @price * @taxrate / (100 + @taxrate)), @inprc,
		@rtlprc, @wrh, @invqty)

	--增加生成单据表中单据明细记录数
	update alcpoolgenbills
		set dtlcnt = @line
	where billname = '批发单'
		and flag = 0

	-- add by hzl 2003-10-24
	if @qty > 0
		update alcpoolhtemp set gennum = @num, gencls = '批发单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and srcgrp = @from
	else
		update alcpoolhtemp set gennum = @num, gencls = '批发单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and qty = 0

	return (0)
end
GO
