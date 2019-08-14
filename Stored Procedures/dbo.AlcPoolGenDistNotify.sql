SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolGenDistNotify](
	@storegid	int,
	@gdgid	int,
	@qty	money,
	@operator	int,
	@from	int -- add by hzl 2003-10-24
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
		@alcqpc money,
		@isltd	int,
		@msg	varchar(255),
		@cases  money

	--限制配货和清场品
	exec GetGoodsOutIsLtd @storegid, @gdgid, @isltd output
	if (@isltd & 1 = 1) or (@isltd & 8 = 8)
	begin
		set @msg = '商品' + str(@gdgid) + '是限制配货或清场商品，不能配货'
		exec AlcPoolWriteLog 1, 'SP:AlcPoolGenDistNotify', @msg
		return 0
	end

	--是否需要开始一张新的单据
	select @num = num, @line = dtlcnt from alcpoolgenbills(nolock)
		where billname = '配货通知单'
		and flag = 0
	if @num is null
	begin
		--抢占单号
		select @usergid = usergid, @zbgid = zbgid from system(nolock)
		select @num = isnull(max(num), '0000000001') from distnotify(nolock)
		exec NEXTBN @num, @num output
		insert into distnotify(num, settleno, diststore, wrh,fildate, filler, stat, reccnt, note)
		values( @num, -1, @storegid, 1,getdate(), @operator, 0, 0, '由配货池生成')

		insert into autoalloclog(storegid, cls, num, oper, atime)
		values(@storegid, '配货通知', @num, @operator, getdate())

		--在生成单据表中记录
		insert into alcpoolgenbills(billname, num, dtlcnt, flag)
		values('配货通知单', @num, 0, 0)
	end

	--计算有关变量
	select @line = isnull(@line, 0) + 1

	select
		@wrh = wrh,
		@taxrate = taxrate,
		@wsprc	= whsprc,
		@inprc	= inprc,
		@rtlprc	= rtlprc,
		@alcqpc = isnull(alcqty,0)
	from goods(nolock)
	where gid = @gdgid
/*	exec GetStoreOutPrc @storegid, @gdgid, @wrh, @price output
            declare @vNewUserGid int
	select @vNewUserGid = USERGID from SYSTEM(nolock)
	select @invqty = isnull(AVLQTY, 0)
	from V_ALCINV(nolock)
	where gdgid = @gdgid and wrh = @wrh and store = @vNewUserGid
	if @invqty is null
		set @invqty = 0
*/

	if @alcqpc = 0
		set @alcqpc = 1
    if @qty < @alcqpc  --箱数取整
        set @cases = 1
    else
        set @cases = round(@qty / @alcqpc, 0)
    set @qty = @alcqpc * @cases

	--插入一条明细
	insert into DistNotifydtl(num, line, settleno, gdgid, cases, shouldqty)
	values(@num, @line, -1, @gdgid, @cases, @qty)

	--增加生成单据表中单据明细记录数
	update alcpoolgenbills
		set dtlcnt = @line
	where billname = '配货通知单'
		and flag = 0

	-- add by hzl 2003-10-24
	if @Qty > 0
		update alcpoolhtemp set gennum = @num, gencls = '配货通知单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and srcgrp = @from
	else
		update alcpoolhtemp set gennum = @num, gencls = '配货通知单', gentime = getdate()
		where storegid = @storegid and gdgid = @gdgid and qty = 0

	return (0)
end
GO
