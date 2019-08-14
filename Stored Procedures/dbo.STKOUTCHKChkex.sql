SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTCHKChkex](
  @cls char(10),
  @num char(10),
  @VStat smallint = 6,
  @ChkFlag smallint = 0,  /*调用标志，1表示WMS调用，缺省为0*/
  @poMsg varchar(255) = null output
) as
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

    --通用变量
    @return_status int,
    @cur_settleno int,
    @store int,
    @ret1 int, @ret2 int,
    @msg1 varchar(100), @msg2 varchar(100),
    @gendsp smallint,              /* 生成提货单 */
    @isbianli bit,
    @outinprcmode int,

    --Option部分
    @opt_ChkWriteToOrd int,        /* 2005.1.13 Edited By Jin Q3403 */
    @opt_CanAlcQtyLmt int,
    @opt_RCPCST char(1),
    @opt_wsale int,                /* 2003.01.10 */
    @opt_FrcAlcOutPrc int,         /* 2002-06-14 */
    @opt_UseAlcGft int,
    @opt_AlcGftQtyMatch int,
    @opt_UseLeaguestore int,
    @optvalue_Chk int,
    @optvalue_wsale int
  DECLARE @AMT MONEY,@COST MONEY /*2003.01.27 HXS*/


  exec OPTREADINT 65, 'ChkStatDwFunds', 0, @optvalue_Chk output
  if @cls <> '批发' or @optvalue_Chk <> 1 or @VStat <> 6
  begin
    set @poMsg = '非复核批发单不能调用此接口'
    return(1)
  end

  if (select isnull(LogAcnt, 0) from stkout where cls = @cls and num = @num) = 1
  begin
    set @poMsg = '已经记录帐款的已审核单据不能复核'
    return(1)
  end

  declare @Oper char(30)
  set @Oper = Convert(Char(1), @ChkFlag)

  exec @return_status = WMSSTKOUTCHKFILTER @piCls = @Cls, @piNum = @Num, @piToStat = 6, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = @poMsg OUTPUT
  if @return_status <> 0 return -1

  select @return_status = 0
  select @cur_settleno = max(NO) from MONTHSETTLE
  select @store = usergid from system
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
    @destgid = CLIENT,/*2002.10.11*/
    @billtogid = BILLTO/*2002.10.11*/
    from STKOUT(nolock) where CLS = @cls and NUM = @num

  select @isbianli = 0

  if exists (select 1 from warehouse(nolock) where gid = @client)
	select @isbianli = 1
  if @stat <> 1 and @VStat = 6 begin
    set @poMsg = '复核的不是已审核的单据'
    return(1)
  end
  update STKOUT set STAT = 6, ReCheckDate = getdate(), SETTLENO = @cur_settleno
    where CLS = @cls and NUM = @num
  exec OPTREADINT 0, 'WHOLESALEUSECSTGD', 0, @optvalue_wsale output

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
    if (@cls = '批发') and (@optvalue_wsale = 1)
    	and exists(select 1 from CSTGD(nolock) where cstgid = @client and gdgid = @gdgid)	/*2003.02.14 by zyb*/
   	select
    		@whsprc = WHSPRC,
    		@payrate = PAYRATE,
        	@vdr = BILLTO,
        	@taxrate = TAXRATE,
        	@alcqty = ISNULL(CSTGD.ALCQTY, GOODSH.ALCQTY),
        	@sale = GOODSH.SALE,
        	@qpc = QPC
    	from GOODSH(nolock), CSTGD(nolock)
    	where GID = @gdgid
    		and CSTGD.GDGID = GID
    		and CSTGD.CSTGID = @client

 --2005.7.25, Added by ShenMin, Q4527, 增加各店商品表的配货单位
    else  if (@cls = '配货')
      begin
   	select
    		@payrate = G.PAYRATE,
        	@vdr = G.BILLTO,
        	@taxrate = G.TAXRATE,
        	--@alcqty = ISNULL(S.ALCQTY, G.ALCQTY),
        	@sale = G.SALE,
        	@qpc = G.QPC
    	from GDSTORE S(NOLOCK), GOODSH G(nolock)
    	where G.GID = @gdgid
    	  AND S.GDGID =* G.GID
    	  AND S.STOREGID = @client
    --2005.11.29 Added by ShenMin, Q5601, 各店商品表配货属性要用属性控制是否启用
        exec GetGdValue @client, @gdgid,  'ALCQTY', @alcqty OUTPUT
      end
    else
    	select
    		@payrate = PAYRATE,
        	@vdr = BILLTO,
        	@taxrate = TAXRATE,
        	@alcqty = ALCQTY,
        	@sale = SALE,
        	@qpc = QPC
    	from GOODSH(nolock) where GID = @gdgid

    IF (SELECT BATCHFLAG FROM SYSTEM) = 2 BEGIN
        SELECT @COST = 0
        SELECT @COST = COST FROM STKOUTDTL(nolock) WHERE CLS = @CLS AND NUM = @NUM AND LINE = @LINE

        SELECT @AMT = @TOTAL - @TAX
  /*Edit By Liujunping 2005.4.5*/
        IF (@CLS = '批发') and (@VStat = 6) and (@optvalue_Chk = 1) BEGIN
                INSERT INTO XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
                WC_Q, WC_A, WC_T, WC_I, WC_R, ACNT)
                VALUES (@CUR_DATE, @CUR_SETTLENO, @WRH, @GDGID, @CLIENT, @SLR, @VDR,
                @QTY, @AMT, @TAX, @COST, @QTY * @RTLPRC, 2)  --只记录账款报表
        END
    END
    ELSE
    BEGIN
	    execute @return_status = STKOUTDTLCHKCRT
	      @cls, @cur_date, @cur_settleno, @cur_date, @cur_settleno,
	      @client, @slr, @wrh, @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @vdr,
	      null, @VStat, 2
	    if @return_status <> 0
	    begin
	      close c_stkout
                      deallocate c_stkout
	      return 10
	    end
    END

    if @paymode <> '应收款'
      and ((@CLS = '批发' and @VStat = 6 and @optvalue_Chk = 1)
        or (@CLS = '批发' and @VStat = 1 and @optvalue_Chk = 0)
        or (@CLS <> '批发')) begin
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
      @gdgid, @qty, @total, @tax, @inprc, @rtlprc, @validdate, @wrh,
      @line, @subwrh, @price, @wsprc, @gftflag
  end
  close c_stkout
  deallocate c_stkout
  if @paymode <> '应收款' and ((@CLS = '批发' and @VStat = 6 and @optvalue_Chk = 1) or (@CLS = '批发' and @VStat = 1 and @optvalue_Chk = 0) or (@CLS <> '批发'))
  begin            /*此时，这张批发单的结算状态应该是已结清 2001-10-29*/
    if @cls = '批发' and (select finished from stkout(nolock) where num = @num and cls = @cls )<>1
    begin
      update stkout set finished = 1 where num = @num and cls = @cls
      update stkoutdtl set rcpqty = qty,rcpamt = total where num = @num and cls = @cls
    end
  end

  if not(@cls = '批发' and @VStat = 1 and @optvalue_Chk = 1)
  begin
    -- sz add
    EXEC @return_status = STKOUTBEFORECHK @num, @cls, @poMsg output
    if @return_status <> 0
    begin
      --raiserror(@msg, 16, 1)
      return(3)
    end
  end

  --add by cyb 2002.08.01
  if (@cls = '批发' and @VStat = 6 and @optvalue_Chk = 1)
  or (@cls = '批发' and @VStat = 1 and @optvalue_Chk = 0) or (@cls <> '批发')
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

  if @return_status <> 0 return @return_status

  /* 更新已记录帐款标志 */
  update stkout set LogAcnt = 1 where num = @num and cls = @cls

  exec @return_status = WMSSTKOUTCHKFILTERBCK @piCls = @Cls, @piNum = @Num, @piToStat = 6, @piOper = @Oper, @piTag = 0, @piAct = null, @poMsg = null
  return 0
end
GO
