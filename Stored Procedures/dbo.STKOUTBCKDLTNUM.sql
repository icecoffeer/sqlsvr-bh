SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKDLTNUM](
  @old_cls char(10),
  @old_num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,          @vdr int,                 @old_settleno int,
    @old_client int,             @old_ocrdate datetime,    @old_total money,
    @old_tax money,              @old_wrh int,             @old_fildate datetime,
    @old_stat smallint,          @old_slr int,             @old_reccnt int,
    @old_gdgid int,              @old_qty money,           @oldd_total money,
    @oldd_tax money,             @old_inprc money,         @old_rtlprc money,
    @old_validdate datetime,     @old_src int,             @old_billto int,
    @cur_date datetime,          @cur_settleno int,        @cur_inprc money,
    @cur_rtlprc money,           @temp_qty money,          @temp_total money,
    @temp_tax money,             @money1 money,            @old_subwrh int,
    @old_note varchar(100),--2001-8-29
    @old_gencls char(10),        @old_genbill char(10),    @old_gennum char(12),     /*2001-09-18*/
    @old_itemno int,             @old_GftTotal money,      @old_FromNum char(10),
 /*零售退货   2001-11-26*/
    @old_saleqty money,       @old_bckqty money,
    @old_CardGid int,         @old_CstGid int,          @old_CstFavamt money,
    @old_favprc money,
    @paymode char(10),         @d_qty money,             @d_total money,/*2002-01-04*/
    @isbianli bit/*2002-02-04*/, @temp_cost money,         @old_cost money /*2002-06-13*/,
    @sale smallint, /*2003-06-13*/ @old_score money /*2006-06-14*/
  declare @optvalue_Chk int
  exec OPTREADINT 69, 'ChkStatDwFunds', 0, @optvalue_Chk output /*add by jinlei 3692*/
  if @old_cls <> '批发'
    set @optvalue_Chk = 0

  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char,getdate(),102))
  select
    @cur_settleno = max(NO) from MONTHSETTLE
  /*零售退货   2001-11-26*/
  select
    @old_CstFavamt = 0,
    @old_favprc = 0
  select
    @old_settleno = SETTLENO,
    @old_client = CLIENT,
    @old_ocrdate = OCRDATE,
    @old_total = TOTAL,
    @old_tax = TAX,
    @old_wrh = WRH,
    @old_fildate = FILDATE,
    @old_stat = STAT,
    @old_slr = SLR,
    @old_reccnt = RECCNT,
    @old_src = SRC,
    @old_billto = BILLTO,
    @old_gencls =GENCLS,
    @old_genbill =GENBILL,
    @old_gennum =GENNUM,
    @old_score = SCORE,
    @paymode = PAYMODE, /*2002-01-04*/
    @old_GftTotal = GftTotal,
    @old_FromNum = FROMNUM
    from STKOUTBCK where CLS = @old_cls and NUM = @old_num

  /*2002-02-04*/
  select @isbianli = 0
  if exists (select 1 from warehouse(nolock) where gid = @old_client)
	select @isbianli = 1

  if @old_stat <> 1 begin
    set @errmsg = '删除的不是已审核的单据'
    return(1)
  end

  declare @option_ISZBPAY int
  exec OptReadInt 0, 'ISZBPAY', 0, @option_ISZBPAY output

  /* 00-3-30 */
  execute @return_status = CanDeleteBill 'STKLOUTBCK', @old_cls, @old_num, @errmsg output
  if @return_status != 0 begin
    --raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  update STKOUTBCK set STAT = 2 where CLS = @old_cls and NUM = @old_num

  if @old_cls = '零售'
  begin
  insert into STKOUTBCK (CLS, NUM, SETTLENO, CLIENT, OCRDATE, TOTAL,
    TAX, WRH, FILDATE, FILLER, CHECKER, STAT, MODNUM, SLR, RECCNT, SRC, BILLTO,
    GENCLS, GENNUM, GENBILL, GFTTOTAL, SCORE)
    values (@old_cls, @neg_num, @cur_settleno, @old_client,
    @old_ocrdate, -@old_total, -@old_tax, @old_wrh, getdate(),
    @new_oper, @new_oper, 4, @old_num, @old_slr, @old_reccnt, @old_src, @old_billto,
    @old_GENCLS, @old_GENNUM, @old_GENBILL, -@old_GftTotal, -@old_score)
  insert into STKOUTBCKDTL (CLS, NUM, LINE, SETTLENO, GDGID, QTY, WSPRC,
    PRICE, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, SUBWRH, RCPQTY, RCPAMT,NOTE,
    ITEMNO, QPCGID, GFTTOTAL, QPCQTY)
    select CLS, @neg_num, LINE, @cur_settleno, GDGID, -QTY, WSPRC,
    PRICE, -TOTAL, -TAX, INPRC, RTLPRC, VALIDDATE,
    STKOUTBCKDTL.WRH, STKOUTBCKDTL.SUBWRH, 0, 0,NOTE,
    ITEMNO, QPCGID, -GFTTOTAL, -QPCQTY
    from STKOUTBCKDTL
    where CLS = @old_cls and NUM = @old_num

