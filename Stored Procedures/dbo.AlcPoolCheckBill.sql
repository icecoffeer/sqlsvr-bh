SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcPoolCheckBill](
	@operator int
)
as
begin
	declare
		@allocoutstat smallint,
		@ordstat smallint,
		@wholesalestat smallint,
		@billname varchar(10),
		@num char(10),
		@alcckinv smallint,
		@wsckinv smallint,
		@invlackpolicy smallint,
		@dtlcnt int,
		@vOp_AutoSndDirAlcOrd int,
		@vOp_AutoChkDirAlcOrd int,
		@vOp_SpecialOrdUsed int,
		@usergid int
	declare @ErrMsg varchar(200)
		,@ret int

	exec AlcPoolWriteLog 0, 'SP:AlcPoolCheckBill', '审核单据'

	exec OptReadInt 500, 'allocoutstat', 0, @allocoutstat output
	exec OptReadInt 500, 'ordstat', 0, @ordstat output
	exec OptReadInt 500, 'wholesalestat', 0, @wholesalestat output
	exec OptReadInt 500, '审核后自动发送直配定单', 0, @vOp_AutoSndDirAlcOrd output
	exec OptReadInt 500, '门店接收直配定单强制审核', 0, @vOp_AutoChkDirAlcOrd output

	exec OptReadInt 90, 'ckinv', 0, @alcckinv output
	exec OptReadInt 65, 'ckinv', 0, @wsckinv output
/*
  exec OptReadInt 0, 'SpecialOrdUsed', 0, @vOp_SpecialOrdUsed output --是否启用分类定单。
  if @vOp_SpecialOrdUsed = 0
  begin
		--exec OptReadInt 114, 'AutoSend', 0, @vOp_AutoSndDirAlcOrd output --普通定单
		exec OptReadInt 114, 'AutoCheck', 0, @vOp_AutoChkDirAlcOrd output
	end
	else
	begin
		--exec OptReadInt 528, 'AutoSend', 0, @vOp_AutoSndDirAlcOrd output --直配定单
		exec OptReadInt 528, 'AutoCheck', 0, @vOp_AutoChkDirAlcOrd output
	end*/
  select @usergid = usergid from system
	declare c_genbills cursor for
	select billname, num from alcpoolgenbills
	where flag in (3) and billname in ('定货单', '配货出货单','配货通知单', '批发单') --FDY flag in (2,3)
	for update
	open c_genbills
	fetch next from c_genbills into @billname, @num
	while @@fetch_status = 0
	begin
		if @billname = '定货单'
		begin
			if @ordstat = 7
			begin
				update ord set stat = 7 where num = @num
			end else if @ordstat = 1
			begin
				exec ordchk @num
				--发送直配（不包括直流）定单
				if @vOp_AutoSndDirAlcOrd = 1 and @usergid <> (select receiver from ord(nolock) where num = @num)
					exec ordsnd @num, @vOp_AutoChkDirAlcOrd, 1
			end
			select @dtlcnt = count(*)
			from orddtl(nolock)
			where num = @num
		end else if @billname = '配货出货单'
		begin
			if @allocoutstat = 7
			begin
				exec stkoutchk @cls = '配货', @num = @num, @VStat = 7
			end else if @allocoutstat = 1
			begin
				exec stkoutchk '配货', @num, @alcckinv, 0, 0, 0, 1, ''  /*2005-05-30*/
			end
			select @dtlcnt = count(*)
			from stkoutdtl(nolock)
			where num = @num and cls = '配货'
		end else if @billname = '批发单'
		begin
			if @wholesalestat = 7
			begin
				update stkout set stat = 7 where num = @num and cls = '批发'
			end else if @wholesalestat = 1
			begin
				exec stkoutchk '批发', @num, @wsckinv, 0, 0, 0, 1, ''  /*2005-05-30*/
			end
			select @dtlcnt = count(*)
			from stkoutdtl(nolock)
			where num = @num and cls = '批发'
		end else if @billname = '配货通知单'
		begin
			exec @ret = DistNotifychk @num, @operator,@allocoutstat, @ErrMsg output
			if @ret <> 0
			begin
				close c_genbills
				deallocate c_genbills
				return @ret
			end
			select @dtlcnt = count(*)
			from DistNotifydtl(nolock)
			where num = @num
		end


		update alcpoolgenbills set flag = 4, dtlcnt = @dtlcnt where current of c_genbills
		fetch next from c_genbills into @billname, @num
	end
	close c_genbills
	deallocate c_genbills

	return (0)
end
GO
