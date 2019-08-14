SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTDLTNUM](
  @old_cls char(10),
  @old_num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
) with encryption as
begin
  declare
    @return_status int,       @vdr int,
    @old_settleno int,        @old_client int,          @old_ocrdate datetime,
    @old_total money,         @old_tax money,           @old_wrh int,
    @old_fildate datetime,    @old_stat smallint,       @old_slr int,
    @old_reccnt int,          @old_billto int,          @old_gdgid int,
    @old_qty money,           @oldd_total money,        @oldd_tax money,
    @old_inprc money,         @old_rtlprc money,        @old_validdate datetime,
    @old_src int,             @cur_date datetime,       @cur_settleno int,
    @cur_inprc money,         @cur_rtlprc money,        @ordnum char(10),
    @paymode char(10),        @temp_qty money,          @temp_total money,
    @temp_tax money,          @money1 money,            @old_subwrh int,
    @old_gen int,        @dsp_num char(10),        @dsp_stat smallint,
    @gendsp smallint,
    /* 2000-2-21
    @DSPMODE SMALLINT,     @BUYERNAME VARCHAR(50),   @TEL VARCHAR(40),
    @ADDR VARCHAR(100),    @NEARBY VARCHAR(50),      @DSPDATE DATETIME */
    @isbianli bit/*2002-02-04*/,
    @old_outcost money, @temp_outcost money /*2002-06-13*/,
    @sale smallint,/*2003-06-13*/
    @vCount Int
  declare @optvalue_Chk int

  exec OPTREADINT 65, 'ChkStatDwFunds', 0, @optvalue_Chk output /*add by jinlei 3692*/
  if @old_cls <> '批发'
    set @optvalue_Chk = 0
  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char,getdate(),102)),
    @cur_settleno = max(NO)
    from MONTHSETTLE
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
    @old_gen = GEN,
    @ordnum = ORDNUM,
    @paymode = PAYMODE
    from STKOUT(nolock) where CLS = @old_cls and NUM = @old_num

  /*2002-02-04*/
  select @isbianli = 0
  if exists (select 1 from warehouse(nolock) where gid = @old_client)
	select @isbianli = 1

  if @old_stat <> 1 begin
    set @errmsg = '删除的不是已审核的单据'
    return(1)
  end

  /* 00-3-30 */
  execute @return_status = CanDeleteBill 'STKOUT', @old_cls, @old_num, @errmsg output
  if @return_status != 0 begin
    --raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  /* 99-7-26: 限制冲单或做提单作废 */
  /* 99-10-22: 使用@gendsp变量表示提单是否已生成*/
  /* 99-11-13: (stkout.gen is not null) instead of (stkout.gen = 1) */
  /* 2000-1-8 李希明: SYSTEM.DSP按位控制是否生成提货单*/
  select @gendsp = 0