/*2001-10-29*/
  insert into STKOUTBCKCURDTL
    select cls, @neg_num, currency, -1*amount
    from STKOUTBCKCURDTL where cls=@old_cls and num=@old_num
  end
  else begin
  insert into STKOUTBCK (CLS, NUM, SETTLENO, CLIENT, OCRDATE, TOTAL, FROMNUM,
    TAX, WRH, FILDATE, FILLER, CHECKER, STAT, MODNUM, SLR, RECCNT, SRC, BILLTO, PAYMODE)  /*2002-01-04*/
    values (@old_cls, @neg_num, @cur_settleno, @old_client,
    @old_ocrdate, -@old_total, @old_FromNum, -@old_tax, @old_wrh, getdate(),
    @new_oper, @new_oper, 4, @old_num, @old_slr, @old_reccnt, @old_src, @old_billto, @PAYMODE)
  insert into STKOUTBCKDTL (CLS, NUM, LINE, SETTLENO, GDGID, QTY, WSPRC,
    PRICE, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, SUBWRH, RCPQTY, RCPAMT,NOTE,
    COST) /*2002-06-13*/
    select CLS, @neg_num, LINE, @cur_settleno, GDGID, -QTY, WSPRC,
    PRICE, -TOTAL, -TAX, INPRC, RTLPRC, VALIDDATE,
    STKOUTBCKDTL.WRH, STKOUTBCKDTL.SUBWRH, 0, 0,NOTE,
    -COST /*2002-06-13*/
    from STKOUTBCKDTL
    where CLS = @old_cls and NUM = @old_num
  end

  EXEC @return_status = STKOUTBEFORECHK @neg_num, @old_cls, @errmsg output
  if @return_status <> 0
  begin
    --raiserror(@errmsg, 16, 1)
		return(3)
  end

  declare c_stkout cursor for
    select GDGID, QTY, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC, SUBWRH, ITEMNO,/* 零售退货   2001-11-26*/
      COST/*2002-06-13*/
    from STKOUTBCKDTL where CLS = @old_cls and NUM = @old_num
  open c_stkout
  fetch next from c_stkout into
    @old_gdgid, @old_qty, @oldd_total, @oldd_tax, @old_validdate, @old_wrh,
    @old_inprc, @old_rtlprc, @old_subwrh, @old_itemno/*2001-11-26*/,
    @old_cost/*2002-06-13*/
  while @@fetch_status = 0 begin
    DECLARE @fromNum VARCHAR(10)
    DECLARE @enabledWhsLinkBcp int
    EXEC OptReadInt 0, 'Whs_Link_Bcp', 0, @enabledWhsLinkBcp OUTPUT
    IF @old_cls = '批发' and @enabledWhsLinkBcp = 1
    BEGIN
      SELECT @fromNum = FromNum
      FROM StkOutBck
      WHERE Num = @old_num AND Cls = '批发'

      UPDATE StkOutDtl
      SET BckQty = BckQty - @old_qty
      WHERE GDGid = @old_gdgid AND Cls = '批发' AND Num = @fromNum
    END

    if @old_cls = '批发' or @old_cls = '零售'/*2002-06-13*/
    begin
      select @temp_qty = -@old_qty, @temp_total = -@old_cost/*-@old_qty * @old_inprc 2004-08-25*/,
        @temp_cost = - @old_cost
--      execute UPDINVPRC '销售退货', @old_gdgid, @temp_qty, @temp_total, @old_wrh,@temp_cost output  /*2002-06-13 2002.08.18*//*linbo modified by tkl 2002.12.05*/
      execute UPDINVPRC '进货', @old_gdgid, @temp_qty, @temp_total, @old_wrh /*2004-08-25*/
    end
    --2002-06-13
    if @old_cls = '配货'
    begin
      select @temp_qty = -@old_qty, @temp_total = -@oldd_total,
        @temp_cost = null
      execute UPDINVPRC '进货', @old_gdgid, @temp_qty, @temp_total, @old_wrh /*2002.08.18*/
    end
