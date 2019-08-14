SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKCHKCHKex](
  @cls char(10),
  @num char(10),
  @VStat smallint = 6,   /* add By jinlei 2005.5.18*/
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
    @vDXGDUseSrcCostPrc int,              @gdcode varchar(13), @optvalue_Chk int
  if @cls <> '批发'
  begin
    set @poMsg = '只有批发退货才有复核动作'
    return 1
  end
  declare @opt_UseLeagueStore int
  exec optreadint 0, 'useleaguestore', 0, @opt_useLeagueStore output

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)
  exec @return_status = WMSSTKOUTBCKCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 6, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg output
  if @return_status <> 0 return -1

  exec OPTREADINT 69, 'ChkStatDwFunds', 0, @optvalue_Chk output /*add by jinlei 3692*/
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

  if @stat <> 1 and @VStat = 6 begin
    set @poMsg = '复核的不是已审核的单据'
    return(1)
  end
  select @cur_settleno = max(NO) from MONTHSETTLE
  update STKOUTBCK set STAT = @VStat, ReCheckDate = GETDATE(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num

  select @OptionValue1 = OptionValue from HDOption
    where  moduleNo = 403  and OptionCaption = 'SaleBckCostPrc'  /*2003.07.23*/
  exec optreadint 69, '代销商品成本价取值方式', 0, @vDXGDUseSrcCostPrc output /*2004.11.10 1259 批发退货是否代销商品成本调整*/
  declare c_stkout cursor for
    select GDGID, QTY, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, LINE, SUBWRH, PRICE, ITEMNO
    from STKOUTBCKDTL where CLS = @cls and NUM = @num
    for update
  open c_stkout
  fetch next from c_stkout into
    @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @itemno
  while @@fetch_status = 0 begin
    select @whsprc = WHSPRC, @vdr = BILLTO, @gdcode = code,
      @sale = SALE, @payrate = PAYRATE,
      @lstinprc = LSTINPRC
      from GOODSH where GID = @gdgid

    if @sale = 1/*2003-06-13*/
    execute @return_status = STKOUTBCKDTLCHKCRT
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @billto, @slr, @wrh,
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr, @VStat, 2, @d_cost /*2002-06-13*/
    else
    execute @return_status = STKOUTBCKDTLCHKCRT
      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,
      @billto, @slr, @wrh,
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr, @VStat, 2, null
    if @return_status <> 0 break

    select @d_qty = -@qty, @d_total = -@total  /*2002-01-04*/
    if @paymode <> '应收款'
      and ((@CLS = '批发' and @VStat = 6 and @optvalue_Chk = 1)
        or (@CLS = '批发' and @VStat = 1 and @optvalue_chk = 0) or (@CLS <> '批发')) begin
      execute @return_status = RCPDTLCHK
        @cur_date, @cur_settleno, @client, @gdgid, @wrh, @d_qty,
        @d_total, @inprc, @rtlprc
    end
    fetch next from c_stkout into
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh, @line, @subwrh, @price, @itemno
  end
  close c_stkout
  deallocate c_stkout
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
      set @poMsg = @errmsg
      return(3)
    end
  end
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

  exec @return_status = WMSSTKOUTBCKCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 6, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