/*  if (@cls = '批发') and ((select dsp from system) = 1)
  or (@cls = '配货') and (@gen is not null)
     select @gendsp = 1 */
  if (@old_cls = '批发' and (select DSP from SYSTEM) & 1 <> 0)
    or (@old_cls = '配货' and (select DSP from SYSTEM) & 2 <> 0)
    or (@old_cls = '调出' and (select DSP from SYSTEM) & 4 <> 0)
    select @gendsp = 1

  if @gendsp = 1
  begin
    SELECT @dsp_num = NUM, @dsp_stat = STAT
    FROM DSP WHERE CLS = 'STKOUT' AND POSNOCLS = @old_cls AND FLOWNO = @old_num
    if @dsp_stat <> 0
    begin
      select @return_status = 2
      set @errmsg =  '该单据已被提货,不能冲单.'
      return
    end
    execute @return_status = DSPABORT @dsp_num
    if @return_status <> 0
    begin
      select @return_status = 3
      set @errmsg =  '不能作废相关的提单.'
      return
    end
  end

  update STKOUT set STAT = 2 where CLS = @old_cls and NUM = @old_num

  insert into STKOUT (CLS, NUM, SETTLENO, CLIENT, OCRDATE, TOTAL,
    TAX, WRH, FILDATE, FILLER, CHECKER, STAT, MODNUM, SLR, RECCNT, SRC, ORDNUM,
    BILLTO, PAYMODE)
    values (@old_cls, @neg_num, @cur_settleno, @old_client,
    @old_ocrdate, -@old_total, -@old_tax, @old_wrh, getdate(),
    @new_oper, @new_oper, 4, @old_num, @old_slr, @old_reccnt, @old_src, @ordnum,
    @old_billto, @paymode)
  insert into STKOUTDTL (CLS, NUM, LINE, SETTLENO, GDGID, QTY, WSPRC,
    PRICE, TOTAL, TAX, INPRC, RTLPRC, VALIDDATE, WRH, SUBWRH, RCPQTY, RCPAMT,
    COST, RSVALCQTY, FIRSTQTY, ALLOCQTY) /*2002-06-13*/
    select CLS, @neg_num, LINE, @cur_settleno, GDGID, -QTY, WSPRC,
    PRICE, -TOTAL, -TAX, INPRC, RTLPRC, VALIDDATE, STKOUTDTL.WRH, SUBWRH, 0, 0,
    -COST, -ISNULL(RSVALCQTY, 0), -FIRSTQTY, -ALLOCQTY /*2002-06-13*/
    from STKOUTDTL(nolock)
    where CLS = @old_cls and NUM = @old_num

  EXEC @return_status = STKOUTBEFORECHK @neg_num, @old_cls, @errmsg output
  if @return_status <> 0
  begin
    --raiserror(@errmsg, 16, 1)
		return(3)
  end

  declare c_stkout cursor for
    select GDGID, QTY, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC, SUBWRH, COST --2002-07-24
    from STKOUTDTL(nolock) where CLS = @old_cls and NUM = @old_num
  open c_stkout
  fetch next from c_stkout into
    @old_gdgid, @old_qty, @oldd_total, @oldd_tax, @old_validdate, @old_wrh,
    @old_inprc, @old_rtlprc, @old_subwrh, @old_outcost /*2002-06-13*/
  while @@fetch_status = 0 begin
    /*if @old_cls = '批发' begin  2002-06-13
      select @temp_qty = -@old_qty, @temp_total = -@old_qty * @old_inprc
      execute UPDINVPRC '销售', @old_gdgid, @temp_qty, @temp_total
    end*/
    select
      @cur_inprc = INPRC,
      @cur_rtlprc = RTLPRC,
      @vdr = BILLTO,
      @sale = SALE
      from GOODSH(nolock) where GID = @old_gdgid

    -- 2002-03-28 出货冲单处理成进货影响库存价的变化
    select @temp_qty = @old_qty, @temp_total = @old_outcost
    execute UPDINVPRC '进货', @old_gdgid, @temp_qty, @temp_total, @old_wrh /*2002.08.18*/

    execute @return_status = LOADIN
      @old_wrh, @old_gdgid, @old_qty, @cur_rtlprc, @old_validdate, /* 2000-10-24 */0
    if @return_status <> 0 break

    /* 2002-02-04 杨善平 */
   if @old_cls = '配货' and  @isbianli = 1
   begin
     execute @return_status = UNLOAD @old_billto, @old_gdgid, @old_qty, @cur_rtlprc, @old_validdate
     if @return_status <> 0 break
   end
   /******************/

    /* 99-10-22: 只有不生成提单的才改动货位库存 */
    if (@old_subwrh is not null)/* 00-3-3  and (@gendsp = 0) */
    begin
      execute @return_status = LOADINSUBWRH
        @old_wrh, @old_subwrh, @old_gdgid, @old_qty,
        /* 2000-06-12 ref 用货位实现批次管理三.doc */@old_inprc
      if @return_status <> 0 break
    end

    -- ord
    if @ordnum is not null
      update ORDDTL set ASNQTY = ASNQTY - @old_qty
      where NUM = @ordnum and GDGID = @old_gdgid

    select
      @temp_qty = -@old_qty, @temp_total = -@oldd_total, @temp_tax = -@oldd_tax,
      @temp_outcost = -@old_outcost /*2002-06-13*/
    if @sale = 1/*2003-06-13*/
    execute @return_status = STKOUTDTLCHKCRT
      @old_cls, @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_billto, @old_slr, @old_wrh,
      @old_gdgid, @temp_qty, @temp_total, @temp_tax,
      @old_inprc, @old_rtlprc, @vdr,
      @temp_outcost, 1, @optvalue_Chk /*2002-06-13*/ /*2005-05-31*/
    else
    execute @return_status = STKOUTDTLCHKCRT
      @old_cls, @cur_date, @cur_settleno, @old_fildate, @old_settleno,
      @old_billto, @old_slr, @old_wrh,
      @old_gdgid, @temp_qty, @temp_total, @temp_tax,
      @old_inprc, @old_rtlprc, @vdr, null, 1, @optvalue_Chk /*2005-05-31*/
    if @return_status <> 0 break

    /* 生成调价差异, 库存已经按照当前售价退库了 */
    /*2002-06-13 移动加权平均核算这时不应计算进价的调价差异*/
    --if @old_inprc <> @cur_inprc or @old_rtlprc <> @cur_rtlprc
    --if @old_rtlprc <> @cur_rtlprc
    /*2003-06-13 V2算法下，代联销商品仍然应该计算进价的调价差异*/
    if @old_inprc <> @cur_inprc or @old_rtlprc <> @cur_rtlprc
    begin
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @old_gdgid, @old_wrh,
    --    (@cur_inprc-@old_inprc) * @old_qty, (@cur_rtlprc-@old_rtlprc) * @old_qty)
    --    0, (@cur_rtlprc-@old_rtlprc) * @old_qty)/*2002-06-13*/
        case @sale when 1 then 0 else (@cur_inprc-@old_inprc) * @old_qty end, (@cur_rtlprc-@old_rtlprc) * @old_qty)
    end

    if @paymode <> '应收款'
      and ((@OLD_CLS = '批发' and @optvalue_chk = 0)
        or (@OLD_CLS <> '批发'))
    begin
      execute @return_status = RCPDTLDLTCRT
        @cur_date, @cur_settleno, @old_fildate, @old_settleno,
        @old_billto, @old_gdgid, @old_wrh, @old_qty, @oldd_total,
        @old_inprc, @old_rtlprc
    end
    if @return_status <> 0 break

    fetch next from c_stkout into
      @old_gdgid, @old_qty, @oldd_total, @oldd_tax, @old_validdate, @old_wrh,
      @old_inprc, @old_rtlprc, @old_subwrh, @old_outcost /*2002-06-13*/
  end
  close c_stkout
  deallocate c_stkout

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    set @errmsg = '处理单据时发生错误.'
    return (@return_status)
  end
