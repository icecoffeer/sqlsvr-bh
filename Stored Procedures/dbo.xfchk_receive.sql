SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[xfchk_receive]
	@num char(10),
	@chgwrh smallint,
	@curdate datetime,
	@cursettleno int,
	@batchflag smallint,
	@errmsg varchar(200)='' output
as
begin
	declare
		@ret int,
		@FROMWRH int, @TOWRH int,
		@LINE int, @GDGID int, @VALIDDATE datetime, @QTY money, @AMT money,
		@INPRC money, @RTLPRC money, @INQTY money, @OUTQTY money, @INTOTAL money, @OUTTOTAL money,
		@FROMSUBWRH money, @TOSUBWRH money,
		@INVCOST money, @ININPRC money, @INRTLPRC money,
		@difprc money, @finalprc money,
		@store int, @wrh int,
		@d_cost money /*2002-06-13*/,
                @sale smallint/*2003-06-13*/
	/*
	xf
	c	NUM,
	s	SETTLENO, FILDATE,
	c	FILLER, CHECKER, FROMWRH, TOWRH, AMT,
	s	STAT,
	c	RECCNT, NOTE, AFLAG, PRNTIME,
	s	INVCOST,
	c	OUTEMP, OUTDATE, INEMP, INDATE
	*/
	select	@FROMWRH=FROMWRH,
			@TOWRH=TOWRH
	from XF
	where NUM=@num

	/*
	xfdtl
	c	NUM, LINE, SETTLENO, GDGID, VALIDDATE, QTY, AMT,
	s	INPRC, RTLPRC, INQTY, OUTQTY, INTOTAL, OUTTOTAL,
	c	FROMSUBWRH, TOSUBWRH,
	s	INVCOST, ININPRC, INRTLPRC
	*/
	declare c_xf cursor for
		select	LINE, GDGID, VALIDDATE, QTY, AMT,
				INPRC, RTLPRC, INQTY, OUTQTY, INTOTAL, OUTTOTAL,
				FROMSUBWRH, TOSUBWRH,
				INVCOST, ININPRC, INRTLPRC
		from XFDTL
		where NUM = @num
		for update
	open c_xf
	fetch next from c_xf into
		@LINE, @GDGID, @VALIDDATE, @QTY, @AMT,
		@INPRC, @RTLPRC, @INQTY, @OUTQTY, @INTOTAL, @OUTTOTAL,
		@FROMSUBWRH, @TOSUBWRH,
		@INVCOST, @ININPRC, @INRTLPRC
	while @@fetch_status = 0 begin
		/* 2000-9-14 2000091353807 */
		if (select batchflag from system) = 1
		begin
			select @tosubwrh=@fromsubwrh
			update xfdtl set tosubwrh=@tosubwrh where NUM = @num and LINE = @line
		end

		/* xfdtl */
		/* ININPRC, INRTLPRC */
		select @ininprc=inprc, @inrtlprc=rtlprc , @sale = SALE/*2003-06-13*/
		from goods
		where gid=@gdgid

/*old process ,modify by hxs 2001.08.21,see next
		-- INQTY
		if @tosubwrh is null
		begin

    	-- 2000-11-13 wrh, store conversion for convenient store
      select @store = null
      select @store = GID from STORE where GID = @towrh
      if @store is null select @store = USERGID from SYSTEM
      else select @wrh = 1

			select @outqty=isnull(sum(qty), 0)
			from inv
			where wrh=@wrh and store=@store
		end else
		begin
			select @outqty=isnull(sum(qty), 0)
			from subwrhinv
			where wrh=@towrh and subwrh=@tosubwrh
		end
		-- INTOTAL
		select @intotal=@qty*@inrtlprc

*/
		-- INQTY
		if @tosubwrh is null
		begin

		      select @store = null
		      select @store = GID from STORE where GID = @towrh
		      if @store is null
		      begin
				select @store = USERGID from SYSTEM
				select @wrh = @towrh
		      end
		      else
				select @wrh = 1

			select @inqty=isnull(sum(qty), 0)
			from inv
			where wrh=@wrh and store=@store and gdgid = @gdgid
		end else
		begin
			select @inqty=isnull(sum(qty), 0)
			from subwrhinv
			where wrh=@towrh and subwrh=@tosubwrh and gdgid = @gdgid
		end
		-- INTOTAL
		select @intotal=@inqty*@inrtlprc

