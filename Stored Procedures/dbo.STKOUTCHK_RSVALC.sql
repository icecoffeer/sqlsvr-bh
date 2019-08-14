SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[STKOUTCHK_RSVALC](
  @cls char(10),                     --类型
  @num char(10),                     --单号
  @ckinv smallint = 0,               --库存不足时的处理方式
  @avalt float = 0,
  @bvalt float = 0,
  @ckord smallint = 0,
  @VStat smallint = 15,
  @outnum char(10) = null output,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
)
--With Encryptions
As
begin
  declare
    @gdgid int,            @qty money,                 @tax money,
    @inprc money,          @rtlprc money,              @whsprc money,
    @validdate datetime,   @qpc money,                 @vdr int,
    @msg varchar(200),     @line smallint,             @money1 money,
    @lineno int,           @subwrh int,                @taxrate money,
    @lacktotal money,      @lacktax money,             @lackqty money,
    @invqty money,         @invtotal money,            @lackratio float,
    @ordtotal money,       @price money,               @wsprc money,
    @alcqty money,         @ordqty money,              @payrate money,
    @sale smallint,        @curtime datetime,          @gdinprc money,
    @ret_status int,       @gftflag int,               @invqty_canuse money,
    /*2001-09-29*/

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
    @genbill varchar(10),     /*2005-8-22*/
    @srcaganum varchar(14),

    --通用变量
    @return_status int,
    @cur_settleno int,
    @store int,
    @ret1 int, @ret2 int,
    @msg1 varchar(100), @msg2 varchar(100),
    @gendsp smallint,              /* 生成提货单 */
    @isbianli bit,
    @outinprcmode int,
    @ckinvM int,
    @diff money,
    @difftotal money,
    @lack money,
    @GFTID int,

    --Option部分
    @opt_ChkStatDwFunds int,       /* liujunping 2005.04.04 */
    @opt_ChkWriteToOrd int,        /* 2005.1.13 Edited By Jin Q3403 */
    @opt_CanAlcQtyLmt int,
    @opt_RCPCST char(1),
    @opt_wsale int,                /* 2003.01.10 */
    @opt_AlcQtyLmt int,            /* 2002-08-02 */
    @opt_UseAlcGft int,
    @opt_AlcGftQtyMatch int,
    @opt_UseZLSpecVdr int,
    @opt_UseLeaguestore int,
    @optvalue int,
    @opt_DelFlag int,
    @opt_MAndDWrh int
  DECLARE @AMT MONEY,@COST MONEY /*2003.01.27 HXS*/

  /* 读入HDOption */
  exec OptReadInt 65, 'ChkStatDwFunds', 0, @opt_ChkStatDwFunds output
  exec OptReadInt 90, '审核时是否回写相应来源单据的配货数量', 0, @opt_ChkWriteToOrd output
  if @Cls = '配货'
    exec OptReadInt 90,  'CanAlcQtyLmt', 0, @opt_CanAlcQtyLmt output
  else if @Cls = '批发'
    exec OptReadInt 65,  'AlcQty', 0, @opt_CanAlcQtyLmt output
  else set @opt_CanAlcQtyLmt = 0
  exec OptReadInt 0,  'RCPCST', '0', @opt_RCPCST output
  exec OptReadInt 0,  'WHOLESALEUSECSTGD', 0, @opt_wsale output
  exec OptReadInt 0,  'AlcQtyLmt', 0, @opt_AlcQtyLmt output
  exec OptReadInt 0,  'UseAlcGft', 0, @opt_UseAlcGft output
  exec OptReadInt 90, 'AlcGftQtyMatch', 0, @opt_AlcGftQtyMatch output
  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output
  exec Optreadint 0, '直流分店进货流程', 0, @opt_UseZLSpecVdr output
  exec Optreadint 0, 'IFDELSTKOUTDTL', 0, @opt_DelFlag output
  exec Optreadint 0, 'SynMasterAndDetailWrh', 0, @opt_MAndDWrh output

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 15, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg output
  if @return_status <> 0 return -1

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
    @destgid = CLIENT,               /*2002.10.11*/
    @billtogid = BILLTO              /*2002.10.11*/
  from STKOUT(nolock)
  where CLS = @cls and NUM = @num

  /* 通用变量初始化 */
  set @return_status = 0
  select @cur_settleno = max(NO) from MONTHSETTLE
  select @store = usergid from system
  /*2002-02-04*/
  select @isbianli = 0
  if exists (select 1 from warehouse(nolock) where gid = @client)
    set @isbianli = 1
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
  if (@VStat = 15) and (@stat not in (0, 7)) begin
    set @poMsg = '审核的不是未审核的单据'
    return(1)
  end

  exec @ret1 = StkOutChk_Check @cls, @destgid, @billtogid, @num, @msg1 output
  if @ret1 <> 0
  begin
    --raiserror(@msg1, 16, 1)
    set @poMsg = @msg1
    return(3)
  end

  if @VStat = 15
    update STKOUT set STAT = @VStat, FILDATE = getdate(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num
  else begin
    set @poMsg = 'VStat状态错误'
    return 1
  end

  /*删除数量为0的记录*/
  if @opt_DelFlag = 1
    delete from stkoutdtl where cls = @cls and num = @num and qty = 0

  /* 搜索配货赠品,再根据一些限制重算,这样就避免在底下的过程中处理 */
  if @opt_UseAlcGft = 1 and @cls = '配货'
  begin
    --清空STKOUTGFTDTL表, stkoutdtl表
    delete from STKOUTGFTDTL where cls = @cls and num = @num
    delete from stkoutdtl where cls = @cls and num = @num and gftflag = 1

    --将数据导入TMPALCGFTGOODS表
    delete from TMPALCGFTGOODS where spid = @@spid
    insert into TMPALCGFTGOODS(spid, GDGID, QTY)
    select @@spid, gdgid, sum(qty)
    from stkoutdtl(nolock) where cls = @cls and num = @num
    group by gdgid

    --搜索赠品
    exec Stkoutchk_SearchAlcGft @client

    --将结果从临时表导出
    insert into STKOUTGFTDTL (CLS, NUM, LISTNO, AGANUM, MATCHTIME, GDGID, ALCQTY, GFTGID, GFTQTY, GFTWRH, FLAG, INVTAG)
    select @cls, @num, LISTNO, AGANUM, MATCHTIME, GDGID, ALCQTY, GFTGID, GFTQTY, GFTWRH, FLAG, 0
    from TMPSTKOUTGFTDTL
    where spid = @@spid

    declare
      @c_GFTGID int,	@c_GFTQTY money,
      @c_GFTWRH int,	@c_SRCNUM varchar(14),
      @c_line int
    select @c_line = Isnull(max(line), 0) + 1 from stkoutdtl(nolock) where cls = @cls and num = @num
    declare c_TMPSTKOUTDTL cursor for
    select GFTGID, GFTQTY, GFTWRH, SRCNUM
    from TMPSTKOUTDTL(nolock)
    where spid = @@spid
    open c_TMPSTKOUTDTL
    fetch next from c_TMPSTKOUTDTL into
      @c_GFTGID, @c_GFTQTY, @c_GFTWRH, @c_SRCNUM
    while @@fetch_status = 0
    begin
      insert into stkoutdtl (cls, num, line, settleno, gdgid, qty, wsprc, price,
        total, tax, inprc, rtlprc, wrh, gftflag, SRCAGANUM)
      select @cls, @num, @c_line, @cur_settleno, @c_GFTGID,
        @c_GFTQTY, g.whsprc, 0, 0, 0, g.inprc, g.rtlprc, @c_gftwrh, 1, @c_SRCNUM
      from goods g(nolock)
      where g.gid = @c_GFTGID

      set @c_line = @c_line + 1

      fetch next from c_TMPSTKOUTDTL into
        @c_GFTGID, @c_GFTQTY, @c_GFTWRH, @c_SRCNUM
    end
    close c_TMPSTKOUTDTL
    deallocate c_TMPSTKOUTDTL


    --处理赠品
    exec StkoutChk_ProcAlcGft @cls, @num, @ckinv, @bvalt, @avalt
  end

  /* 启用限制单据的汇总仓位和明细仓位一致 */
  if @cls = '配货' and @opt_MAndDWrh = 1
  begin
    update STKOUTDTL set wrh = @wrh, note = ltrim(rtrim(note)) + ' 原仓位(' + ltrim(rtrim(str(wrh))) + ')'
    where CLS = @cls and NUM = @num and wrh <> @wrh
  end

  /* 处理明细 */
  declare c_stkout cursor for
    select GDGID, QTY, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH,
      LINE, SUBWRH, PRICE, WSPRC, isnull(gftflag,0), isnull(GFTID, 0), srcaganum
    from STKOUTDTL(nolock) where CLS = @cls and NUM = @num and qty <> 0
  open c_stkout
  fetch next from c_stkout into
    @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh,
    @line, @subwrh, @price, @wsprc, @gftflag, @GFTID, @srcaganum
  while @@fetch_status = 0
  begin
    if @gftflag = 1
      select @wrh = GFTWRH from STKOUTGFTDTL(nolock)
      where cls = @cls and num = @num and gftgid = @gdgid and flag = 1 and aganum = @srcaganum
    /*2005-8-22*/
    if @genbill = 'rtl'
    begin
      select @invqty = isnull(sum(AVLQTY), 0)
        from V_ALCINV(nolock)
       where WRH = @wrh and GDGID = @gdgid and STORE = @store
      update stkoutdtl set invqty = @invqty
        where CLS = @cls and NUM = @num and LINE = @line
    end

    /* 取最新的商品信息 */
    /* 起用客户商品表时更新商品信息 */
    if @cls = '批发' and @opt_wsale = 1
    begin
      --Added by Jianweicheng 2003.01.10
      /* Edited By Jin Q3474 修改了起用客户商品表时商品信息可能取不到的错误 */
      select @vdr = g.billto, @taxrate = g.taxrate, @alcqty = isnull (cstgd.alcqty, g.alcqty),
        @sale = g.sale, @qpc = g.qpc
      from goods g(nolock), cstgd(nolock)
      where g.gid = @gdgid and g.gid *= cstgd.gdgid and CSTGD.CSTGID = @client
    end
    else  if (@cls = '配货') --2005.7.28, Added by ShenMin, Q4527, 增加各店商品表的配货单位
    begin
      select
        @vdr = G.BILLTO,
        @taxrate = G.TAXRATE,
        @sale = G.SALE,
        @qpc = G.QPC
      from GOODSH G(nolock)
      where G.GID = @gdgid
      --2005.11.29 Added by ShenMin, Q5601, 各店商品表配货属性要用属性控制是否启用
      exec GetGdValue @client, @gdgid, 'ALCQTY', @alcqty OUTPUT
    end
    else
      select @vdr = BILLTO, @taxrate = TAXRATE, @alcqty = ALCQTY, @sale = SALE, @qpc = QPC
      from GOODSH(nolock)
      where GID = @gdgid

    /* 99-12-9 */
    if not exists (select * from vdrgd(nolock) where gdgid = @gdgid and vdrgid = @vdr and wrh = @wrh)
      insert into vdrgd (gdgid, vdrgid, wrh) values (@gdgid, @vdr, @wrh)

    /* 2000-4-10 */
    select @ordqty = null
    if @ordnum is not null
    begin
      select @ordqty = QTY - ASNQTY
      from orddtl(nolock)
      where NUM = @ordnum and GDGID = @gdgid
    end
    if @ordqty is null select @ordqty = 0

    /* 2000-05-16 增加未提数动作放到出库之前, 以防止库存记录被删除 */
    /* 99-7-26: 改写条件 */
    /* 99-10-22: 使用@gendsp */


    /* 要把库存操作放在第一步 */
    /* 99-12-7: 缺货处理 */

    /* 不允许负库存的情况 */
    if (select ALLOWNEG from warehouse where gid = @wrh) <> 1
    begin
      /* 不允许负库存: 取库存数据,计算缺货比,按照缺货比处理, 当缺货比为<=0,则表示不缺货 */
      select @invqty = sum(AVLQTY), @invtotal = sum(TOTAL)
      from V_ALCINV(nolock)
      where WRH = @wrh and GDGID = @gdgid and STORE = @store

      /* 2000-1-22: INV中没有该记录,则认为库存值是0 */
      set @invqty = isnull(@invqty, 0)
      set @invtotal = isnull(@invtotal, 0)

      /*2005-8-22*/
      if @genbill = 'rtl'
        update stkoutdtl set invqty = @invqty
          where CLS = @cls and NUM = @num and LINE = @line

      /*2001-1-12 可供库存应该按配货单位数的整数倍计算.
        当=0时, 使缺货比=101(超出最大的完全缺货比), 避免出现配货数=0的记录*/
      if (@gftflag = 0) and (@opt_CanAlcQtyLmt = 1)
        set @invqty_canuse = floor(@invqty / @alcqty) * @alcqty
      else
        set @invqty_canuse = @invqty

      /* 计算缺货比
         没有可用库存需要分情况处理,有则计算缺货比
         @opt_AlcQtyLmt, @opt_CanAlcQtyLmt
      */
      if @invqty_canuse = 0
      begin
        if @opt_AlcQtyLmt = 0 set @lackratio = 101
        else
        begin
          /* 真实库存为0,只能作缺货处理,否则会变成负库存
             真实库存不为0,计算缺货比 */
          if @invqty = 0
            set @lackratio = 101
          else
            set @lackratio = (@qty - @invqty) / @qty * 100
        end
      end
      else
        select @lackratio = (@qty - @invqty_canuse) / @qty * 100

      /* 2000-2-23: @qty < 0, 则使@lackratio = -1,以便正常处理*/
      if @qty < 0 select @lackratio = -1

      /* 按缺货比进行处理 */
      if @lackratio <= 0
      begin
        /* 没有缺货,按需求量供给,继续正常处理 */
        /* 00-4-10 */
        if @gftflag = 0  --主商品
        begin
          if @opt_CanAlcQtyLmt = 1  --配货单位
          begin
            /* 根据配货单位更新主商品数量*/
            set @diff = @qty
            if not ((@opt_AlcQtyLmt = 1) and (@qty < @alcqty))
              set @qty = floor(@qty / @alcqty) * @alcqty
            if @diff <> @qty
            begin
              update stkoutdtl set qty = @qty, total = round(@qty * price, 2)
              where cls = @cls and num = @num and gdgid = @gdgid and gftflag <> 1

              set @diff = @diff - @qty
              set @difftotal = @diff * @price
              if @diff > 0
              begin
                set @ckinvM  = @ckinv & 6 --只记缺货待配和配货池
                execute @return_status = StkOutChkRegLack
                  @ckinvM,
                  @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, 0,
                  @wrh, @invqty, @invtotal, 0, 0, @diff, @difftotal,
                  @cls, @num, @store, @cur_settleno, @client, @slr, @filler,
                  @ordnum,
                  @outnum output
              end
            end

            /*主商品因为配货单位而被清空的情况*/
            if @qty = 0
            begin
              if @opt_DelFlag = 1
                delete from stkoutdtl where cls = @cls and num = @num and gdgid = @gdgid and gftflag <> 1
            end
          end
        end

        /* 2001-09-29 同时删除以前标记为'缺货待配'的,配往同一门店，同一仓位未审核配货出货单明细中
        的商品，并更新出货单汇总 */
        if ((@cls='配货') or (@cls = '批发')) and (isnull(@GFTID, 0) <> -1)  --2002-04-01 By Wang Xin
        begin
          if @delnum is not null and @delnum <> @num
          begin
            select @delline = line from stkoutdtl(nolock)
            where cls = @cls and num = @delnum and gdgid = @gdgid
            if @delline is not null
            begin
              select @deltotal = total, @deltax = tax from stkoutdtl(nolock)
              where  cls = @cls and num = @delnum and line = @delline

              delete from stkoutdtl
              where  cls = @cls and num = @delnum and line = @delline

              update stkout set reccnt = reccnt - 1, total = total- @deltotal, tax = tax- @deltax
              where cls = @cls and num = @delnum
            end
          end
        end
        if @return_status <> 0
        begin
          close c_stkout
          deallocate c_stkout
          return 10
        end
      end
      else if (@ckinv = 0)  and (@qty > @invqty or @lackratio = 101 or @lackratio > @bvalt) /*2003.02.21*/
      begin
        /* 库存不足,不能继续 */
        select @msg =
          '不允许负库存的仓位' + (select code from warehouse where gid = @wrh)
          + '中商品' + (select CODE from GOODSH(nolock) where GID = @gdgid)
          + '的库存量不足(需求=' + ltrim(convert(char,@qty))
          + ', 库存=' + ltrim(convert(char, @invqty)) + ')'
        select @return_status = 1001
        --raiserror(@msg, 16, 1)
        set @poMsg = @msg
        close c_stkout --ShenMin
        deallocate c_stkout --ShenMin
        return 10
      end
      else if @lackratio <= @bvalt
      begin
        /*按库存量供给(配货单位的整数倍),修改出货单后继续处理
          计算缺货数,如果不按配货单位取整则取库存数
          如果是赠品,缺货数用实际库存数来算*/
        set @lack = @qty - @invqty

        if (@opt_AlcQtyLmt = 1 and floor(@invqty / @alcqty) = 0) or (@gftflag = 1)
          set @lackqty = @qty - @invqty
        else
          set @lackqty = @qty - @invqty_canuse

        set @qty = @qty - @lackqty

        --set @diff = @qty
        /*按配货单位取整*/
        --if (@opt_CanAlcQtyLmt = 1) and (@gftflag = 0)
          --set @qty = floor(@qty / @alcqty) * @alcqty

        select @lacktotal = @total - round(@qty * @price, 2)
        select @total = @total - @lacktotal
        select @lacktax = @tax - (@total - round(@total/(1+@taxrate/100), 2))
        select @tax = @tax - @lacktax

        update stkoutdtl set qty = @qty, total = @total, tax = @tax,
          /* 2001-1-12*/ cases = @qty / @qpc
        where CLS = @cls and NUM = @num and LINE = @line

        if @ckinv <> 0  /*2003.02.21*/
        begin
          /* 00-4-10 */
          --set @lackqty = @lackqty + @diff
          set @lacktotal = @lackqty * @price
          set @ckinvM = @ckinv & 6
          execute @return_status = StkOutChkRegLack
            @ckinvM,
            @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, @gftflag,
            @wrh, @invqty, @invtotal, @qty, @total, @lackqty, @lacktotal,
            @cls, @num, @store, @cur_settleno, @client, @slr, @filler,
            @ordnum,
            @outnum output, 1 /*缺货待配累加*/
          set @ckinvM = @ckinv & 1
          set @difftotal = @lack * @price
          execute @return_status = StkOutChkRegLack
            @ckinvM,
            @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, @gftflag,
            @wrh, @invqty, @invtotal, @qty, @total, @lack, @difftotal,
            @cls, @num, @store, @cur_settleno, @client, @slr, @filler,
            @ordnum,
            @outnum output
        end
      end else
      begin
        /* 从出货单中删除,记缺货列表和/或缺货单,不再处理该记录 */
        delete from STKOUTDTL where CLS = @cls and NUM = @num and LINE = @line

        select @lackqty = @qty
        select @qty = @qty - @lackqty
        select @lacktotal = @total
        select @total = @total - @lacktotal
        select @lacktax = @tax
        select @tax = @tax - @lacktax

        /* 00-4-10 */
        execute @return_status = StkOutChkRegLack
          @ckinv,
          @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, @gftflag,
          @wrh, @invqty, @invtotal, @qty, @total, @lackqty, @lacktotal,
          @cls, @num, @store, @cur_settleno, @client, @slr, @filler,
          @ordnum,
          @outnum output, 1 /*缺货待配累加*/
        goto NextLoop
      end
    end

    NextLoop:
    fetch next from c_stkout into
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @wsprc, @gftflag, @GFTID, @srcaganum
  end
  close c_stkout
  deallocate c_stkout

  if @opt_DelFlag = 1
    delete from stkoutdtl where cls = @cls and num = @num and qty = 0
  declare c_Procalcgft1 cursor for
  select gdgid, line
  from stkoutdtl(nolock)
  where cls = @cls and num = @num order by line --and gftline is not null
  set @line = 0
  update stkoutdtl set line = line + 10
  where cls = @cls and num = @num
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @gdgid, @lineno
  while @@fetch_status = 0
  begin
    set @line = @line + 1
    update stkoutdtl set line = @line
      where cls = @cls and num = @num and gdgid = @gdgid and line = @lineno
    fetch next from c_Procalcgft1 into @gdgid, @lineno
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1

  /*更新stkout合计值*/
  declare @vTotal money, @vTax money
  select @vTotal = ISNULL(sum(total), 0), @vTax = ISNULL(sum(tax), 0) from stkoutdtl(nolock)
   where cls = @cls and num = @num
  update stkout set
    RECCNT = @line,
    total = @vTotal,
    tax = @vTax
  where cls = @cls and num = @num

  /* 更新明细箱数 */
  update stkoutdtl set cases = qty / g.qpc from goodsh g(nolock) where cls = @cls and num = @num and g.gid = gdgid

  if @line = 0
    update stkout set
      note = rtrim(note) + '[按照业务规则本单据明细被删除]'
    where cls = @cls and num = @num

  /*更新计划配货数*/
  if @cls = '配货'
    update stkoutdtl set ALLOCQTY = qty where cls = @cls and num = @num

  /*增加预配数*/
  declare @Opqty money, @m_store int
  select @m_store = usergid from system
  select @wrh = WRH from STKOUT(nolock) where CLS = @cls and NUM = @num
  declare c_Procalcgft1 cursor for
  select gdgid, qty, line
  from stkoutdtl(nolock)
  where cls = @cls and num = @num order by line
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @gdgid, @qty, @lineno
  while @@fetch_status = 0
  begin
    exec @return_status = IncRsvAlcQty @piStore = @m_store, @piWrh = @wrh, @piGdgid = @gdgid, @piQty = @qty, @piMode = -1, @poOpqty = @Opqty output --zhangzhen 20071114
    if @return_status <> 0
    begin
      close c_Procalcgft1
      deallocate c_Procalcgft1
      return @return_status
    end
    update stkoutdtl set RSVALCQTY = ISNULL(RSVALCQTY, 0) + @Opqty
      where cls = @cls and num = @num and gdgid = @gdgid and line = @lineno
    fetch next from c_Procalcgft1 into @gdgid, @qty, @lineno
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1

  if @return_status <> 0 return @return_status

  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 15, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
