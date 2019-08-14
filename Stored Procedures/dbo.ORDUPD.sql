SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ORDUPD](
	@new_num char(10),
	@ChkFlag smallint = 0  /*调用标志，1表示WMS调用，缺省为0*/
) with encryption as
begin
	declare
		@return_status int,
		@new_stat int,
		@new_checker int,
		@old_num char(10),
		@new_settleno int,
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
                /* 2000-06-20 */ @old_note varchar(255),
        @old_dlvbdate datetime, /*2002.08.05*/
        @old_dlvedate datetime, /*2002.08.05*/
		@gdgid int,
		@wrh int,
		@qty money,
		@max_num char(10),
		@neg_num char(10),
		@alc char(10)

	select
		@new_settleno = SETTLENO,
		@new_checker = CHECKER,
		@new_stat = STAT,
		@old_num = MODNUM
	from ORD where NUM = @new_num
	if @new_stat <> 0 begin
		raiserror('修改单不是未审核的单据', 16, 1)
		return(1)
	end

	select
		@old_wrh = WRH,
		@old_vendor = VENDOR,
		@old_reccnt = RECCNT,
		@old_src = SRC,
		@old_srcnum = SRCNUM,
		@old_sndtime = SNDTIME,
		@old_receiver = RECEIVER,
		@old_total = TOTAL,
		@old_tax = TAX,
		@old_stat = STAT,
		@old_psr = PSR,
		@old_paydate = PAYDATE,
		@old_prepay = PREPAY,
                @old_alccls = ALCCLS,
                /* 2000-06-20 */@old_note = NOTE,
        @old_dlvbdate = DLVBDATE,
        @old_dlvedate = DLVEDATE
	from ORD where NUM = @old_num

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

	--update ORD set STAT = 1 where NUM = @new_num
	execute ORDCHK @new_num


	if @old_stat <> 1
	begin
		raiserror('被修改的不是已审核的单据', 16, 1)
		return(1)
	end

	if @old_src <> (select usergid from system)
	begin
		raiserror('被修改的不是本单位生成的单据', 16, 1)
		return(1)
	end

	--select @max_num = max(NUM) from ORD
	--execute NEXTBN @max_num, @neg_num output
	execute NEXTBN @new_num, @neg_num output
	while exists (select * from ORD where num = @neg_num)
		execute NEXTBN @neg_num, @neg_num output


	update ORD set STAT = 2 where NUM = @old_num


	/*减少在单量*/
	if @old_receiver = (select usergid from system)	--20010702 CQH
	--//只有本单位生成的定货单才影响在单量
	begin
		declare c_ord cursor for
		select GDGID, WRH, -QTY
		from ORDDTL
		where NUM = @old_num

		open c_ord
		fetch next from c_ord into
			@gdgid, @wrh, @qty
		while @@fetch_status = 0
		begin
			--2006.11.29 added by zhanglong, 供应单位为供应商，或配货方式必须为‘统配’才可影响在单量
			select @alc = alc from goods(nolock) where gid = @gdgid
			if not exists(select 1 from store(nolock) where gid = @old_vendor)
				or (@alc = '统配')
				execute IncOrdQty @wrh, @gdgid, @qty

			fetch next from c_ord into
				@gdgid, @wrh, @qty
		end
		close c_ord
		deallocate c_ord
	end

	/*做一张负单*/
	insert into ORD(NUM, SETTLENO, FILDATE, FILLER, CHECKER,
			WRH, VENDOR, STAT, MODNUM, RECCNT, SRC,
			SRCNUM, SNDTIME, RECEIVER, TOTAL, TAX,
			PSR, PAYDATE, PREPAY, ALCCLS, NOTE, DLVBDATE, DLVEDATE /*2002.08.04*/)
	values (
		@neg_num, @new_settleno, getdate(), @new_checker, @new_checker, @old_wrh,
		@old_vendor, 3, @old_num, @old_reccnt, @old_src, @old_srcnum, @old_sndtime,
		@old_receiver, -@old_total, -@old_tax, @old_psr, @old_paydate, @old_prepay, @old_alccls, --2002-05-22
		/* 2000-06-20 null*/@old_note, @old_dlvbdate, @old_dlvedate/*2002.08.05*/)


	insert into ORDDTL(NUM, LINE, SETTLENO, GDGID, WRH,
		CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, INVQTY, ARVQTY, ASNQTY, /* 2000-06-20 */NOTE, /*2002.09.13*/FROMGID, FLAG)
	select @neg_num, LINE, @new_settleno, GDGID, WRH,
		-CASES, -QTY, PRICE, -TOTAL, -TAX, VALIDDATE, INVQTY, ARVQTY, ASNQTY, NOTE, FROMGID, FLAG
	from ORDDTL
	where NUM = @old_num

	--2003.01.07
	exec OrdUpdAlcPool @old_num

	return(0)
end
GO
