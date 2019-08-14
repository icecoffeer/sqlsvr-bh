SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SaleBckChk]
  @num char(10),
  @new_stat smallint
as
begin
/*
99-7-22 记报表: 根据SALEBCK所对应的DSP所对应的单据区分零售退货和批发/配出退货.
        如果DSP没有对应单据,认为是零售退货
2000-3-1 除STKOUT生成的DSP退货外,写XS时使用PARAM=0,
         按CSTGID=1,每天每个商品记录OUTXRPT,VDRXRPT,不记录CSTXRPT
         PARAM的含义详见EXS_INS.SQL
2000-05-13
  if @sale = 3 select @inprc = @total / @qty * @payrate / 100 
2000-8-17
  提单退货不改变货位库存-HLJD不使用, ZHZH使用
*/
  declare
    @settleno int,         @fildate datetime,         @wrh int,
    @stat smallint,        @statdiff smallint,        @gdgid int,
    @qty money,            @price money,              @vdrgid int,
    @line int,             @dspline int,              @total money,
    @dspnum char(10),      @inprc money,              @rtlprc money,
    @cls char(10),         @subwrh int,               @dspqty money,
    @dsp_cls char(10),     @dsp_posnocls char(10),    @dsp_flowno char(10),
    @stkout_billto int,    @stkout_slr int,           @saletax money,
    @tax money,            @dsptotal money,           @sale smallint,
    @payrate money
  select
    @settleno = SETTLENO,
    @fildate = convert( datetime, convert(char, FILDATE, 102) ),
    @wrh = WRH,
    @stat = STAT,
    @dspnum = DSPNUM,
    @cls = CLS
    from SALEBCK where NUM = @num
  select @dsp_cls = CLS, @dsp_posnocls = POSNOCLS, @dsp_flowno = FLOWNO
    from DSP where NUM = @dspnum
  select @dsp_cls = isnull(@dsp_cls, 'BUY1'),
         @dsp_posnocls = isnull(@dsp_posnocls, '-')
  select @stkout_billto = BILLTO, @stkout_slr = SLR
    from STKOUT where CLS = @dsp_posnocls and NUM = @dsp_flowno
  select @stkout_billto = isnull(@stkout_billto, 1),
         @stkout_slr = isnull(@stkout_slr, 1)
  /*
    单据状态: 0=未生效,1=已收货,2=已付款,3=已完成
    可能的变迁: 0->1, 0->2, 0->3, 1->3, 2->3
    if @cls = '提单退货' 不需要判断请求本次操作的前后状态,总是0->3
    else in ('实物退货', '仓库退货'), 需要判断请求本次操作的前后状态
  */
  if ((@stat ^ @new_stat) & @new_stat) <> (@stat ^ @new_stat)
  /* 有变化的在新状态中必为1 */
  begin
    raiserror( '状态变化错误.', 16, 1 )
    return 1
  end
  update SALEBCK set STAT = @new_stat where NUM = @num
  select @statdiff = @new_stat & (~@stat)
  declare c_salebckdtl cursor for
    select LINE, DSPLINE, GDGID, QTY, PRICE, TOTAL, SUBWRH
    from SALEBCKDTL
    where NUM = @num
  open c_salebckdtl
  fetch next from c_salebckdtl into
    @line, @dspline, @gdgid, @qty, @price, @total, @subwrh
  while @@fetch_status = 0
  begin
    /* 从商品总表中取得必要数据 */
    select @inprc = INPRC, @rtlprc = RTLPRC,
      @vdrgid = BILLTO, @saletax = isnull(SALETAX, 0),
      /* 2000-05-13 */  @sale = SALE, @payrate = PAYRATE
      from GOODSH where GID = @gdgid
      
    /* 2000-05-13 */
    if @sale = 3 select @inprc = @total / @qty * @payrate / 100 
    
    /* 修改单据的INPRC和RTLPRC */
    update SALEBCKDTL set INPRC = @inprc, RTLPRC = @rtlprc
      where NUM = @num and LINE = @line
    if @cls = '提单退货'
    begin
      /* 减未提数 */
      execute DecDspQty @wrh, @gdgid, @qty, /*00-3-3*/@subwrh
      /* 加可用数 */
      execute Loadin @wrh, @gdgid, @qty, @price, null
      /* 2000-8-17
      对于“提单退货”，应：(+)仓位可用库存，(-)仓位未提库存；
      而对于“实物退货”或“仓库退货”，应：(+)仓位可用库存，(+)货位可用库存。
      因此当“提单退货”的时候，不应对货位库存进行任何操作。但在程序line92中：
      if @subwrh is not null execute LoadinSubWrh @wrh, @subwrh, @gdgid, @qty
      按照上面描述的，这句话应去掉。
      */
      /*if @subwrh is not null execute LoadinSubWrh @wrh, @subwrh, @gdgid, @qty*/

      /* 记报表: 根据DSP所对应的单据区分零售退货和批发/配出退货.
      如果没有对应单据,认为是零售退货 */
      select @tax = @total * @saletax / (100 + @saletax)
      if @dsp_cls = 'STKOUT'
      begin
        execute STKOUTBCKDTLCHKCRT
          @dsp_posnocls, @fildate, @settleno, @fildate, @settleno,
          @stkout_billto, @stkout_slr, @wrh,
          @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdrgid, 1, 0 /*add by jinlei 3692*/
          /*如果dsp_posnocls不是批发/配货/调出,STKOUTBCKDTLCHKCRT不记任何报表*/
      end
      else /* if @dsp_cls = 'BUY1' or something else */
      begin
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
          BVDRGID, BCSTGID,
          LST_Q, LST_A, LST_T, LST_I, LST_R, /*2000-3-1*/PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @dsp_posnocls, 1,
          @vdrgid, 1,
          @qty, @total-@tax, @tax, @qty * @inprc, @qty * @rtlprc, /*2000-3-1*/0)
      end

      /* 回写提单:已提数, 已提金额 */
      update DSPDTL set DSPQTY = isnull(DSPQTY, 0) + @qty,
                        DSPTOTAL = isnull(DSPTOTAL, 0) + @total
        where NUM = @DSPNUM and LINE = @dspline
    end
    else if (@cls = '实物退货') or (@cls = '仓库退货')
    begin
      if @statdiff & 1 <> 0
      begin
        /* 加退货收货数 */
        execute IncBckQty @wrh, @gdgid, @qty, /*00-3-3*/@subwrh
        /*00-3-3
	    if @subwrh is not null execute LoadinSubWrh @wrh, @subwrh, @gdgid, @qty */
      end
      if @statdiff & 2 <> 0
      begin
        /* 减退货收货数 */
        execute DecBckQty @wrh, @gdgid, @qty, /*00-3-3*/@subwrh
        /* 加可用数 */
        execute Loadin @wrh, @gdgid, @qty, @price, null
        /*00-3-3*/
	    if @subwrh is not null execute LoadinSubWrh @wrh, @subwrh, @gdgid, @qty

        /* 记报表: 根据DSP所对应的单据区分零售退货和批发/配出退货.
        如果没有对应单据,认为是零售退货 */
        select @tax = @total * @saletax / (100 + @saletax)
        if @dsp_cls = 'STKOUT'
        begin
          execute STKOUTBCKDTLCHKCRT
            @dsp_posnocls, @fildate, @settleno, @fildate, @settleno,
            @stkout_billto, @stkout_slr, @wrh,
            @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdrgid, 1, 0 /*add by jinlei 3692*/
            /*如果dsp_posnocls不是批发/配货/调出,STKOUTBCKDTLCHKCRT不记任何报表*/
        end
        else /* if @dsp_cls = 'BUY1' or something else */
        begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
            BVDRGID, BCSTGID,
            LST_Q, LST_A, LST_T, LST_I, LST_R, /*2000-3-1*/ PARAM)
            values (@settleno, @fildate, @wrh, @gdgid, @dsp_posnocls, 1,
            @vdrgid, 1,
            @qty, @total-@tax, @tax, @qty * @inprc, @qty * @rtlprc, /*2000-3-1*/0)
        end

      end
    end
    else /*提单金额, 实物金额*/
    begin
      if @new_stat <> 3
	  begin
	    raiserror( '金额退货状态错误.', 16, 1 )
		return 1
      end
      /* 记报表: 根据DSP所对应的单据区分零售退货和批发/配出退货.
      如果没有对应单据,认为是零售退货 */
      select @tax = @total * @saletax / (100 + @saletax)
      if @dsp_cls = 'STKOUT'
      begin
           execute STKOUTBCKDTLCHKCRT
           @dsp_posnocls, @fildate, @settleno, @fildate, @settleno,
           @stkout_billto, @stkout_slr, @wrh,
           @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdrgid, 1, 0 /*add by jinlei 3692*/
           /*如果dsp_posnocls不是批发/配货/调出,STKOUTBCKDTLCHKCRT不记任何报表*/
      end
      else /* if @dsp_cls = 'BUY1' or something else */
      begin
           insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
                           BVDRGID, BCSTGID,
                           LST_Q, LST_A, LST_T, LST_I, LST_R, /*2000-3-1*/PARAM)
           values (@settleno, @fildate, @wrh, @gdgid, @dsp_posnocls, 1,
                   @vdrgid, 1,
                   @qty, @total-@tax, @tax, @qty * @inprc, @qty * @rtlprc, /*2000-3-1*/0)
      end
      /* 回写提单:已提金额 */
      if @cls = '提单金额'
           update DSPDTL set DSPTOTAL = isnull(DSPTOTAL, 0) + @TOTAL
           where NUM = @DSPNUM and LINE = @dspline
    end

    /* 回写提单:不论收货或付款,由先做的动作回写提单,以后的不写 */
    if @stat = 0
    begin
      update DSPDTL set BCKQTY = isnull(BCKQTY, 0) + @qty,
		BCKTOTAL = isnull(BCKTOTAL, 0) + @total
        where NUM = @DSPNUM and LINE = @dspline
    end
nextloop:
    fetch next from c_salebckdtl into @line, @dspline, @gdgid, @qty, @price, @total, @subwrh
  end /* of detail */
loopend:
  close c_salebckdtl
  deallocate c_salebckdtl

  select @qty = sum(SALEQTY), @dspqty = sum(DSPQTY),
		@dsptotal = sum(DSPTOTAL)
  from DSPDTL
  where NUM = @DSPNUM

  if @dspqty <> 0
  begin
	if @qty > @dspqty
		update DSP set STAT = 1 where NUM = @DSPNUM
	else if @qty = @dspqty
		update DSP set STAT = 2 where NUM = @DSPNUM
  end
  else if @dsptotal <> 0
  begin
    update DSP set STAT = 1 where NUM = @DSPNUM and STAT = 0
  end
end
GO
