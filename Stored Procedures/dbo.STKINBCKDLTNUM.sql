SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
/*
  @return_staus
    2: 已提货,不能冲单
    3: 提单作废错误
*/
create procedure [dbo].[STKINBCKDLTNUM]
  @cls char(10),
  @num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
with encryption as
begin
  /*
    99-8-30: 负单的OCRDATE应和废单的一致
  */
  declare
    @return_status int,        @cur_date datetime,        @cur_settleno int,
    @fildate datetime,         @settleno int,             @wrh int,
    @billto int,               @psr int,                  @stat smallint,
    @gdgid int,                @qty money,                @price money,
    @total money,              @tax money,                @validdate datetime,
    @g_inprc money,            @g_rtlprc money,           @paytodtl smallint,
    @line smallint,            @acnt smallint,            @inprc money,
    @rtlprc money,             @subwrh int,
    @gendsp int,               @dsp_num char(10),         @dsp_stat int,
    /*2002-06-13*/
    @cost money,               @n_cost money,             @sale smallint,/*2003-06-13*/
    @vendor int,               @genbill varchar(10),      @gennum varchar(14), /*2005-8-23*/
    @rtlbck_usezbinprc int,    @store int  /*2005-8-23*/

  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char,getdate(),102))
  select
    @cur_settleno = max(NO) from MONTHSETTLE

  select
    @stat = STAT,
    @fildate = CASE STAT WHEN 1 THEN OCRDATE ELSE FILDATE END,
    @settleno = SETTLENO,
    @billto = BILLTO,
    @psr = PSR,
    @vendor = VENDOR,    /*2005-8-23*/
    @genbill = GENBILL,  /*2005-8-23*/
    @gennum = GENNUM     /*2005-8-23*/
    from STKINBCK where CLS = @cls and NUM = @num
  if @stat <> 1 and @stat <> 6 begin
    raiserror('删除的不是已审核或已复核的单据.', 16, 1)
    return(1)
  end

  /* 2000-11-02 */
  if @stat=6 and (select payflag from system)=1
  begin
    select @errmsg = '已复核的单据不能冲单'
    raiserror(@errmsg, 16, 1)
    return(1)
  end

  /*2005-8-23 检查是否门店零售退货单生成且使用了总部成本价*/
  select @store = usergid from system
  if @genbill = 'RTLBCK' and @gennum <> '' and @vendor <> @store
    and exists(select 1 from hdoption(nolock) where moduleno = 284 and optioncaption = 'PriceType' and optionvalue = '1')
    select @rtlbck_usezbinprc = 1
  else
    select @rtlbck_usezbinprc = 0

  /* 00-3-30 */
  execute @return_status = CanDeleteBill 'STKINBCK', @cls, @num, @errmsg output
  if @return_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  -- make a negative bill, set inprc, rtlprc to current values
  insert into STKINBCK (CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE,
    WRH, GENBILL/*2005-8-23*/,
    TOTAL, TAX, NOTE, FILDATE, FILLER, CHECKER, STAT, MODNUM, PSR, RECCNT, SRC)
    select @cls, @neg_num, @cur_settleno, VENDOR, VENDORNUM, BILLTO, OCRDATE,
    WRH, GENBILL/*2005-8-23*/,
    -TOTAL, -TAX, NULL, getdate(), @new_oper, @new_oper, 4, @num, PSR, RECCNT,
    SRC
    from STKINBCK where CLS = @cls and NUM = @num
  if @stat = 6
    update STKINBCK set CHKDATE = getdate() where CLS = @cls and NUM = @neg_num
  insert into STKINBCKDTL (CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, PAYQTY, PAYAMT,
    PRICE, TOTAL, TAX, VALIDDATE, WRH, INPRC, RTLPRC, SUBWRH, COST) /*2002-06-13*/
    select @cls, @cur_settleno, @neg_num, LINE, GDGID, -CASES, -QTY, 0, 0,
    PRICE, -TOTAL, -TAX, VALIDDATE, STKINBCKDTL.WRH, INPRC, RTLPRC, SUBWRH, -COST /*2002-06-13*/
    from STKINBCKDTL
    where CLS = @cls and NUM = @num
  insert into STKBCKIN (CLS, INNUM, INLINE, BCKNUM, BCKLINE, QTY)
    select @cls, INNUM, INLINE, @neg_num, BCKLINE, -QTY
    from STKBCKIN where CLS = @cls and BCKNUM = @num

  declare c_stkinbck cursor for
    select WRH, GDGID, QTY, PRICE, TOTAL, TAX, VALIDDATE, LINE, INPRC, RTLPRC, SUBWRH,
    COST -- 2002-06-13
    from STKINBCKDTL where CLS = @cls and NUM = @num
  open c_stkinbck
  fetch next from c_stkinbck into
    @wrh, @gdgid, @qty, @price, @total, @tax,
    @validdate, @line, @inprc, @rtlprc, @subwrh, @cost /*2002-06-13*/
  while @@fetch_status = 0 begin
    select
      @g_rtlprc = RTLPRC,
      @g_inprc = INPRC,
      @paytodtl = PAYTODTL,
      @sale = SALE/*2003-06-13*/
      from GOODS where GID = @gdgid

    if @stat = 6 begin
      /* update STKINDTL */
      if @paytodtl = 1 begin
        update STKINDTL
          set BCKQTY = BCKQTY - STKBCKIN.QTY
          from STKBCKIN
          where STKINDTL.CLS = STKBCKIN.CLS
            and STKINDTL.NUM = STKBCKIN.INNUM
            and STKINDTL.LINE = STKBCKIN.INLINE
            and STKBCKIN.BCKNUM = @num
            and STKBCKIN.BCKLINE = @line
        if @@error <> 0 begin
          select @return_status = @@error
          break
        end
      end
    end

    /* update inventory */
    if @rtlbck_usezbinprc = 1
      /*2005-8-23 如果经销、代销商品由门店零售退货单产生并使用总部成本价，则不在门店移动平均；联销商品调用UPDINVPRC也没实际效果*/
      select @return_status = 0
    else
      /* 2002-03-28 update INVPRC 参照出货单冲单处理，处理成进货影响库存价变化*/
      execute UPDINVPRC '进货', @gdgid, @qty, @cost, @wrh /*2002.08.18*/
    execute @return_status = LOADIN @wrh, @gdgid, @qty, @g_rtlprc, @validdate
    if @return_status <> 0 break
    if @subwrh is not null
    begin
      execute @return_status = LOADINSUBWRH @wrh, @subwrh, @gdgid, @qty, /* 2000-06-12 */ @inprc
      if @return_status <> 0 break
    end

    if @stat = 6 select @acnt = 2
    else select @acnt = 0
    /* reports */
    select
      @qty = -@qty,
      @total = -@total,
      @tax = -@tax,
      @n_cost = - @cost --2002-06-13
    if @sale = 1 /*2003-06-13*/
    execute @return_status = STKINBCKDTLCRT
      @cur_date, @cur_settleno, @fildate, @settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @inprc, @rtlprc, @acnt,
      @n_cost --2002-06-13
    else
    execute @return_status = STKINBCKDTLCRT
      @cur_date, @cur_settleno, @fildate, @settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @inprc, @rtlprc, @acnt
    if @return_status <> 0 break
    /* 生成调价差异, 库存已经按照当前售价退库了 */
    /*2002-06-13 移动加权平均核算这时不应计算进价的调价差异*/
    --if @inprc <> @g_inprc or @rtlprc <> @g_rtlprc
    --if @rtlprc <> @g_rtlprc
    /*2003-06-13 V2算法下，代联销商品仍然应该计算进价的调价差异*/
    if @inprc <> @g_inprc or @rtlprc <> @g_rtlprc
    begin
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @gdgid, @wrh,
    --    (@g_inprc-@inprc) * -@qty, (@g_rtlprc-@rtlprc) * -@qty)
    	case @sale when 1 then 0 else (@g_inprc-@inprc) * -@qty end, (@g_rtlprc-@rtlprc) * -@qty)
    end

    fetch next from c_stkinbck into
      @wrh,@gdgid,@qty,@price, @total, @tax,
      @validdate, @line, @inprc, @rtlprc, @subwrh, @cost /*2002-06-13*/
  end
  close c_stkinbck
  deallocate c_stkinbck

  /* 在某种未知的情况下,调用过程中的RAISERROR不能被CLIENT捕获.
  这里再RAISE一次 */
  if @return_status <> 0
  begin
    raiserror('处理单据时发生错误.', 16, 1)
    return (@return_status)
  end

  /* 2000-2-28: 处理提单 */
  if (@cls = '自营' and (select DSP from SYSTEM) & 32 <> 0) or
     (@cls = '配货' and (select DSP from SYSTEM) & 64 <> 0)
    select @gendsp = 1
  else
    select @gendsp = 0
  if @gendsp = 1
  begin
    select @dsp_num = null
    SELECT @dsp_num = NUM, @dsp_stat = STAT
    FROM DSP WHERE CLS = 'STKINBCK' AND POSNOCLS = @cls AND FLOWNO = @num
    if @dsp_num is not null
    begin
      if @dsp_stat <> 0
      begin
        select @return_status = 2
        raiserror( '该单据已被提货,不能冲单.', 16, 1 )
        return
      end
      execute @return_status = DSPABORT @dsp_num
      if @return_status <> 0
      begin
        select @return_status = 3
        raiserror( '不能作废相关的提单.', 16, 1 )
        return
      end
    end
  end

  return(@return_status)
end
GO