/*零售退货   2001-11-26*/
    if @old_cls = '零售'
    begin
    	select @old_Cardgid = Guest from buy1(nolock)
    		where posno = @old_gencls and flowno = @old_gennum                /* 取卡号*/
    	if @old_Cardgid is not null
    	begin
    		select @old_favprc = isnull((price - Realamt/qty),0) from buy2(nolock)
              		where posno=@old_gencls and flowno=@old_gennum and itemno=@old_itemno and gid=@old_gdgid
              			/*and (price * qty ) <> realamt*/
        		select @old_CstFavamt = @old_favprc * @old_qty                   /*算优惠金额*/
    		select @old_CstGid = cst.Gid from Client cst(nolock), Card c(nolock) where cst.Gid = c.cstGid and c.gid = @old_CardGid
    		if @old_CstGid is not null                                      /*更新Client*/
    			update Client set Total = Total + @old_total, Favamt = Favamt + @old_CstFavamt,
    				    Tlgd = Tlgd + @old_qty where gid = @old_cstGid
    	end
    	--2006.02.24 更新销售定单池的零售退货数
    	  if exists(select 1 from preordpooldtl where POSNO = @old_genCls and FLOWNO = @old_genNum
    	    and GDGID = @old_gdgid)
    	      update preordpooldtl set RTLBACKQTY = RTLBACKQTY - @old_qty, PREORDQTY = PREORDQTY + @old_qty
			      where POSNO = @old_genCls and FLOWNO = @old_genNum and GDGID = @old_gdgid
    end

    select
      @cur_inprc = INPRC,
      @cur_rtlprc = RTLPRC,
      @vdr = BILLTO,
      @sale = SALE/*2003-06-13*/
      from GOODS where GID = @old_gdgid

    execute @return_status = UNLOAD
      @old_wrh, @old_gdgid, @old_qty, @cur_rtlprc, @old_validdate
    if @return_status <> 0 break

    /* 2002-02-04 杨善平 */
    if @old_cls = '配货' and  @isbianli = 1
      begin
        execute @return_status = LOADIN @old_client, @old_gdgid, @old_qty, @cur_rtlprc, @old_validdate
        if @return_status <> 0 break
      end
    /******************/

    /* 99-11-10: 不考虑SYSTEM.DSP */
    if @old_subwrh is not null /* and (select DSP from system) = 0 */
    begin
      execute @return_status = UNLOADSUBWRH
        @old_wrh, @old_subwrh, @old_gdgid, @old_qty
      if @return_status <> 0 break
    end

    select
      @temp_qty = -@old_qty, @temp_total = -@oldd_total, @temp_tax = -@oldd_tax
    if @sale = 1/*2003-06-13*/
    execute @return_status = STKOUTBCKDTLCHKCRT
      @old_cls, @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_billto, @old_slr, @old_wrh,
      @old_gdgid, @temp_qty, @temp_total, @temp_tax,
      @old_inprc, @old_rtlprc, @vdr, 1, @optvalue_Chk, @temp_cost  /*2002-06-13*/
    else
    execute @return_status = STKOUTBCKDTLCHKCRT
      @old_cls, @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_billto, @old_slr, @old_wrh,
      @old_gdgid, @temp_qty, @temp_total, @temp_tax,
      @old_inprc, @old_rtlprc, @vdr, 1, @optvalue_Chk, null
    if @return_status <> 0 break

    if @old_cls = '零售' and @old_genbill = 'buy1'
	  begin
	  	declare @favamt_24 money, @FAVTYPE_24 varchar(4)
      select @favamt_24 = sum(FAVAMT), @FAVTYPE_24 = max(FAVTYPE) from BUY21(nolock)
      where POSNO = @old_gencls and FLOWNO = @old_gennum
        and ITEMNO = @old_itemno and FAVTYPE like '24%'
      if @favamt_24 is not null and @favamt_24 <> 0
      begin
      	declare @_usergid int, @_zbgid int, @qty_24 money
      	select @qty_24 = qty from BUY2(nolock)
        where POSNO = @old_gencls and FLOWNO = @old_gennum
          and ITEMNO = @old_itemno
        set @favamt_24 = @favamt_24 * @old_qty / @qty_24
      	select @_usergid = usergid, @_zbgid = zbgid from system(nolock)
      	if @option_ISZBPAY = 0
        begin
      	  --供应商
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@old_wrh, @old_gdgid, @vdr, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 1, @favamt_24, 1, @old_client)
          --总部
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@old_wrh, @old_gdgid, @_zbgid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, @favamt_24, 0, @old_client)
          --门店
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@old_wrh, @old_gdgid, @_usergid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, @favamt_24, 0, @old_client)
        end if @option_ISZBPAY = 1
        begin
          --总部
          insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
            FV_P, FV_L, FV_A, MODE, BCSTGID)
          values (@old_wrh, @old_gdgid, @_zbgid, @_usergid, @cur_date, @cur_settleno,
            @FAVTYPE_24, 0, @favamt_24, 0, @old_client)
        end
        if @@error <> 0 break
      end
	  end

    /* 生成调价差异, 库存已经按照当前售价退库了 */
    /*2002-06-13 移动加权平均核算这时不应计算进价的调价差异*/
    --if @old_inprc <> @cur_inprc or @old_rtlprc <> @cur_rtlprc
    --if @old_rtlprc <> @cur_rtlprc
    /*2003-06-13 V2算法下，代联销商品仍然应该计算进价的调价差异*/
    if @old_inprc <> @cur_inprc or @old_rtlprc <> @cur_rtlprc
    begin
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @old_gdgid, @old_wrh,
    --    (@cur_inprc-@old_inprc) * -@old_qty, (@cur_rtlprc-@old_rtlprc) * -@old_qty)
        case @sale when 1 then 0 else (@cur_inprc-@old_inprc) * -@old_qty end, (@cur_rtlprc-@old_rtlprc) * -@old_qty)
    end

    select @d_qty = -@old_qty, @d_total = -@old_total  /*2002-01-04*/
    if @paymode <> '应收款'
      and ((@old_CLS = '批发' and @optvalue_chk = 0)
        or (@old_CLS <> '批发'))
    begin
      execute @return_status = RCPDTLDLTCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
        @old_billto, @old_gdgid, @old_wrh, @d_qty, @d_total,
        @old_inprc, @old_rtlprc
    end
    fetch next from c_stkout into
      @old_gdgid, @old_qty, @oldd_total, @oldd_tax, @old_validdate, @old_wrh,
      @old_inprc, @old_rtlprc, @old_subwrh,@old_itemno, @old_cost /*2002-06-13*/
  end
  close c_stkout
  deallocate c_stkout