--hxs modify in 2001.08.21 end here

		update xfdtl
		set	inqty=@inqty,
			intotal=@intotal,
			ininprc=@ininprc,
			inrtlprc=@inrtlprc
		where NUM = @num and LINE = @line
		/* difprc */
		select @difprc=isnull(sum(ADJINCOST/qty), 0)	/* 2000.9.29 */
		from INPRCADJDTL
		where LACTIME is not null
		and BILL = 'XF' and BILLCLS = '调入'
		and BILLNUM = @num and BILLLINE = @line
		and qty<>0
		/* finalprc */
		select @finalprc=@inprc+@difprc

		--2003-03-11
		execute @ret = UNLOAD -100, @gdgid, @qty, @rtlprc, @validdate
		if @ret <> 0 break
		execute UPDINVPRC '内部调拨出', @gdgid, @qty, 0, -100, @d_cost output
		--2002-06-13 2002.08.18
		--select @d_cost = COST from XFDTL where NUM = @num and LINE = @line

		execute UPDINVPRC '内部调拨进', @gdgid, @qty, @d_cost, @towrh
		/* inv */
		execute @ret = LOADIN @towrh, @gdgid, @qty, @rtlprc, @validdate
    	if @ret <> 0 break

		/* subwrhinv */
		if @batchflag=1 and @tosubwrh is null
		begin
			execute @ret = GetSubWrhBatch @towrh, @tosubwrh output, @errmsg output
			if @ret <> 0 break
		end
    	if @tosubwrh is not null
    	begin
      		execute @ret = LOADINSUBWRH @towrh, @tosubwrh, @gdgid, @qty, @finalprc
      		if @ret <> 0 break
    	end
		/* invxrpt */
		/* invchgxrpt */
        if @sale = 1/*2003-06-13*/
        begin
    	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
      	NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
      	values (@curdate, @cursettleno, @towrh, @gdgid, 1, 1, /*@vdrgid, @cstgid */
      	@qty, @amt, @d_cost/*2002-06-13@qty * @finalprc*/, @qty * @rtlprc)

		/*2003-03-11*/
    	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
      	NDC_Q, NDC_A, NDC_I, NDC_R)
      	values (@curdate, @cursettleno, -100, @gdgid, 1, 1, /*@vdrgid, @cstgid */
      	@qty, @amt, @d_cost/*2002-06-13@qty * @finalprc*/, @qty * @rtlprc)
        end else
        begin
    	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
      	NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
      	values (@curdate, @cursettleno, @towrh, @gdgid, 1, 1, /*@vdrgid, @cstgid */
      	@qty, @amt, @qty * @finalprc, @qty * @rtlprc)

		/*2003-03-11*/
    	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
      	NDC_Q, NDC_A, NDC_I, NDC_R)
      	values (@curdate, @cursettleno, -100, @gdgid, 1, 1, /*@vdrgid, @cstgid */
      	@qty, @amt, @qty * @finalprc, @qty * @rtlprc)
        end


    	/* 更改默认仓位 */
		if @chgwrh = 1
    	begin
      		update goods set wrh = @towrh where gid = @gdgid
      		delete from inv where store = (select usergid from system)
        	and  wrh = @fromwrh and gdgid = @gdgid and qty = 0
    	end
		fetch next from c_xf into
			@LINE, @GDGID, @VALIDDATE, @QTY, @AMT,
			@INPRC, @RTLPRC, @INQTY, @OUTQTY, @INTOTAL, @OUTTOTAL,
			@FROMSUBWRH, @TOSUBWRH,
			@INVCOST, @ININPRC, @INRTLPRC
	end
	deallocate c_xf
	return(@ret)
end
GO
