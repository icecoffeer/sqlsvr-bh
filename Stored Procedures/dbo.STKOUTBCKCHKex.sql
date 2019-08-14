SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKCHKex](
  @cls char(10),
  @num char(10),
  @VStat smallint = 1,   /* add By jinlei 2005.5.18*/
  @errmsg varchar(200) = '' output,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
) with encryption as
begin
  declare
    @return_status int,       @cur_date datetime,       @cur_settleno int,
    @client int,              @billto int,              @wrh int,
    @stat smallint,           @slr int,                 @gdgid int,
    @qty money,               @total money,             @tax money,
    @inprc money,             @rtlprc money,            @whsprc money,
    @validdate datetime,      @vdr int,                 @line smallint,
    @money1 money,            @subwrh int,              @price money,
    @lstinprc money,          @t_qty money,             @mod_qty money,
    @modnum char(10),         @sale smallint,           @payrate money,
    @curtime datetime,        @gdinprc money,           @store int,
    @ret_status int,  /*2001-06-04*/
    @gencls char(10),         @genbill char(10),        @gennum char(12),
    @itemno smallint,         @saleqty money,           @bckqty money,  /*2001-09-18*/
    /*零售退货         2001-11-26*/
    @CardGid int,/*卡号*/    @CstGid int,/*客户Gid*/   @CstFavamt money,/*客户优惠金额*/
    @favprc money,/*优惠价格*/
    @paymode char(10),       @d_qty money,             @d_total money,/*2002-01-04*/
    @isbianli bit,/*2002-02-04*/@d_cost money/*2002-06-13*/,@OptionValue_RCPCST CHAR(1),
    @cardcode varchar(13) /*2002.08.12*/, @qpcgid int /*大包装商品gid*/,
    @qpcqty money, @t_num char(10),                    @OptionValue1 int,/*2003.07.23*/
    @vDXGDUseSrcCostPrc int,              @gdcode varchar(13), @optvalue_Chk int,
    @preordqty money, @opt_TopClientPrice int

  declare @opt_UseLeagueStore int
  declare @opt_MAndDWrh int
  declare @OptBckDmdRepImp int, @BckdmdQty money, @BckedQty money, @BackQty money, @BckLine int, @OverDmdQtyCount int; --ShenMin
  exec optreadint 0, 'useleaguestore', 0, @opt_useLeagueStore output
  exec Optreadint 0, 'SynMasterAndDetailWrh', 0, @opt_MAndDWrh output

  exec OPTREADINT 69, 'ChkStatDwFunds', 0, @optvalue_Chk output /*add by jinlei 3692*/
  exec OptReadInt 69, 'TopClientPrice', 0, @opt_TopClientPrice output
  exec optreadint 0, 'BckDmdRepImp', 0, @OptBckDmdRepImp output; --ShenMin

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTBCKCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 1, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg output
  if @return_status <> 0 return -1

  declare @option_ISZBPAY int
  exec OptReadInt 0, 'ISZBPAY', 0, @option_ISZBPAY output

  --取得当前用户
  declare @fillerxcode varchar(20), @fillerx int, @fillerxname varchar(50),
          @bckdmdnum varchar(14), @ret int, @outmsg varchar(255), @bckdmdstat int
  set @fillerxcode = rtrim(substring(suser_sname(), charindex('_', suser_sname()) + 1, 20))
  select @fillerx = gid, @fillerxname = name from employee(nolock)
    where code like @fillerxcode
  if @fillerxname is null
  begin
    set @fillerxcode = '-'
    set @fillerxname = '未知'
  end
  set @fillerxcode = convert(varchar(30),'['+rtrim(isnull(@fillerxcode,''))+']' +
    rtrim(isnull(@fillerxname,'')))
  -------
  select @return_status = 0
  select @CstFavamt = 0  select @favprc = 0
  select
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @client = CLIENT,
    @wrh = WRH,
    @stat = STAT,
    @slr = SLR,
    @billto = BILLTO,
    @modnum = MODNUM,
    @gencls=GENCLS,
    @genbill=GENBILL,
    @gennum=GENNUM,
    @paymode = PAYMODE /*2002-01-04*/
    from STKOUTBCK where CLS = @cls and NUM = @num

  --bckdmd----------------------------------2005.03.17-----------
  --检查回写配货退货申请单
  if @return_status = 0 and @cls = '配货'
  begin
    select @bckdmdnum = num from bckdmd (nolock)
        where locknum = @num and lockcls = '配出退' and stat = 400

    if @bckdmdnum is not null and rtrim(@bckdmdnum) <> ''
    begin
      select @bckdmdstat = stat from bckdmd where num = @bckdmdnum
      if (@bckdmdstat <> 400) and exists (select 1 from system(nolock) where zbgid = usergid) --edited by jinlei 总部才检查退货申请单状态，门店不必检查
      begin
          set @poMsg = '来源退货申请单已经终止不能继续审核。'
    	    return 1
      end
    	if exists(select 1 from stkoutbckdtl where num = @num and cls= @cls
    	  group by gdgid having count(1)>1 )
    	begin
          set @poMsg = '单据中有重复商品，不能回写退货申请单'
    	    return 1
    	end
      if @OptBckDmdRepImp = 0  --ShenMin
        begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
           --增加对门店发送上来的单据的审核的回写，这时是没有记录VDRBCKDMD.LOCKNUM
          	select @bckdmdnum = gennum
          	    from stkinbck where num = @num and cls = @cls --and datalength(gennum) = 14
          	    and gencls = '配货退货申请单'
          	update bckdmd set
          	    locknum = @num, lockcls = '配进退' where num = @bckdmdnum
          end
          exec @ret = bckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
          if @ret = 0
          update bckdmddtl set bckedqty = bck.qty
              from stkinbckdtl bck(nolock)
              where bck.num = @num and bck.cls = @cls and bckdmddtl.num = @bckdmdnum
          and bck.gdgid = bckdmddtl.gdgid
        end;
      else if @OptBckDmdRepImp = 1
      	begin
          if @bckdmdnum is null or rtrim(@bckdmdnum) = ''
          begin
            	select @bckdmdnum = gennum
            	    from stkOutbck where num = @num and cls = @cls --and datalength(gennum) = 14
            	    and gencls = '配货退货申请单'
          end;
        	set @BckdmdQty = 0;
        	set @BckedQty = 0;
          set @BckLine = 0;
          set @BackQty = 0;
          select @BckdmdQty = dmd.Qty, @BckedQty = dmd.BckedQty, @BckLine = bck.Line, @BackQty = bck.qty
          from bckdmddtl dmd(nolock), stkOutbckdtl bck(nolock)
          where bck.num = @num and bck.cls = @cls
            and dmd.gdgid = bck.gdgid
            and dmd.num = @bckdmdnum
            and bck.qty + dmd.bckedqty > dmd.qty;

          if @BckLine <> 0
            begin
              if @BckdmdQty < @BckedQty + @BackQty
                begin
                  set @outmsg = '单据中第' + CAST(@BckLine AS varchar(8)) + '行的退货数量'
                              + CAST(@BackQty AS varchar(8)) + ' 超过了来源配货退货申请单中的可退数量'
                              + CAST(@BckdmdQty - @BckedQty  AS varchar(8)) + '，不允许审核！';
                  set @ret = 2;
                end;
            end;
          if @ret = 0
            begin
              update bckdmddtl set bckedqty = bckedqty + bck.qty
      	    	 from stkOutbckdtl bck(nolock)
      	    	 where bck.num = @num and bck.cls = @cls
      	    	   and bckdmddtl.num = @bckdmdnum
      	    	   and bck.gdgid = bckdmddtl.gdgid
              update bckdmd
              set locknum = null, lockcls = null where num = @bckdmdnum
              select @OverDmdQtyCount = 0
              select @OverDmdQtyCount = count(1) from bckdmddtl(nolock)
              where num = @bckdmdnum and bckedqty < qty
              if @OverDmdQtyCount = 0
                exec @return_status = bckdmdchk @bckdmdnum, @fillerxcode, '', 300, @outmsg output
              if @return_status<>0
                begin
                  set @outmsg = '更改退货申请单' + @bckdmdnum + '状态失败！';
                  set @ret = 2;
                end
            end;
      	end;
    end;
    set @return_status = @ret
  end
  --bckdmd----------------------------------2005.03.17-----------

  /*2002-02-04*/
  select @isbianli = 0
  if exists (select 1 from warehouse(nolock) where gid = @client)
	select @isbianli = 1

  /* 99-12-29 */
  if @stat not in (0,7) and @VStat = 1 begin
    set @poMsg = '审核的不是未审核的单据'
    return(1)
  end
  if @VStat = 6 begin
    set @poMsg = '本过程不能复核'
    return(1)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE

  update STKOUTBCK set STAT = 1, FILDATE = GETDATE(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num

  select @OptionValue1 = OptionValue from HDOption
    where  moduleNo = 403  and OptionCaption = 'SaleBckCostPrc'  /*2003.07.23*/
  exec optreadint 69, '代销商品成本价取值方式', 0, @vDXGDUseSrcCostPrc output /*2004.11.10 1259 批发退货是否代销商品成本调整*/

  /* 启用限制单据的汇总仓位和明细仓位一致 */
  if @cls = '配货' and @opt_MAndDWrh = 1
  begin
    update STKOUTBCKDTL set wrh = @wrh, note = ltrim(rtrim(note)) + ' 原仓位(' + ltrim(rtrim(str(wrh))) + ')'
    where CLS = @cls and NUM = @num and wrh <> @wrh
  end

  declare c_stkout cursor for
    select GDGID, QTY, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, LINE, SUBWRH, PRICE, ITEMNO
    from STKOUTBCKDTL where CLS = @cls and NUM = @num
    for update
  open c_stkout
  fetch next from c_stkout into
    @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @itemno
  while @@fetch_status = 0 begin
    /*
    -------------退货报废处理------------------
    if ( select USERPROPERTY from SYSTEM ) >= 24 begin
      -- 配货中心或总部
      select @wrh = 2
      update STKOUTBCKDTL set WRH = 2
      where CLS = @cls and NUM = @num and LINE = @line
    end
    --------------------------------------------
    */

    -- Added by zhourong, 2006.04.28
    -- Q6617
    DECLARE @fromNum VARCHAR(10)
    DECLARE @enabledWhsLinkBcp int
    EXEC OptReadInt 0, 'Whs_Link_Bcp', 0, @enabledWhsLinkBcp OUTPUT
    IF @cls = '批发' and @enabledWhsLinkBcp = 1
    BEGIN
      SELECT @fromNum = FromNum
      FROM StkOutBck
      WHERE Num = @num AND Cls = '批发'

      UPDATE StkOutDtl
      SET BckQty = BckQty + @qty
      WHERE GDGid = @gdgid AND Cls = '批发' AND Num = @fromNum
    END


  --2006.4.18, Edited by ShenMin, Q6541, 增加选项来控制是否对配出退进行限制退货控制
    declare @boolUseLtdBack int
    EXEC OPTREADINT 92, 'UseLtdBack', 1, @boolUseLtdBack OUTPUT  --Q6727

    if @cls = '配货' and (@boolUseLtdBack <> 0)
    begin
       if exists (select 1 from gdstore where gdstore.storegid = @client and gdstore.gdgid = @gdgid and ( (gdstore.isltd & 16)=16 ) )
       begin
          select @gdcode = code from goods where gid = @gdgid
          set @poMsg = '商品[' + @gdcode + ']已经被限制退货!'
	  return (-1)
       end
    end

    --退货价不得高于客户的出货单价限制 Addedby wangxin 2006.04.06
    if @cls = '批发' and @opt_TopClientPrice = 1
    begin
      declare
        @outprc varchar(100),
        @gdOutPrc money,
        @execSql nvarchar(1000),
        @params nvarchar(1000)
      select @outprc = OUTPRC from CLIENT(NOLOCK) where GID = @client
      set @execsql = 'select @GdOutprc = ' + @outprc + ' from GOODS(nolock) where GID = @gdgid'
      set @params = N'@GdOutPrc money output, @gdgid int '
      exec sp_executesql @execsql, @params, @gdOutPrc output, @gdgid
      if @price > @gdOutPrc
      begin
        set @poMsg = '单据第' + convert(varchar(3), @line) + '行的退货价大于客户的出货价'
          + convert(varchar(10), @gdOutPrc) + '，不允许批发退货!'
        return(2)
      end
    end

    if @cls = '零售'
    begin
		if @genbill = 'buy1'
		begin
	      	select @saleqty = qty from buy2(nolock)
    	    	  where posno=@gencls and flowno=@gennum and itemno=@itemno and gid=@gdgid
      		if @saleqty is null
      		begin
        	  	  set @poMsg = '退货商品不在指定的零售单上！'
        	  	  return 2
        	  	end

	      	if @modnum is not null
  	    		select @bckqty = isnull(sum(d.qty),0)
    	      	from stkoutbckdtl d,stkoutbck m
      	    	where d.cls=m.cls and d.num=m.num and d.cls='零售' and m.gencls=@gencls
        	    	and m.genbill='buy1' and m.gennum=@gennum and d.itemno=@itemno
          	    	and m.stat=1 and m.num<>@modnum and m.num<>@num
      		else
      			select @bckqty = isnull(sum(d.qty),0)
        	  	from stkoutbckdtl d,stkoutbck m
          		where d.cls=m.cls and d.num=m.num and d.cls='零售' and m.gencls=@gencls
            		and m.genbill='buy1' and m.gennum=@gennum and d.itemno=@itemno
              		and m.stat=1 and m.num<>@num

	  	    if @qty > (@saleqty - @bckqty)
	  	    begin
	  	        set @poMsg = '退货数量超过可退货上限！'
	  	        return 2
	  	    end
	  	    if exists(select 1 from PREORDPOOLDTL where POSNO = @gencls and FLOWNO = @genNum
	  	      and gdgid = @gdgid)
	  	    begin
	  	      select @preordqty = PREORDQTY from PREORDPOOLDTL(NOLOCK) where POSNO = @genCls and FLOWNO = @gennum
	  	        and GDGID = @gdgid
	  	      if @qty >= @preordqty
	  	      begin
	  	        delete from PREORDPOOLDTL where POSNO = @genCls and FLOWNO = @genNum and GDGID = @gdgid
	  	        if not exists(select 1 from PREORDPOOLDTL where POSNO = @genCls and FLOWNO = @genNum)
	  	          delete from PREORDPOOL where POSNO = @gencls and FLOWNO = @genNum
	  	      end
	  	      else
	  	        update PREORDPOOLDTL set RTLBACKQTY = RTLBACKQTY + @qty, PREORDQTY = PREORDQTY - @qty
	  	          where POSNO = @genCls and FLOWNO = @genNum and gdgid = @gdgid
            end
	  	end else if @genbill = 'cutbuy1'  /*2002.08.12*/
	  	begin
	      	select @saleqty = iqty from cutbuy2(nolock)
    	    	  where num=@gennum and line=@itemno and gdgid=@gdgid
      		if @saleqty is null
      		begin
        	  	  set @poMsg = '退货商品不在指定的裁剪销售单上！'
        	  	  return 2
        	  	end

            /*在客户端执行 2002.09.05 by zyb*/
			/*if exists(select d.* from buygddsp m, buygddspdtl d
				where m.num = d.num
					and m.buynum = @gennum
					and m.stat <> 0
					and d.iscut <> 0
					and d.pkggid = @qpcgid
					--and d.line = @itemno
			)
				raiserror('存在已提货的裁剪商品!', 16, 1)*/

	      	if @modnum is not null
  	    		select @bckqty = isnull(sum(d.qpcqty),0)
    	      	from stkoutbckdtl d,stkoutbck m
      	    	where d.cls=m.cls and d.num=m.num and d.cls='零售'
        	    	and m.genbill='cutbuy1' and m.gennum=@gennum and d.itemno=@itemno
          	    	and m.stat=1 and m.num<>@modnum and m.num<>@num
      		else
      			select @bckqty = isnull(sum(d.qpcqty),0)
        	  	from stkoutbckdtl d,stkoutbck m
          		where d.cls=m.cls and d.num=m.num and d.cls='零售'
            		and m.genbill='cutbuy1' and m.gennum=@gennum and d.itemno=@itemno
              		and m.stat=1 and m.num<>@num

	  	    if @qpcqty > (@saleqty - @bckqty)
	  	    begin
	  	        set @poMsg = '退货数量超过可退货上限！'
	  	        return 2
	  	    end
	  	end;
    end

/*零售退货  2001-11-26*/
    if @cls = '零售'
    begin
    	if @genbill = 'buy1'
    	begin
    		select @Cardgid = Guest from buy1(nolock)
    		where posno = @gencls and flowno = @gennum                /* 取卡号*/
			if @Cardgid is not null
			begin
				select @favprc = isnull((price - Realamt/qty),0) from buy2(nolock)
          			where posno=@gencls and flowno=@gennum and itemno=@itemno and gid=@gdgid
    			select @CstFavamt = @favprc * @qty                   /*算优惠金额*/
				select @CstGid = cst.Gid from Client cst(nolock), Card c(nolock) where cst.Gid = c.cstGid and c.gid = @CardGid
				if @cstGid is not null                               /*更新client的total, favamt, tlcnt,tlgd字段*/
					update Client set Total = Total - @total, Favamt = Favamt - @CstFavamt,
				    	Tlgd = Tlgd - @qty where gid = @cstGid
			end
		end else if @genbill = 'cutbuy1' /*2002.08.12*/
		begin
			-- 回写buygddspdtl
			select @t_num = m.num from buygddsp m, buygddspdtl d
			where m.num = d.num
				and m.buynum = @gennum
				and d.pkggid = @qpcgid
				and ((d.iscut = 0) or (m.stat = 0))
			if @t_num is not null
			begin
				update buygddspdtl set bckqty = isnull(bckqty, 0) + @qpcqty
				where num = @t_num and pkggid = @qpcgid
			end
/*				update buygddspdtl set bckqty = isnull(bckqty, 0) + @qty
				where pkggid = @qpcgid
					--and line = @itemno
					and num in (
						select num from buygddsp
						where buynum = @gennum
					)*/

			--回写cutbuy2
			update cutbuy2 set bckiqty = isnull(bckiqty, 0) + @qpcqty
			where num = @gennum and line = @itemno and pkggid = @qpcgid
		end
    end

    /*2004-08-12 为在执行updivprc前得到当前inprc，把这几段脚本提前*/
    select @inprc = INPRC, @rtlprc = RTLPRC, @whsprc = WHSPRC, @vdr = BILLTO, @gdcode = code,
      /* 2000-05-13 */
      @sale = SALE, @payrate = PAYRATE,
      /* 2000-07-12 */
      @lstinprc = LSTINPRC
      from GOODSH where GID = @gdgid

/*2001-06-04*/
    if (@cls = '批发') and @sale = 2 /*2001-09-18*/
    begin
        select @curtime = getdate()
        select @store = usergid from system
        --2004.11.10 1259
        if (@vDXGDUseSrcCostPrc = 1) and (@gencls = '批发')
        begin
            select @inprc = inprc from stkoutdtl(nolock)
                where num = @gennum and cls = @gencls and line = @itemno and gdgid = @gdgid
            if @@rowcount <> 1
            begin
                set @errmsg = '没有找到对应的来源批发单[' + @gennum + ']的商品[' + @gdcode + ']'
                close c_stkout
                deallocate c_stkout
                set @return_status = 1
                set @poMsg = @errmsg
                return 2
                --raiserror(@errmsg, 16, 1)
            end
        end else
        begin
          execute @ret_status=GetGoodsPrmInprc @store, @gdgid, @curtime, @qty, @inprc output
          if @ret_status <> 0
              select @inprc = INPRC from GOODSH where GID = @gdgid
        end
    end

    if (@cls = '零售'/*2001-09-18*/) and @sale = 2
    begin
        select @curtime = getdate()
        select @store = usergid from system
        execute @ret_status=GetGoodsPrmInprc @store, @gdgid, @curtime, @qty, @inprc output
        if @ret_status <> 0
            select @inprc = INPRC from GOODSH where GID = @gdgid
    end

    /* 2000-05-13 */--edited by jinlei 对于联销商品从批发单导入的取批发单上的INPRC
    if (@cls = '批发') and (@sale = 3) and (@gencls = '批发')
    begin
      select @inprc = inprc from stkoutdtl(nolock)
      where num = @gennum and cls = @gencls and line = @itemno and gdgid = @gdgid
      if @@rowcount <> 1
      begin
        set @errmsg = '没有找到对应的来源批发单[' + @gennum + ']的商品[' + @gdcode + ']'
        close c_stkout
        deallocate c_stkout
        set @return_status = 1
        --raiserror(@errmsg, 16, 1)
        set @poMsg = @errmsg
        return 2
      end
    end else if @sale = 3 select @inprc = @total / @qty * @payrate / 100

    if @cls = '零售' and @sale <> 1 and @OptionValue1 = 1/*2003.07.23*/
         select @inprc = inprc from buy2 where posno=@gencls and flowno=@gennum and itemno=@itemno and gid=@gdgid

    update STKOUTBCKDTL set INPRC = @inprc, RTLPRC = @rtlprc, WSPRC = @whsprc
      where CLS = @cls and NUM = @num and LINE = @line
    /*2004-08-12*/

    if @cls = '批发' or @cls = '零售' --2002-06-13
    begin
      select @money1 = @qty * @inprc
      execute UPDINVPRC '销售退货', @gdgid, @qty, @money1, @wrh, @d_cost output --2002-06-13 2002.08.18
      if @sale = 1
        update STKOUTBCKDTL set COST = @d_cost
            where CLS = @cls and NUM = @num and LINE = @line  --2002-06-13
      else
        update STKOUTBCKDTL set COST = @money1 --2004-08-12
            where CLS = @cls and NUM = @num and LINE = @line
    end
    --2002-06-13
    if @cls = '配货'
    begin
      select @d_cost = @qty * @price
      execute UPDINVPRC '进货', @gdgid, @qty, @d_cost, @wrh /*2002.08.18*/
      if @sale = 1
        update STKOUTBCKDTL set COST = @d_cost
            where CLS = @cls and NUM = @num and LINE = @line
      else
        update STKOUTBCKDTL set COST = @qty * @inprc --2004-08-12
            where CLS = @cls and NUM = @num and LINE = @line
    end

    execute @return_status = LOADIN @wrh, @gdgid, @qty, @rtlprc, @validdate
    if @return_status <> 0 break

/* 2002-02-04 杨善平 */
    if @cls = '配货' and  exists (select 1 from warehouse where gid = @client)
      begin
        execute @return_status = UNLOAD @client, @gdgid, @qty, @rtlprc, @validdate
        if @return_status <> 0 break
      end
/******************/

    /* 2000-3-15 增加了system.batchflag=1时的处理,
    ref 用货位实现批次管理(二).doc */
    select @t_qty = @qty
    if (select batchflag from system) = 1
    begin
      /* 2000-07-12 */
      if @sale = 3 select @inprc = @total / @qty * @payrate / 100
      else select @inprc = @lstinprc

      if @subwrh is null
      begin
        if @t_qty >= 0
        begin
          execute @return_status = GetSubWrhBatch @wrh, @subwrh output, @errmsg output
          if @return_status <> 0 break
          update /* 2000-07-12 STKINBCKDTL */ STKOUTBCKDTL
            set SUBWRH = @subwrh, /* 2000-07-12 */INPRC = @inprc
            where CLS = @cls and NUM = @num and LINE = @line
        end
        else /* @t_qty < 0 */
        begin
          select @errmsg = '负数出货退货必须指定货位'
          select @return_status = 1014
          break
        end
      end
      else /* @subwrh is not null */
      begin
        if @t_qty < 0
        begin
          select @mod_qty = null
          select @mod_qty = qty from stkinbckdtl
            where cls = @cls and num = @modnum and subwrh = @subwrh
          if @mod_qty is null
          begin
            select @errmsg = '找不到对应的出货退货单'
            select @return_status = 1015
            set @poMsg = @errmsg
            return 2
            --raiserror(@errmsg, 16, 1)
            break
          end
          if @mod_qty <> @t_qty
          begin
            select @errmsg = '数量和对应的出货退货单('+@modnum+')上的不符合'
            select @return_status = 1016
            set @poMsg = @errmsg
            return 2
            --raiserror(@errmsg, 16, 1)
            --break
          end
        end
      end
    end

    /* 99-11-10: 不考虑SYSTEM.DSP */
    if @subwrh is not null /* and (select DSP from SYSTEM) = 0 */
    begin
      /* 2000-1-4 李希明：货位中的最近进价
         2000-2-28 李希明：根据系统标志做去税处理 */
      /* 2000-07-12
      if (select INPRCTAX from SYSTEM) = 1
        select @i_price = @price
      else
        select @i_price = @price/(1.0+TAXRATE/100.0) from GOODS where GID = @gdgid
      execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @qty, @i_price, @inprc
      */
      execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @qty, @inprc

      if @return_status <> 0 break
    end

    if @sale = 1/*2003-06-13*/
    execute @return_status = STKOUTBCKDTLCHKCRT
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @billto, @slr, @wrh,
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr, @VStat, @optvalue_chk, @d_cost /*2002-06-13*/
    else
    execute @return_status = STKOUTBCKDTLCHKCRT
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @billto, @slr, @wrh,
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr, @VStat, @optvalue_chk, null
    if @return_status <> 0 break

    if @CLS = '零售' and @genbill = 'buy1'
	  begin
	  	declare @favamt_24 money, @FAVTYPE_24 varchar(4)
      select @favamt_24 = sum(FAVAMT), @FAVTYPE_24 = max(FAVTYPE) from BUY21(nolock)
      where POSNO = @gencls and FLOWNO = @gennum
        and ITEMNO = @itemno and FAVTYPE like '24%'
      if @favamt_24 is not null and @favamt_24 <> 0
      begin
      	declare @_usergid int, @_zbgid int, @qty_24 money
      	select @qty_24 = qty from BUY2(nolock)
        where POSNO = @gencls and FLOWNO = @gennum
          and ITEMNO = @itemno
        set @favamt_24 = @favamt_24 * @qty / @qty_24
      	select @_usergid = usergid, @_zbgid = zbgid from system(nolock)

      	if @option_ISZBPAY = 0
        begin
          --供应商
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@wrh, @gdgid, @vdr, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 1, - @favamt_24, 1, @client)
          --总部
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@wrh, @gdgid, @_zbgid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, - @favamt_24, 0, @client)
          --门店
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@wrh, @gdgid, @_usergid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, - @favamt_24, 0, @client)
        end if @option_ISZBPAY = 1
        begin
          --总部
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@wrh, @gdgid, @_zbgid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, - @favamt_24, 0, @client)
        end
        if @@error <> 0 break
      end
	  end

    /*代销商品若进行促销进价促销，生成调价差异 2001-06-04*/
    if (@cls = '批发' or @cls = '零售'/*2001-09-18*/) /*and @sale = 2 2003.07.23*/and @sale <> 1
    begin
      select @gdinprc = inprc from goodsh where gid = @gdgid
      if @inprc <> @gdinprc
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)
        values (@cur_settleno, @cur_date, @gdgid, @wrh,
        (@gdinprc-@inprc) * @qty)
    end

    select @d_qty = -@qty, @d_total = -@total  /*2002-01-04*/
    if @paymode <> '应收款' and ((@CLS = '批发' and @VStat = 6 and @optvalue_Chk = 1) or (@CLS = '批发' and @VStat = 1 and @optvalue_chk = 0) or (@CLS <> '批发')) begin
      execute @return_status = RCPDTLCHK
        @cur_date, @cur_settleno, @client, @gdgid, @wrh, @d_qty,
        @d_total, @inprc, @rtlprc
    end

    fetch next from c_stkout into
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @itemno
  end
  close c_stkout
  deallocate c_stkout