/*更新client             零售退货2001-11-26*/
  if @old_cls = '零售' and @old_Cstgid is not null
  begin
  	if @old_genbill = 'buy1'
  		select @old_saleqty = sum(qty) from buy2(nolock) where posno=@old_gencls and flowno=@old_gennum
  	else if @old_genbill = 'cutbuy1'	/*2002.08.12*/
  		select @old_saleqty = sum(iqty) from cutbuy2(nolock) where num=@old_gennum
  	select @old_bckqty = sum(qty) from stkoutbckdtl(nolock) where num = @old_num and cls = '零售'
  	if @old_saleqty = @old_qty
  		update Client set Tlcnt = Tlcnt - 1 where gid = @old_cstGid
  end


  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    set @errmsg = '处理单据时发生错误.'
    return (@return_status)
  end

--2005.7.14, Added by ShenMin, Q4331, 配货出货退货单冲单时修改信用额度
  declare
    @opt_UseLeagueStore int,
    @account1 money, @account2 money, @account3 money,
    @UseStoreAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能

  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output

  if @opt_UseLeagueStore = 1 and @old_cls = '配货'
  begin
    select @account1 = total from stkoutBck(nolock) where cls = @old_cls and num = @old_num
    select @account2 = total, @account3 = account, @UseStoreAccount = USEACCOUNT from LEAGUESTOREALCACCOUNT(NOLOCK)
    where storegid = @old_billto
    if (@account3 + @account2 - @account1 < 0 ) and (@UseStoreAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    begin
      set @errmsg = '该单据金额为负，配货信用额与交款额不足,不能冲单'
      return(5)
    end
    else
    begin
      --update LEAGUESTOREALCACCOUNT set total = total + @account1
      --where storegid = @old_client
      exec UPDLEAGUESTOREALCACCOUNTTOTAL @neg_num, @old_client, '配出退', @account1
    end
  end

--2005.1.5 Edited by ShenMin, Q5974, 客户信用额度控制
  declare
    @opt_UseLeagueClient int,
    @UseClientAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
  exec Optreadint 0, 'UseLeagueClient', 0, @opt_UseLeagueClient output
  if @opt_UseLeagueClient = 1 and @old_cls = '批发'
  begin
    select @account1 = total from stkoutBck(nolock) where cls = @old_cls and num = @old_num
    select @account2 = total, @account3 = account, @UseClientAccount = USEACCOUNT from LEAGUECLIENTACCOUNT(NOLOCK)
    where ClientGid = @old_billto
    if (@account3 + @account2 - @account1 < 0 ) and (@UseClientAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    begin
      set @errmsg = '该单据金额为负，批发信用额与交款额不足,不能冲单'
      return(5)
    end
    else
    begin
      exec UPDLEAGUECLIENTACCOUNTTOTAL @neg_num, @old_client, '批发退', @account1
    end
  end

  return(@return_status)
end
GO
