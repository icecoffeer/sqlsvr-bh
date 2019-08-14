SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[xfchk_check]
	@num char(10),
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
		@store int, @wrh int,
		@d_cost money /*2002-06-13*/,
                @sale smallint/*2003-06-13*/,
                @TotalAmt money, --2006.3.17, ShenMin, Q6334, 便利信用额度增加对内部调拨单的处理
		@opt_UseLeaguestore int --2006.3.17, ShenMin, Q6334, 便利信用额度增加对内部调拨单的处理
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
		@TOWRH=TOWRH,
		@TotalAmt = AMT  --2006.3.17, ShenMin, Q6334, 便利信用额度增加对内部调拨单的处理
	from XF
	where NUM=@num

     --2006.3.17, ShenMin, Q6334, 便利信用额度增加对内部调拨单的处理
	exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output
	if @opt_UseLeaguestore = 1
	  begin
	    if exists (select 1 from store where gid = @FROMWRH)
	      exec UPDLEAGUESTOREALCACCOUNTTOTAL @num, @FROMWRH, '内部调拨单', @TotalAmt
	    if exists (select 1 from store where gid = @TOWRH)
	      begin
	        set @TotalAmt = -@TotalAmt
	        exec UPDLEAGUESTOREALCACCOUNTTOTAL @num, @TOWRH, '内部调拨单', @TotalAmt
	      end
	  end
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
		/* xfdtl */
		/* INPRC */
		if @batchflag=1
		begin
			select @inprc=LSTINPRC
			from SUBWRHINV
			where GDGID=@gdgid and SUBWRH=@fromsubwrh
			if @@rowcount=0
			begin
				select	@errmsg='在仓位'+name+'['+code+']' from warehouse where gid=@fromwrh
				select	@errmsg=@errmsg+'中找不到批号为'+convert(char,@fromsubwrh)+
						'的商品'+name+'['+code+']'
				from goods
				where gid=@gdgid
				select @ret=1031
				break
			end
		end else
		begin
			select @inprc=INPRC
			from goods
			where gid=@gdgid
		end
		/* RTLPRC */
		select @rtlprc=RTLPRC, @sale = SALE/*2003-06-13*/
		from goods
		where gid=@gdgid
		/* INQTY */
		select @inqty=0
		/* OUTQTY */
		if @fromsubwrh is null
		begin

    	/* 2000-11-13 wrh, store conversion for convenient store */
/*      select @store = null
      select @store = GID from STORE where GID = @fromwrh
      if @store is null select @store = USERGID from SYSTEM
      else select @wrh = 1

			select @outqty=isnull(sum(qty),0)
			from inv
			where wrh=@wrh and store=@store
			*/
		      select @store = null
		      select @store = GID from STORE where GID = @fromwrh
		      if @store is null
		      begin
				select @store = USERGID from SYSTEM
				select @wrh = @fromwrh
		      end
		      else
			select @wrh = 1

			select @outqty=isnull(sum(qty),0)
			from inv
			where wrh=@wrh and store=@store and gdgid = @gdgid  --modify by hxs 2001.08.21

		end else
		begin
			select @outqty=isnull(sum(qty),0)
			from subwrhinv
			where wrh=@fromwrh and subwrh=@fromsubwrh and gdgid = @gdgid --modify by hxs 2001.08.21

/*old where clause ,modify by hxs 2001.08.21			where wrh=@fromwrh and subwrh=@fromsubwrh*/

		end
		/* INTOTAL */
		select @intotal=0
		/* OUTTOTAL */
		select @outtotal=@outqty*@rtlprc
		/* ININPRC */
		select @ininprc=0
		/* INRTLPRC	*/
		select @inrtlprc=0
		update xfdtl
		set	inprc=@inprc,
			rtlprc=@rtlprc,
			inqty=@inqty,
			outqty=@outqty,
			intotal=@intotal,
			outtotal=@outtotal,
			ininprc=@ininprc,
			inrtlprc=@inrtlprc
		where NUM = @num and LINE = @line

		/* 未提数 */
		execute @ret=incdspqty @fromwrh, @gdgid, @qty, @fromsubwrh

		/* inv */
		execute @ret=unload @fromwrh, @gdgid, @qty, @rtlprc, @validdate
		if @ret <> 0
		begin
			select @errmsg='从仓位'+name+'['+code+']'+'出库'
			from warehouse
			where gid=@fromwrh
			select @errmsg='商品'+name+'['+code+']'+ltrim(rtrim(convert(char,@qty)))+munit+'错误'
			from goods
			where gid=@gdgid
			break
		end
		/* subwrhinv */
		if @fromsubwrh is not null
		begin
			execute @ret=unloadsubwrh @fromwrh, @fromsubwrh, @gdgid, @qty
			if @ret <> 0
			begin
				select @errmsg='从仓位'+name+'['+code+']'
				from warehouse
				where gid=@fromwrh
				select @errmsg=@errmsg+'货位'+name+'['+code+']'+'出库'
				from subwrh
				where gid=@fromsubwrh
				select @errmsg=@errmsg+'商品'+name+'['+code+']'+ltrim(rtrim(convert(char,@qty)))+munit+'错误'
				from goods
				where gid=@gdgid
				break
			end
		end
		if @ret<>0 break

		--2002-06-13 2002.08.18
		execute UPDINVPRC '内部调拨出', @gdgid, @qty, 0, @fromwrh, @d_cost output --2002.08.18
		if @sale = 1
		    update XFDTL set COST = @d_cost
		        where NUM = @num and LINE = @line
		else --2004-08-12
		    update XFDTL set COST = @qty * @inprc
		        where NUM = @num and LINE = @line

		--2003-03-11
		execute UPDINVPRC '内部调拨进', @GDGID, @QTY, @d_cost, -100
		execute @ret=LOADIN -100, @gdgid, @qty, @rtlprc, @validdate  /*2003-03-11*/
		if @ret <> 0 break
		/* invxrpt */
		/* invchgxrpt */
        if @sale = 1/*2003-06-13*/
        begin
      	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDC_Q, NDC_A, NDC_I, NDC_R)
        values (@curdate, @cursettleno, @fromwrh, @gdgid, 1, 1, /*@vdrgid, @cstgid */
        @qty, @amt, @d_cost/*2002-06-13*/, @qty * @rtlprc)

        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,  --2003-03-11
        NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @cursettleno, -100, @gdgid, 1, 1,
        @qty, @amt, @d_cost, @qty * @rtlprc )
        end else
        begin
      	insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDC_Q, NDC_A, NDC_I, NDC_R)
        values (@curdate, @cursettleno, @fromwrh, @gdgid, 1, 1, /*@vdrgid, @cstgid */
        @qty, @amt, @qty * @inprc, @qty * @rtlprc)

        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,  --2003-03-11
        NDJ_Q, NDJ_A, NDJ_I, NDJ_R)
        values (@curdate, @cursettleno, -100, @gdgid, 1, 1,
        @qty, @amt, @qty * @inprc, @qty * @rtlprc )
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