/*更新client的tlcnt字段  零售退货 2001-11-26*/
  if @cls = '零售' and @Cstgid is not null
  begin
  	if @genbill = 'buy1'
  		select @saleqty = sum(qty) from buy2(nolock) where posno=@gencls and flowno=@gennum
  	else if @genbill = 'cutbuy1'	/*2002.08.12*/
  		select @saleqty = sum(iqty) from cutbuy2(nolock) where num = @gennum
  	select @bckqty = sum(qty) from stkoutbckdtl(nolock) where num = @num and cls = '零售'
  	if @saleqty = @qty 	  /* 更新client中的tlcnt字段*/
  		update Client set Tlcnt = Tlcnt - 1 where gid = @cstGid
  end

  if @paymode <> '应收款' and ((@CLS = '批发' and @VStat = 6 and @optvalue_Chk = 1) or (@CLS = '批发' and @VStat = 1 and @optvalue_chk = 0) or (@CLS <> '批发')) begin            /*此时，这张批发退货单的结算状态应该是已结清 2002-01-04*/
      if @cls = '批发' and (select finished from stkoutbck where num = @num and cls = @cls )<>1 begin
         update stkoutbck
         set finished = 1 where num = @num and cls = @cls

        update stkoutbckdtl
        set rcpqty = qty,rcpamt = total
        where num = @num and cls = @cls
     end
  end
  if not(@cls = '批发' and @VStat = 1 and @optvalue_Chk = 1) begin
    -- sz add
    EXEC @return_status = STKOUTBCKBEFORECHK @num, @cls, @errmsg output
    if @return_status <> 0
    begin
      --raiserror(@errmsg, 16, 1)
      set @poMsg = @errmsg
      return(3)
    end
  end
  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    set @poMsg = '处理单据时发生错误.'
    return (@return_status)
  end
  /*add by cyb 2002.07.31*/
  if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0)))
  begin
	  select @OptionValue_RCPCST = OptionValue from HDOption where  moduleNo = 0  and OptionCaption = 'RCPCST'
	  if @OptionValue_RCPCST is null
	     select @OptionValue_RCPCST = '0'
	  if @OptionValue_RCPCST = '1'
	  begin
		insert into CSTBILL (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)
			SELECT SETTLENO,FILDATE,'批发退',BILLTO,NUM,TOTAL,0,TOTAL
			    FROM STKOUTBCK
                            WHERE NUM = @num
				AND CLS = @CLS
				AND TOTAL <>0
				and paymode =  '应收款'
				and billto not in (select gid from store)

	  end
  end

  --2005.7.14, Added by ShenMin, Q4331, 配货出货退货单审核前判断信用额度
  declare
    @account1 money, @account2 money, @account3 money,
    @UseStoreAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能

  if @opt_UseLeaguestore = 1 and @cls = '配货'
  begin
    select @account1 = total from stkoutbck (nolock) where num = @num and cls = @cls

  --2005.7.14, Added by ShenMin, Q4331, 配货出货退货单审核前判断信用额度
    select @account2 = total, @account3 = account, @UseStoreAccount = USEACCOUNT from LEAGUESTOREALCACCOUNT(nolock)
    where storegid = @billto
    if (@account3 + @account2 + @account1 < 0 ) and (@UseStoreAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
      begin
        set @poMsg = '该单据金额为负，配货信用额与交款额不足,不能审核'
        return(5)
      end
    else
      begin
        --update LEAGUESTOREALCACCOUNT set total = total + @total
        --where storegid = @billto
        set @account1 = -@account1
        exec UPDLEAGUESTOREALCACCOUNTTOTAL @num, @billto, '配出退', @account1
      end
  end

 --2005.1.5 Edited by ShenMin, Q5974, 客户信用额度控制
  declare @opt_UseLeagueClient int,
          @UseClientAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
  exec Optreadint 0, 'UseLeagueClient', 0, @opt_UseLeagueClient output
  if @opt_UseLeagueClient = 1 and @cls = '批发'
  begin
    select @account1 = total from stkoutbck (nolock) where num = @num and cls = @cls
    select @account2 = total, @account3 = account, @UseClientAccount = USEACCOUNT from LEAGUECLIENTACCOUNT(nolock)
    where ClientGid = @billto
    if (@account3 + @account2 + @account1 < 0 ) AND (@UseClientAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
      begin
        set @poMsg = '该单据金额为负，客户信用额与交款额不足,不能审核'
        return(5)
      end
    else
      begin
        set @account1 = -@account1
        exec UPDLEAGUECLIENTACCOUNTTOTAL @num, @billto, '批发退', @account1
      end
  end

  if @return_status <> 0 return @return_status
  exec @return_status = WMSSTKOUTBCKCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 1, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
