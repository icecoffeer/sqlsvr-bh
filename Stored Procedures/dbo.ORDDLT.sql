SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ORDDLT](
	@old_num char(10),
	@new_oper int,
	@ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
	declare
		@return_status int,
		@cur_settleno int,
		@old_settleno int,
		@old_wrh int,
		@old_vendor int,
		@old_reccnt int,
		@old_src int,
		@old_srcnum char(10),
		@old_sndtime datetime,
		@old_receiver int,
		@old_total money,
		@old_tax money,
		@old_stat int,
		@old_psr int,
		@old_paydate datetime,
		@old_prepay money,
		@old_alccls char(10),
                /* 2000-06-20 */@old_note varchar(255),
				/* 2002.07.15 */@old_dlvbdate datetime,
				/* 2002.07.15 */@old_dlvedate datetime,
		@max_num char(10),
		@neg_num char(10),
		@wrh int,
		@gdgid int,
		@qty money,
		@alc char(10)

	select
		@old_wrh = WRH,
		@old_vendor = VENDOR,
		@old_reccnt = RECCNT,
		@old_src = SRC,
		@old_srcnum = SRCNUM,
		@old_sndtime = SNDTIME,
		@old_receiver = RECEIVER,
		@old_total = -TOTAL,   --2002-05-22
		@old_tax = -TAX,       --2002-05-22
		@old_stat = STAT,
		@old_psr = PSR,
		@old_paydate = PAYDATE,
		@old_prepay = PREPAY,
                @old_alccls = ALCCLS,
                /* 2002.07.15 */@old_dlvbdate = DLVBDATE,
                /* 2002.07.15 */@old_dlvedate = DLVEDATE,
                /* 2000-06-20 */@old_note = NOTE
	from ORD where NUM = @old_num
	if @@ROWCOUNT <> 1
	begin
		raiserror('被删除的单据不存在', 16, 1)
		return(1)
	end
	if @old_stat <> 1
	begin
		raiserror('被删除的不是已审核的单据', 16, 1)
		return(1)
	end
	--if @old_src <> (select usergid from system)
	--begin
		--  raiserror('被删除的不是本单位生成的单据', 16, 1)
		--  return(1)
	--end

  --ShenMin
  declare
    @Oper char(30),
    @poMsg varchar(255)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSFILTER 'ORD', '', @old_num, 2, @Oper,@old_wrh, 0, null, @poMsg output
  if @return_status <> 0
    begin
    	raiserror(@poMsg, 16, 1)
    	return(1)
    end

	select
		@cur_settleno = max(NO) from MONTHSETTLE
	--select @max_num = max(NUM) from ORD
	--execute NEXTBN @max_num, @neg_num output

	execute NEXTBN @old_num, @neg_num output
	while exists (select * from ORD where num = @neg_num)
		execute NEXTBN @neg_num, @neg_num output

	update ORD set STAT = 2 where NUM = @old_num
	--2003.01.07
	exec OrdUpdAlcPool @old_num

	insert into ORD(NUM, SETTLENO, FILDATE, FILLER, CHECKER,
		WRH, VENDOR, STAT, MODNUM, RECCNT, SRC, SRCNUM,
		SNDTIME, RECEIVER, TOTAL, TAX,
		PSR, PAYDATE, PREPAY, ALCCLS, NOTE, /* 2002.07.15 */ DLVBDATE, DLVEDATE)
	values (
		@neg_num, @cur_settleno, getdate(), @new_oper, @new_oper,@old_wrh,
		@old_vendor, 4, @old_num, @old_reccnt, @old_src, @old_srcnum, null,
		@old_receiver, @old_total, @old_tax,
		@old_psr, @old_paydate, @old_prepay, @old_alccls, /* 2000-06-20 null*/@old_note, /* 2002.07.15 */ @old_dlvbdate, @old_dlvedate)

	insert into ORDDTL(NUM, LINE, SETTLENO, GDGID, WRH,
		CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, INVQTY, ARVQTY, ASNQTY, NOTE, /*2002.09.13*/FROMGID, FLAG)
	select @neg_num, LINE, @cur_settleno, GDGID, WRH,
		-CASES, -QTY, PRICE, -TOTAL, -TAX, VALIDDATE, INVQTY, ARVQTY, ASNQTY, NOTE, /*2002.09.13*/FROMGID, FLAG
	from ORDDTL
	where NUM = @old_num

	if /* @old_src */ @old_receiver = (select usergid from system)	--20010702 CQH
	--//只有本单位生成的定货单才影响在单量
	begin
		declare c_ord cursor for
		  select GDGID, WRH, -QTY from ORDDTL where NUM = @old_num
		open c_ord
		fetch next from c_ord into @gdgid, @wrh, @qty
		while @@fetch_status = 0
		begin
			/* 在单量 */
			select @alc = alc from goods(nolock) where gid = @gdgid
			--2006.11.29 added by zhanglong, 供应单位若为供应商，或者商品配货方式为‘统配’影响在单量
			if not exists(select 1 from store(nolock) where gid = @old_vendor)
				or (@alc = '统配')
				execute IncOrdQty @wrh, @gdgid, @qty

			fetch next from c_ord into @gdgid, @wrh, @qty
		end
		close c_ord
		deallocate c_ord
	end
	return(0)
end
GO
