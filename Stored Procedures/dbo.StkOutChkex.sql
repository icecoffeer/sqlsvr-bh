SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[StkOutChkex](  
  @cls char(10),                     --类型  
  @num char(10),                     --单号  
  @ckinv smallint = 0,               --库存不足时的处理方式  
  @avalt float = 0,  
  @bvalt float = 0,  
  @ckord smallint = 0,  
  @VStat smallint = 1,  
  @outnum char(10) = null output,  
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/  
  @msg varchar(255) = '' output  
)  
--With Encryptions  
As  
begin  
  declare  
    @gdgid int,            @qty money,                 @tax money,  
    @inprc money,          @rtlprc money,              @whsprc money,  
    @validdate datetime,   @qpc money,                 @vdr int,  
    @line smallint,        @money1 money,              @invqty_canuse money,  
    @lineno int,           @subwrh int,                @taxrate money,  
    @lacktotal money,      @lacktax money,             @lackqty money,  
    @invqty money,         @invtotal money,            @lackratio float,  
    @ordtotal money,       @price money,               @wsprc money,  
    @alcqty money,         @ordqty money,              @payrate money,  
    @sale smallint,        @curtime datetime,          @gdinprc money,  
    @ret_status int,       @gftflag int,               @amt money,  
    @cost money,           @d_outcost money,  
  
    --一般变量  
    @delnum char(10),  
    @delline smallint,  
    @deltotal money,  
    @deltax money,  
  
    --单据数据部分  
    @cur_date datetime,  
    @client int,  
    @wrh int,  
    @stat smallint,  
    @slr int,  
    @ordnum char(10),  
    @paymode char(10),  
    @total money,  
    @reccnt int,  
    @filler int,  
    @gen int,  
    @destgid int,  
    @billtogid int,  
    @dsp_num char(10),  
    @genbill varchar(10),  
  
    --通用变量  
    @return_status int,  
    @cur_settleno int,  
    @store int,  
    @ret1 int, @ret2 int,  
    @msg1 varchar(100), @msg2 varchar(100),  
    @gendsp smallint,  
    @isbianli bit,  
    @outinprcmode int,  
    @ckinvM int,  
    @diff money,  
    @difftotal money,  
    @lack money,  
    @inprc1 money,  
  
    --Option部分  
    @opt_ChkStatDwFunds int,       /* liujunping 2005.04.04 */  
    @opt_ChkWriteToOrd int,        /* 2005.1.13 Edited By Jin Q3403 */  
    @opt_CanAlcQtyLmt int,  
    @opt_RCPCST char(1),  
    @opt_wsale int,                /* 2003.01.10 */  
    @opt_FrcAlcOutPrc int,         /* 2002-06-14 */  
    @opt_AlcQtyLmt int,            /* 2002-08-02 */  
    @opt_UseAlcGft int,  
    @opt_AlcGftQtyMatch int,  
    @opt_UseZLSpecVdr int,  
    @opt_UseLeaguestore int,  
    @AllBalanceInOut int,  
    @opt_LwtClientPrice int  
  
  /* 判断WMSFilter是否允许继续 */  
  declare @Oper char(30)  
  set @Oper = Convert(Char(1), @ChkFlag)  
  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 1, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @msg output  
  if @return_status <> 0 return -1  
  
  /* 读入HDOption */  
  exec OptReadInt 65, 'ChkStatDwFunds', 0, @opt_ChkStatDwFunds output  
  exec OptReadInt 90, '审核时是否回写相应来源单据的配货数量', 0, @opt_ChkWriteToOrd output  
  exec OptReadInt 90, 'CanAlcQtyLmt', 0, @opt_CanAlcQtyLmt output  
  exec OptReadInt 0,  'RCPCST', '0', @opt_RCPCST output  
  exec OptReadInt 0,  'WHOLESALEUSECSTGD', 0, @opt_wsale output  
  exec OptReadInt 0,  'FrcAlcOutPrc', 0, @opt_FrcAlcOutPrc output  
  exec OptReadInt 0,  'AlcQtyLmt', 0, @opt_AlcQtyLmt output  
  exec OptReadInt 0,  'UseAlcGft', 0, @opt_UseAlcGft output  
  exec OptReadInt 90, 'AlcGftQtyMatch', 0, @opt_AlcGftQtyMatch output  
  exec Optreadint 0,  'UseLeagueStore', 0, @opt_UseLeaguestore output  
  exec Optreadint 0,  '直流分店进货流程', 0, @opt_UseZLSpecVdr output  
  exec optreadint 0,  '开启全局进出货成本平进平出', 0, @AllBalanceInOut output  --2005.08.02  
  exec OptReadInt 65, 'LmtClientPrice', 0, @opt_LwtClientPrice output --2006.04.06 added by wangxin  
  
  /* 单据数据初始化 */  
  select  
    @cur_date = convert(datetime, convert(char, getdate(), 102)),  
    @client = BILLTO,  
    @wrh = WRH,  
    @stat = STAT,  
    @slr = SLR,  
    @ordnum = ORDNUM,  
    @paymode = PAYMODE,  
    @total = TOTAL,  
    @reccnt = RECCNT,  
    @filler = FILLER,  
    @gen = GEN,  
    @genbill = genbill,   /*2005-8-22*/  
    @destgid = CLIENT,    /*2002.10.11*/  
    @billtogid = BILLTO   /*2002.10.11*/  
  from STKOUT(nolock)  
  where CLS = @cls and NUM = @num  
  
  /* 通用变量初始化 */  
  set @return_status = 0  
  select @cur_settleno = max(NO) from MONTHSETTLE  
  select @store = usergid from system  
  select @isbianli = 0  
  if exists (select 1 from warehouse(nolock) where gid = @client) set @isbianli = 1  
  set @ret1 = 0  
  set @gendsp = 0  
  if (@cls = '批发'  and (select DSP from SYSTEM) & 1 <> 0)  
    or (@cls = '配货' and (select DSP from SYSTEM) & 2 <> 0)  
    or (@cls = '调出' and (select DSP from SYSTEM) & 4 <> 0)  
    set @gendsp = 1  
  select @outinprcmode = outinprcmode from system(nolock)  
  if (@cls='配货') or (@cls = '批发')  /* 2004-04-01 By ZCZ */  
    select @delnum = num  
    from stkout(nolock)  
    where cls = @cls and note = '缺货待配' and stat = 0 and wrh = @wrh and client = @client  
  
  /* 一些判断 */  
  if (@VStat = 1) and (@stat not in (0, 15))  
  begin  
    set @msg = '审核的不是未审核的单据'  
  end  
  
  if @VStat in (1, 6)  
    update STKOUT set STAT = @VStat, FILDATE = getdate(), SETTLENO = @cur_settleno  
    where CLS = @cls and NUM = @num  
  else begin  
    set @msg = 'VStat状态错误'  
    return 1  
  end  
  
  exec @ret2 = StkOutChkex_Custom @cls, @num, @msg output  
  if @ret2 <> 0 return 1  
  
  ---- added by HAWK on 2005.6.22, in mission 4265  
  /****************************************************  
  FrcAlcOutPrc = 2时  
  if  STORE.出货单价是库存价 INVPRC 或核算价 INPRC 平进平出  
  else  其他出货单价  忽略  
  *****************************************************/  
  declare @vSoutprc char(30)  
  if @cls = '配货' and @opt_FrcAlcOutPrc = 2  
  begin  
    select @vSoutprc = upper(outprc)  
      from STORE where GID = @store  
    if @vSoutPrc = 'INVPRC' or @vSoutPrc = 'INPRC'  
      set @opt_FrcAlcOutPrc = 1  
  end else if @cls = '配货' and @opt_FrcAlcOutPrc = 0  
  begin  
    if @AllBalanceInOut = 1  --2005.08.01  
      set @opt_FrcAlcOutPrc = 1  
  end  
  /*2002-06-14*/  
  /* 更新出货单价 */  
  /* 更新出货物单价不能改赠品的单价 2005.5.19 Edited by Jin*/  
  if @cls = '配货' and @opt_FrcAlcOutPrc = 1 and @Genbill <> 'rtl'  
  begin  
    /*2003-01-03*/  
    exec UPDSTKOUTPRC_ALC @cls, @num  
    select @total = total from STKOUT(nolock) where CLS = @cls and NUM = @num  
  end  
  
  /* 生成提单头 */  
  if @gendsp = 1  
  begin  
    exec @ret2 = StkOutChk_GenDspMst @cls, @num, @wrh, @total, @reccnt, @filler, @slr, @dsp_num output, @msg2 output  
    if @ret2 <> 0  
    begin  
      --raiserror(@msg2, 16, 1)  
      set @msg = @msg2  
      return 1  
    end  
  end  
  
  /* 处理明细 */  
  declare c_stkout cursor for  
    select GDGID, QTY, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH,  
      LINE, SUBWRH, PRICE, WSPRC, isnull(gftflag,0)  
    from STKOUTDTL(nolock) where CLS = @cls and NUM = @num  
  open c_stkout  
  fetch next from c_stkout into  
    @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh,  
    @line, @subwrh, @price, @wsprc, @gftflag  
  while @@fetch_status = 0  
  begin  
    /* 取最新的商品信息 */  
    /* 起用客户商品表时更新商品信息 */  
    if @cls = '批发' and @opt_wsale = 1  
    begin  
      --Added by Jianweicheng 2003.01.10  
      /* Edited By Jin Q3474 修改了起用客户商品表时商品信息可能取不到的错误 */  
      select @inprc1 = g.inprc, @rtlprc = g.rtlprc, @whsprc = g.whsprc, @payrate = g.payrate,  
        @sale = g.sale, @qpc = g.qpc  
      from goods g(nolock), cstgd(nolock)  
      where g.gid = @gdgid and g.gid *= cstgd.gdgid and CSTGD.CSTGID = @client  
    end  
    else  
      select @inprc1 = inprc, @rtlprc = RTLPRC, @whsprc = WHSPRC, @payrate = PAYRATE,  
        @qpc = QPC, @sale = SALE  
      from GOODS(nolock)  
      where GID = @gdgid  
  
    /* 更新进价 */  
    if @outinprcmode = 0  
    begin  
      /* 代销批发商品更新进价 */  
      /*2001-06-04*/  
      if @cls = '批发' and @sale = 2  
      begin  
        select @curtime = getdate()  
        execute @ret_status = GetGoodsPrmInprc @store, @gdgid, @curtime, @qty, @inprc1 output  
        if @ret_status <> 0  
          select @inprc1 = INPRC from GOODS(nolock) where GID = @gdgid  
      end  
  
      /* 2000-05-13 */  
      if @sale = 3 select @inprc1 = @total / @qty * @payrate / 100  
    end  
    else if @outinprcmode = 1  
    begin  
      /* 00-3-3 INPRC从货位中取 */  
      if (select outinprcmode from system) = 1  
        select @inprc1 = lstinprc from subwrhinv where gdgid = @gdgid and subwrh = @subwrh  
    end  
  
    /* 更新出货单明细 */  
    /* 由于审核时包装规格可能发生变化，所以对箱数要重算 */  
    /* 增加箱数重算 Liujunping 2005.4.7*/  
    /* 99-10-14: 这里不能更新LINE.否则,当第1条不足,第2条满足,第3条不足时,第3条不会被删除 */  
    update STKOUTDTL set RTLPRC = @rtlprc, WSPRC = @whsprc, qty = @qty, cases = @qty / @qpc  
      where CLS = @cls and NUM = @num and LINE = @line  
  
    /* 取最新的商品信息 */  
    if @gftflag = 1  
      select @wrh = GFTWRH from STKOUTGFTDTL(nolock)  
      where cls = @cls and num = @num and gftgid = @gdgid and flag = 1  
  
    if @cls = '批发' and @opt_wsale = 1  /* 起用客户商品表时更新商品信息 */  
    begin  
      --Added by Jianweicheng 2003.01.10  
      select @vdr = g.billto, @taxrate = g.taxrate, @sale = g.sale, @qpc = g.qpc  
      from goods g(nolock), cstgd(nolock)  
      where g.gid = @gdgid and g.gid *= cstgd.gdgid and CSTGD.CSTGID = @client  
    end else  
      select @vdr = BILLTO, @taxrate = TAXRATE, @sale = SALE, @qpc = QPC  
      from GOODSH(nolock)  
      where GID = @gdgid  
  
    --判断批发价是否大于客户出货单价 added by wangxin 2006-4-6  
    if @cls = '批发' and @opt_LwtClientPrice = 1  
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
      if @gdOutPrc > @price  
      begin  
        set @Msg = '单据第' + convert(varchar(3), @line) + '行的单价小于客户的出货价'  
          + convert(varchar(10), @gdOutPrc) + '，不允许批发!'  
        return(1)  
      end  
    end  
  
    select @curtime = getdate()  
  
    select @ordqty = null  
    select @ordqty = QTY - ASNQTY  
      from orddtl(nolock)  
      where NUM = @ordnum and GDGID = @gdgid  
    if @ordqty is null select @ordqty = 0  
  
    /* 允许负库存的情况 */  
    if (select ALLOWNEG from warehouse where gid = @wrh) = 1  
    begin  
      /* 允许负库存,正常出库 */  
      execute @return_status = STKOUTCHKUNLOAD  
        @gendsp, @wrh, @subwrh, @gdgid, @qty, @rtlprc, @validdate, @qpc, @gftflag,  
        @ckord, @avalt, @ordqty, @price, @inprc, @wsprc, @taxrate,  
        @cls, @num, @store, @cur_settleno, @client, @slr, @filler,  
        @ordnum, /* 2000-10-12 */ @dsp_num, @line  
      if @return_status <> 0  
      begin  
        set @msg = '调用过程STKOUTCHKUNLOAD出错。'  
        close c_stkout  
        deallocate c_stkout  
        return 10  
      end  
  
      /* 2002-02-04 杨善平 */  
      if @cls = '配货' and  @isbianli = 1  
      begin  
        execute @return_status = LOADIN @client, @gdgid, @qty, @rtlprc, @validdate  
        if @return_status <> 0  
        begin  
          set @msg = '调用过程LOADIN出错。'  
          close c_stkout  
          deallocate c_stkout  
          return 10  
        end  
      end  
  
      /* 2004-04-23 Added by wangxin */  
      if @cls = '配货' and @qty <> 0  
      begin  
        if @opt_ChkWriteToOrd = 0 execute STKOUTWRITETOORD @num, @gdgid, @qty  
      end  
    end  
    else  
    begin  
      /* 不允许负库存 */  
      execute @return_status = StkOutChkUnload  
        @gendsp, @wrh, @subwrh, @gdgid, @qty, @rtlprc, @validdate, @qpc, @gftflag,  
        @ckord, @avalt, @ordqty, @price, @inprc, @wsprc, @taxrate,  
        @cls, @num, @store, @cur_settleno, @client, @slr, @filler,  
        @ordnum, /* 2000-10-12 */ @dsp_num, @line  
      if @return_status <> 0  
      begin  
        set @msg = '调用过程StkOutChkUnload出错。'  
        close c_stkout  
        deallocate c_stkout  
        return 10  
      end  
  
      /* 2002-02-04 杨善平 */  
      if @cls = '配货' and  @isbianli = 1  
      begin  
        execute @return_status = LOADIN @client, @gdgid, @qty, @rtlprc, @validdate  
        if @return_status <> 0  
        begin  
          set @msg = '调用过程LOADIN出错。'  
          close c_stkout  
          deallocate c_stkout  
          return 10  
        end  
      end  
  
      /* 2004-04-23 Added by wnagxin */  
      if @cls = '配货' and @qty <> 0  
      begin  
        if @opt_ChkWriteToOrd = 0 execute STKOUTWRITETOORD @num, @gdgid, @qty  
      end  
    end  
    ---------------------------------  
    select @money1 = @qty * @inprc1  
    execute UPDINVPRC '销售', @gdgid, @qty, @money1, @wrh, @d_outcost output /*2002.08.18*/  
    if @sale = 1  
      update STKOUTDTL set COST = @d_outcost, inprc = @d_outcost / @qty  
      where CLS = @cls and NUM = @num and LINE = @line  
    else  
      update STKOUTDTL set COST = @money1, inprc = @inprc1 --2004-08-12  
      where CLS = @cls and NUM = @num and LINE = @line  
  
    /* 更新定单*/  
    if @ordnum is not null  
      update ORDDTL set ASNQTY = ASNQTY + @qty  
      where NUM = @ordnum and GDGID = @gdgid  
  
    -- reports  
    if @sale = 1 /*2003-06-13*/  
    execute @return_status = STKOUTDTLCHKCRT  
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,  
      @client, @slr, @wrh, @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr,  
      @d_outcost, @VStat, @opt_ChkStatDwFunds /*add by jinlei 3692*/ --2002-06-13  
    else  
    execute @return_status = STKOUTDTLCHKCRT  
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,  
      @client, @slr, @wrh, @gdgid, @qty, @total, @tax, @inprc1, @rtlprc, @vdr,  
      null, @VStat, @opt_ChkStatDwFunds /*add by jinlei 3692*/  
  
    if @return_status <> 0  
    begin  
      set @msg = '调用过程STKOUTDTLCHKCRT出错。'  
      close c_stkout  
      deallocate c_stkout  
      return 10  
    end  
  
    IF (@cls = '批发') and (((@VStat = 6 and @opt_ChkStatDwFunds = 1) or (@VStat = 1 and @opt_ChkStatDwFunds = 0)))  
      /* 更新已记录帐款标志 */  
      update stkout set LogAcnt = 1 where num = @num and cls = @cls  
  
    /* 代销商品若进行促销进价促销，生成调价差异 2001-06-04 */  
    if ((@cls = '批发' and @sale = 2) or (@sale = 3  /*2003.9.16*/)) and (select outinprcmode from system) <> 1  
    begin  
      select @gdinprc = inprc from goods(nolock) where gid = @gdgid  
      if @inprc <> @gdinprc  
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I)  
        values (@cur_settleno, @cur_date, @gdgid, @wrh,  
        (@inprc-@gdinprc) * @qty)  
    end  
  
    if @paymode <> '应收款' and ((@CLS = '批发' and @VStat = 6 and @opt_ChkStatDwFunds = 1) or (@CLS = '批发' and @VStat = 1 and @opt_ChkStatDwFunds = 0) or (@CLS <> '批发'))  
    begin  
      execute @return_status = RCPDTLCHK  
        @cur_date, @cur_settleno, @client, @gdgid, @wrh, @qty,  
        @total, @inprc, @rtlprc  
    end  
    if @return_status <> 0  
    begin  
      close c_stkout  
      deallocate c_stkout  
      return 10  
    end  
  
    NextLoop:  
    fetch next from c_stkout into  
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @wsprc, @gftflag  
  end  
  close c_stkout  
  deallocate c_stkout  
  
  /* 2000-04-27: 处理删除的定单行 */  
  /* 出货数不足定货数时的处理这段逻辑如果没有客户使用考虑关闭！*/  
  if @ckord <> 0 and @ordnum is not null  
  begin  
    raiserror('出货数不足定货数时的处理选项将在2006年4月关闭，看到此信息请与海鼎开发部联系。', 16, 1)  
    declare c_ord cursor for select gdgid, qty-asnqty, price from orddtl(nolock)  
    where num = @ordnum and qty - asnqty <> 0 and gdgid not in  
      (select gdgid from stkoutdtl(nolock) where cls = @cls and num = @num)  
    select @qty = 0  
    open c_ord  
    fetch next from c_ord into @gdgid, @ordqty, @price  
    while @@fetch_status = 0  
    begin  
        /* 2001-4-18 */  
        if not exists  
          (select * from stkoutdtl(nolock)  
          where cls = @cls  
          and num in (select num from stkout(nolock) where ordnum = @ordnum and cls = @cls)  
          and gdgid = @gdgid)  
        begin  
          select @ordtotal = @ordqty * @price,  
                 @lackqty = @ordqty,  
                 @lacktotal = @lackqty * @price,  
                 @total = @qty * @price  
          select @inprc = inprc, @rtlprc = rtlprc, @wsprc = whsprc, @taxrate = taxrate  
          from goods(nolock) where gid = @gdgid  
  
          /*2001-06-04*/  
          if @cls = '批发' and @sale = 2  
          begin  
            execute @ret_status = GetGoodsPrmInprc @store, @gdgid, @curtime, @qty, @inprc output  
            if @ret_status <> 0  
              select @inprc = INPRC from GOODS(nolock) where GID = @gdgid  
          end  
  
          execute @return_status = StkOutChkRegLack  
                  @ckord,  
                  @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, @gftflag,  
                  @wrh, @ordqty, @ordtotal, @qty, @total, @lackqty, @lacktotal,  
                  @cls, @num, @store, @cur_settleno, @client, @slr, @filler,  
                  @ordnum,  
                  @outnum output  
        end  
  
        fetch next from c_ord into @gdgid, @ordqty, @price   --Modified By Wang Xin 2002-04-15  
    end  
    close c_ord  
    deallocate c_ord  
  end  
  
  /* 设置ORD.FINISHED */  
  if @ordnum is not null and @return_status = 0  
  begin  
    if @cls = '批发' and @opt_UseZLSpecVdr = 1  
    begin  
      update ORD set finished = 1 where num = @ordnum  
    end else begin  
      if not exists (select * from ORDDTL(nolock) where NUM = @ordnum  
        and QTY > ARVQTY + ASNQTY)  
        update ORD set FINISHED = 1 where NUM = @ordnum  
      else  
        update ORD set FINISHED = 0 where NUM = @ordnum  
    end  
  end  
  
  /* 生成完提货单的处理 */  
  if @gendsp = 1  
    exec StkOutChk_GenDspCheck @dsp_num  
  
  if @paymode <> '应收款' and ((@CLS = '批发' and @VStat = 6 and @opt_ChkStatDwFunds = 1) or (@CLS = '批发' and @VStat = 1 and @opt_ChkStatDwFunds = 0) or (@CLS <> '批发'))  
  begin            /*此时，这张批发单的结算状态应该是已结清 2001-10-29*/  
    if @cls = '批发' and (select finished from stkout(nolock) where num = @num and cls = @cls )<>1  
    begin  
      update stkout set finished = 1 where num = @num and cls = @cls  
      update stkoutdtl set rcpqty = qty,rcpamt = total where num = @num and cls = @cls  
    end  
  end  
  
  if not(@cls = '批发' and @VStat = 1 and @opt_ChkStatDwFunds = 1)  
  begin  
    EXEC @return_status = STKOUTBEFORECHK @num, @cls, @msg output  
    if @return_status <> 0  
    begin  
      --raiserror(@msg, 16, 1)  
      return 1  
    end  
  end  
  
  /* add by cyb 2002.08.01 */  
  if (@cls = '批发' and @VStat = 6 and @opt_ChkStatDwFunds = 1) or (@cls = '批发' and @VStat = 1 and @opt_ChkStatDwFunds = 0) or (@cls <> '批发')  
  begin  
    if @Opt_RCPCST = '1'  
    begin  
      insert into CSTBILL (ASETTLENO,ADATE,CLS,CLIENT,OUTNUM,TOTAL,RCPTOTAL,OTOTAL)  
      SELECT SETTLENO,FILDATE,CLS,BILLTO,NUM,TOTAL,0,TOTAL  
      FROM STKOUT(nolock)  
      WHERE NUM = @num AND CLS = @CLS AND TOTAL <>0 and paymode = '应收款'  
        and billto not in (select gid from store(nolock))  
    end  
  end  
  
  if @opt_UseLeaguestore = 1 and @cls = '配货'  
  begin  
    select  @total = TOTAL from STKOUT where CLS = @cls and NUM = @num  
    /* Edited by ShenMin, 2005.6.30, Q4331, 加盟店信用额度增加扣款日志 */  
    execute @return_status = UPDLEAGUESTOREALCACCOUNTTOTAL @NUM, @client, '配出', @total --ShenMin  
    if @return_status <> 0  
    begin  
      set @msg = '调用过程UPDLEAGUESTOREALCACCOUNTTOTAL出错。'  
      return 1  
    end  
  end  
  
  --2005.1.5, Edited by ShenMin, Q5974, 客户信用额度控制  
  Declare @opt_UseLeagueClient int  
  exec Optreadint 0, 'UseLeagueClient', 0, @opt_UseLeagueClient output  
  if @opt_UseLeagueClient = 1 and @cls = '批发'  
  begin  
    execute @return_status = UPDLEAGUECLIENTACCOUNTTOTAL @NUM, @client, '批发', @total  --ShenMin  
  end  
  
  if @return_status <> 0  
  begin  
    set @msg = '调用过程UPDLEAGUECLIENTACCOUNTTOTAL出错。'  
    return 1  
  end  
  
  /*减少预配数*/  
  declare @Opqty money, @m_store int  
  select @m_store = usergid from system  
  select @wrh = WRH from STKOUT(nolock) where CLS = @cls and NUM = @num  
  declare c_Procalcgft1 cursor for  
  select gdgid, ISNULL(RSVALCQTY, 0), line  
  from stkoutdtl(nolock)  
  where cls = @cls and num = @num order by line  
  open c_Procalcgft1  
  fetch next from c_Procalcgft1 into @gdgid, @qty, @lineno  
  while @@fetch_status = 0  
  begin  
    exec @return_status = DecPreAlcQty @piStore = @m_store, @piWrh = @wrh, @piGdgid = @gdgid, @piQty = @qty, @piMode = -1, @poOpqty = @Opqty output --zhangzhen 20071114  
    if @return_status <> 0  
    begin  
      close c_Procalcgft1  
      deallocate c_Procalcgft1  
      return @return_status  
    end  
    update stkoutdtl set RSVALCQTY = ISNULL(RSVALCQTY, 0) - @Opqty  
      where cls = @cls and num = @num and gdgid = @gdgid and line = @lineno  
    fetch next from c_Procalcgft1 into @gdgid, @qty, @lineno  
  end  
  close c_Procalcgft1  
  deallocate c_Procalcgft1  
  
    /*  杨赛 审核 由 状态由 0 - 1 */  
  if @cls = '配货' and @VStat = 1  
  begin  
    delete from EPSSENDSTKOUT where num = @num  
    insert into EPSSENDSTKOUT values(@num, @client, 0)  
  end  
  
  /* 调用WMSFilterBck */  
  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 1, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null  
  return 0  
end

GO
