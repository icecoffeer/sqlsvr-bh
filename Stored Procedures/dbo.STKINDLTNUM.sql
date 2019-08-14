SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINDLTNUM]
  @cls char(10),
  @num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output,
  /* 2000-9-14 */
  @incordqty smallint = 1
as
begin

  /*
    1999-8-26: 进货单被冲单后对应的定单FINISH置0
    99-8-30: 负单的OCRDATE应和废单的一致
    1999-9-2: 进货单被冲单后对应的定单FINISH不能简单置0.
              因为UPD是调用CHK和DLTNUM完成的
    00-3-16: system.batchflag=1时对输入的检查
    2000-9-14: 增加输入参数@incordqty来控制是否增加在单量
               task: 进货单修正在单量处理不正确(2000091243444)

  */

  declare
    @return_status int,     @cur_date datetime,        @cur_settleno int,
    @fildate datetime,      @settleno int,             @wrh int,
    @billto int,            @psr int,                  @stat smallint,
    @gdgid int,             @qty money,                @loss money,
    @price money,           @total money,              @tax money,
    @inprc money,           @rtlprc money,             @validdate datetime,
    @bckqty money,          @payqty money,             @t_qty money,
    @g_inprc money,         @g_rtlprc money,           @paytodtl smallint,
    @ordnum char(10),       @acnt smallint,            @t_money1 money,
    @t_money2 money,        @subwrh int,               @line smallint,
    @optvalue int, /*2002-09-10*/
    @DecOrdQty INT --2006.12.05 ADDED BY ZHANGLONG
  declare @ordline int/*2003-08-27*/,                  @sale smallint/*2004-08-25*/
  declare @GENBILL char(10), @op_usezbinprc int  /*2005-8-13*/

  select
    @return_status = 0,
    @cur_date = convert(datetime, convert(char,getdate(),102))
  select
    @cur_settleno = max(NO) from MONTHSETTLE

  select
    @stat = STAT,
    @fildate = CASE STAT WHEN 1 THEN FILDATE ELSE CHKDATE END,
    @settleno = SETTLENO,
    @billto = BILLTO,
    @psr = PSR,
    @ordnum = ORDNUM,
    @GENBILL = GENBILL  /*2005-8-13*/
    from STKIN where CLS = @cls and NUM = @num
  if @stat <> 1 and @stat <> 6 begin
    select @errmsg = '删除的不是已审核或已复核的单据'
    raiserror(@errmsg, 16, 1)
    return(1009)
  end

  /* 2000-11-02 */
  if @stat=6 and (select payflag from system)=1
  begin
    select @errmsg = '已复核的单据不能冲单'
    raiserror(@errmsg, 16, 1)
    return(1009)
  end

  /* 00-3-30 */
  execute @return_status = CanDeleteBill 'STKIN', @cls, @num, @errmsg output
  if @return_status != 0 begin
    raiserror(@errmsg, 16, 1)
    return(@return_status)
  end

  /*2005-8-13*/
  if @GENBILL is null select @GENBILL = ''
  if exists(select 1 from HDOPTION where MODULENO = 282 and OPTIONCAPTION = 'IsAllowModLocalCost1' and OPTIONVALUE = '1')
    select @op_usezbinprc = 1
  else
    select @op_usezbinprc = 0

  -- make a negative bill
  insert into STKIN (CLS, NUM, SETTLENO, VENDOR, VENDORNUM, BILLTO, OCRDATE,
    TOTAL, TAX, NOTE, FILDATE, FILLER, STAT, MODNUM, PSR, RECCNT, SRC,
    ORDNUM, WRH)
    select @cls, @neg_num, @cur_settleno, VENDOR, VENDORNUM, BILLTO, OCRDATE,
    -TOTAL, -TAX, NULL, getdate(), @new_oper, 4, @num, PSR, RECCNT,
    SRC, ORDNUM, WRH
    from STKIN where CLS = @cls and NUM = @num
  if @stat = 6
    update STKIN set CHKDATE = getdate(), CHECKER = @new_oper
    where CLS = @cls and NUM = @neg_num
  insert into STKINDTL (CLS, SETTLENO, NUM, LINE, GDGID, CASES, QTY, LOSS,
    PRICE, TOTAL, TAX, VALIDDATE, WRH, BCKQTY, PAYQTY, INPRC, RTLPRC, SUBWRH, DECORDQTY)
    select @cls, @cur_settleno, @neg_num, LINE, GDGID, -CASES, -QTY, -LOSS,
    PRICE, -TOTAL, -TAX, VALIDDATE, STKINDTL.WRH, 0, 0,
    INPRC, RTLPRC, SUBWRH, -DECORDQTY
    from STKINDTL
    where CLS = @cls and NUM = @num

  declare c_stkin cursor for
    select WRH, GDGID, QTY, PRICE, TOTAL, TAX, LOSS, INPRC, RTLPRC, VALIDDATE,
    BCKQTY, PAYQTY, SUBWRH, LINE, ORDLINE/*2003-08-27*/
    from STKINDTL where CLS = @cls and NUM = @num
  open c_stkin
  fetch next from c_stkin into
    @wrh, @gdgid, @qty, @price, @total, @tax, @loss, @inprc, @rtlprc,
    @validdate, @bckqty, @payqty, @subwrh, @line, @ordline/*2003-08-27*/
  while @@fetch_status = 0 begin
    /* check validity */
    select
      @paytodtl = PAYTODTL,
      @g_inprc = INPRC,
      @g_rtlprc = RTLPRC,
      @sale = SALE
      from GOODS where GID = @gdgid
    if @paytodtl = 1 and ((@bckqty <> 0) or (@payqty <> 0)) begin
      select @errmsg = name + '[' + code + ']' from goodsh where gid = @gdgid
      select @errmsg = '商品已被退货或付款,不能冲单: 第' +
             convert(char(3), @line) + '行,' + @errmsg
      select @return_status = 1010
      break
    end

    /* if @stat = 6 */
      /* update INVPRC */
    /*2005-8-13*/
    if @GENBILL <> 'RTL' or (@GENBILL = 'RTL' and @op_usezbinprc = 0)
    begin
      select @t_money1 = -@qty - @loss, @t_money2 = -@total
      execute UPDINVPRC '进货', @gdgid, @t_money1, @t_money2, @wrh /*2002-09-03*/
    end

    /* update inventory */
    select @t_qty = @qty + @loss
    execute @return_status = UNLOAD @wrh, @gdgid, @t_qty, @g_rtlprc, @validdate
    if @return_status <> 0 break

    if (select batchflag from system) = 1
    begin
      /* 2000-3-16 */
      if @subwrh is null begin
        select @errmsg = name + '[' + code + ']' from goodsh where gid = @gdgid
        select @return_status = 1011
        select @errmsg = '必须提供货位批号: 第' +
               convert(char(3), @line) + '行,' + @errmsg
        break
      end
      select @t_money1 = isnull(
        (select qty from subwrhinv where subwrh = @subwrh and gdgid = @gdgid),
        0)
      if @t_qty > @t_money1 begin
        select @return_status = 1012
        select @errmsg = name + '[' + code + ']' from goodsh where gid = @gdgid
        select @errmsg = '当前库存中数量少于冲单的数量: 第' +
               convert(char(3), @line) + '行,' + @errmsg
        break
      end
    end
    if @subwrh is not null
    begin
      execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @t_qty
      if @return_status <> 0 break
    end

    /* reports */
    select
      @qty = -@qty,
      @total = -@total,
      @tax = -@tax,
      @loss = -@loss
    if @stat = 6 select @acnt = 2
    else select @acnt = 0
    execute @return_status = STKINDTLCRT
      @cur_date, @cur_settleno, @fildate, @settleno,
      @cls, @wrh, @gdgid, @billto, @psr,
      @qty, @price, @total, @tax, @loss, @inprc, @rtlprc, @acnt
    if @return_status <> 0 break
    /* 生成调价差异, 库存已经按照当前售价退库了 */
    if @inprc <> @g_inprc or @rtlprc <> @g_rtlprc
    begin
      insert into KC (ASETTLENO, ADATE, BGDGID, BWRH, TJ_I, TJ_R)
        values (@cur_settleno, @cur_date, @gdgid, @wrh,
        case @sale when 1 then 0 else (@g_inprc-@inprc) * @qty end /*2004-08-25*/, (@g_rtlprc-@rtlprc) * @qty)
    end

    fetch next from c_stkin into
      @wrh,@gdgid,@qty,@price, @total, @tax, @loss, @inprc, @rtlprc,
      @validdate, @bckqty, @payqty, @subwrh, @line, @ordline/*2003-08-27*/
  end
  close c_stkin
  deallocate c_stkin

  if @return_status <> 0 begin
    raiserror(@errmsg, 16, 1)
    return (@return_status)
  end

  /* 1999-8-26: 进货单被冲单后对应的定单FINISH置0 */
  /* 1999-9-2: 进货单被冲单后对应的定单FINISH不能简单置0.
     因为UPD是调用CHK和DLTNUM完成的 */
  /* 设置ORD.FINISHED */
  if @ordnum is not null
  begin
    /*2002-09-10*/
    select @optvalue = 0
    if @cls = '自营'
      exec OPTREADINT 52, 'WriteBackToOrd', 0, @optvalue output
    if @optvalue = 0
      and not exists
      (select * from ORDDTL where NUM = @ordnum
      and QTY > ARVQTY + ASNQTY)
      update ORD set FINISHED = 1 where NUM = @ordnum
    else
      update ORD set FINISHED = 0 where NUM = @ordnum
  end

  return(@return_status)
end
GO