--2005.7.20, Added by ShenMin, Q4526, 配货出货单冲单时修改信用额度
  declare
    @opt_UseLeagueStore int,
    @account1 money, @account2 money, @account3 money,
    @UseStoreAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能

  exec Optreadint 0, 'UseLeagueStore', 0, @opt_UseLeaguestore output

  if @opt_UseLeagueStore = 1 and @old_cls = '配货'
  begin
    select @account1 = total from stkout(nolock) where cls = @old_cls and num = @old_num
    select @account2 = total, @account3 = account, @UseStoreAccount = USEACCOUNT from LEAGUESTOREALCACCOUNT(nolock)--2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    where storegid = @old_billto
    if (@account3 + @account2 + @account1 < 0) and (@UseStoreAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    begin
      set @errmsg = '该单据金额为负，配货信用额与交款额不足,不能冲单'
      return(5)
    end
    else
    begin
    --ShenMin
      --update LEAGUESTOREALCACCOUNT set total = total + @account1
      --where storegid = @old_client
      set @account1 = -@account1
      execute @return_status = UPDLEAGUESTOREALCACCOUNTTOTAL @neg_num, @old_client, '配出', @account1
    end
  end

--2005.1.5, Edited by ShenMin, Q5974, 客户信用额度控制
  declare
    @opt_UseLeagueClient int,
    @UseClientAccount int  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
  exec Optreadint 0, 'UseLeagueClient', 0, @opt_UseLeagueClient output

  if @opt_UseLeagueClient = 1 and @old_cls = '批发'
  begin
    select @account1 = total from stkout(nolock) where cls = @old_cls and num = @old_num
    select @account2 = total, @account3 = account, @UseClientAccount = USEACCOUNT from LEAGUECLIENTACCOUNT(nolock) --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    where ClientGid = @old_billto
    if (@account3 + @account2 + @account1 < 0) and (@UseClientAccount <> 0)  --2006.3.21, Edited by ShenMin, Q6272, 增加单独控制每个门店和客户是否启用信用额度的功能
    begin
      set @errmsg = '该单据金额为负，客户信用额与交款额不足,不能冲单'
      return(5)
    end
    else
    begin
      set @account1 = -@account1
      execute @return_status = UPDLEAGUECLIENTACCOUNTTOTAL @neg_num, @old_client, '批发', @account1
    end
  end

  /*减少预配数*/
  /*declare @Opqty money, @m_store int
  select @m_store = usergid from system
  declare c_Procalcgft1 cursor for
  select gdgid, qty
  from stkoutdtl(nolock)
  where cls = @old_cls and num = @old_num order by line
  open c_Procalcgft1
  fetch next from c_Procalcgft1 into @old_gdgid, @old_qty
  while @@fetch_status = 0
  begin
    exec @return_status = DecPreAlcQty @piStore = @m_store, @piWrh = @old_wrh, @piGdgid = @old_gdgid, @piQty = @old_qty, @piMode = -1, @poOpqty = @Opqty output --zhangzhen 20071114
    if @return_status <> 0 return @return_status
    fetch next from c_Procalcgft1 into @old_gdgid, @old_qty
  end
  close c_Procalcgft1
  deallocate c_Procalcgft1*/

    /*  杨赛 审核冲单 由 状态由 1 - 2 */
  if @old_cls = '配货' and @old_stat = 1
  begin
    select @vCount = count(1) from EPSSENDSTKOUT where num = @old_num
    if @vCount = 0
      insert into EPSSENDSTKOUT values(@old_num, @old_client, 1)
    else
      delete from EPSSENDSTKOUT where num = @old_num
  end


  return(@return_status)
end
GO
