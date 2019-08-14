SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[UPDINVPRC] (
 @mode varchar(10),
 @gdgid int,
 @qty money,
 @total money,
 @wrh int,  --2002.08.18
 @outcost money = 0 output
) with encryption as
begin
 declare @usergid int, @inprctax smallint, @g_sale smallint,
  @g_tax money, @n_invcost money, @n_invprc money,
  @n_adjamt money, @cur_date datetime, @cur_settleno int,
  @opt_value int --2002.05.30
 declare @gw_invprc money, @gw_invcost money, @iw_tqty money,
  @nw_invcost money, @nw_invprc money, @nw_adjamt money,
  @g_invprc money, @g_invcost money, @i_tqty money

 select @g_sale = SALE, @g_tax = TAXRATE
  from GOODS (nolock) where GID = @gdgid
 if @g_sale <> 1 return(0)/*2004-08-12*/

 select @cur_settleno = max(NO) from MONTHSETTLE
 set @cur_date = convert(datetime, convert(char,getdate(),102))
 select @inprctax = INPRCTAX, @usergid = USERGID from system (nolock)

 select @i_tqty = isnull(sum(QTY), 0)
  from INV (nolock) where STORE = @usergid and GDGID = @gdgid
 select @iw_tqty = isnull(sum(QTY), 0)
  from INV (nolock) where STORE = @usergid and GDGID = @gdgid and WRH = @wrh
 select @gw_invprc = INVPRC, @gw_invcost = INVCOST
  from GDWRH where GDGID = @gdgid and WRH = @wrh  --2002.08.18
 if @@rowcount = 0
 begin
  set @gw_invcost = 0
  if @mode in ('进货', '内部调拨进')  --2002.09.30
   set @gw_invprc = 0
  else
  begin
   exec OPTREADINT 0, 'InitInvPrc', 1, @opt_value output
   if @opt_value = 1
    select @gw_invprc = CNTINPRC from GOODS (nolock) where GID = @gdgid
   else
    set @gw_invprc = 0
  end
  insert into GDWRH (GDGID, WRH, INVPRC, INVCOST)
   values (@gdgid, @wrh, @gw_invprc, @gw_invcost)
 end

 if @mode in ('进货', '内部调拨进')
 begin
  -- 注：进入时库存尚未修改
  if @inprctax = 0
   set @total = @total / (1.0 + @g_tax / 100.0)

  --2004-10-10
  if @iw_tqty < 0 and @qty > 0
  begin
    if @iw_tqty + @qty > 0
      set @nw_invcost = round((@iw_tqty + @qty) * @total / @qty, 2)
    else
      set @nw_invcost = round((@iw_tqty + @qty) * @gw_invprc, 2)
  end
  else if @iw_tqty < 0 and @qty < 0
  begin
      set @nw_invcost = round((@iw_tqty + @qty) * @gw_invprc, 2)
  end
  else if @iw_tqty > 0 and @qty < 0
  begin
    if @iw_tqty + @qty > 0
      if @gw_invcost + @total > 0
       set @nw_invcost = round(@gw_invcost + @total, 2)
   else
       set @nw_invcost = round((@iw_tqty + @qty) * @gw_invprc, 2)
    else
      set @nw_invcost = round((@iw_tqty + @qty) * @gw_invprc, 2)
  end
  else if @iw_tqty > 0 and @qty > 0
  begin
   set @nw_invcost = round(@gw_invcost + @total, 2)
  end
  else
  begin
    if @iw_tqty =0 and @qty < 0
      set @nw_invcost = round((@iw_tqty + @qty) * @gw_invprc, 2)
    else
      set @nw_invcost = round(@gw_invcost + @total, 2)
  end

  set @nw_adjamt = @nw_invcost - (@gw_invcost + @total)
  if @nw_adjamt <> 0
   insert into KC (ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I)
    values (@cur_date, @cur_settleno, @wrh, @gdgid,
    @iw_tqty + @qty, @nw_adjamt)

       if @iw_tqty + @qty <> 0  /*2005-04-15*/
          set @nw_invprc = @nw_invcost / (@iw_tqty + @qty)
       else
          set @nw_invprc = @gw_invprc
        --end 2004-10-10

  set @i_tqty = @i_tqty + @qty
  /*2005-8-19 有差异再更新gdwrh，尽量避免零售单使用IC卡时死锁*/
  update GDWRH set INVPRC = @nw_invprc, INVCOST = @nw_invcost
   where GDGID = @gdgid and WRH = @wrh
   and (INVPRC <> @nw_invprc or INVCOST <> @nw_invcost)
 end

 if @mode in ('销售', '进货退货', '内部调拨出')
 begin
  -- 注：进入时库存已经修改
  if @iw_tqty = 0
   set @outcost = @gw_invcost
  else if @iw_tqty + @qty = 0
   set @outcost = round(@qty * @gw_invprc, 2)
  else
   set @outcost = round(@qty * @gw_invcost / (@iw_tqty + @qty), 2)
  set @nw_invcost = round(@gw_invcost - @outcost, 2)
  set @nw_invprc = @gw_invprc
  if @iw_tqty <> 0
   set @nw_invprc = @nw_invcost / @iw_tqty
  /*2005-8-19 有差异再更新gdwrh，尽量避免零售单使用IC卡时死锁*/
  update GDWRH set INVPRC = @nw_invprc, INVCOST = @nw_invcost
   where GDGID = @gdgid and WRH = @wrh
   and (INVPRC <> @nw_invprc or INVCOST <> @nw_invcost)
 end

 if @mode in ('销售退货', '盘点')
 begin
  -- 注：进入时库存尚未修改
  if @iw_tqty + @qty = 0
   set @outcost = -@gw_invcost  --2002-11-11
  else if @iw_tqty = 0
   set @outcost = round(@qty * @gw_invprc, 2)
  else
   set @outcost = round(@qty * @gw_invcost / @iw_tqty, 2)
  set @nw_invcost = round(@gw_invcost + @outcost, 2)
  set @nw_invprc = @gw_invprc
  if @iw_tqty + @qty <> 0
   set @nw_invprc = @nw_invcost / (@iw_tqty + @qty)
  set @i_tqty = @i_tqty + @qty
  /*2005-8-19 有差异再更新gdwrh，尽量避免零售单使用IC卡时死锁*/
  update GDWRH set INVPRC = @nw_invprc, INVCOST = @nw_invcost
   where GDGID = @gdgid and WRH = @wrh
   and (INVPRC <> @nw_invprc or INVCOST <> @nw_invcost)
 end

 if @mode = '零售'
 begin
  -- 注：进入时库存尚未修改
  if @iw_tqty - @qty = 0
   set @outcost = @gw_invcost
  else if @iw_tqty = 0
   set @outcost = round(@qty * @gw_invprc, 2)
  else
   set @outcost = round(@qty * @gw_invcost / @iw_tqty, 2)
  set @nw_invcost = round(@gw_invcost - @outcost, 2)
  set @nw_invprc = @gw_invprc
  if @iw_tqty - @qty <> 0
   set @nw_invprc = @nw_invcost / (@iw_tqty - @qty)
  set @i_tqty = @i_tqty - @qty
  /*2005-8-19 有差异再更新gdwrh，尽量避免零售单使用IC卡时死锁*/
  update GDWRH set INVPRC = @nw_invprc, INVCOST = @nw_invcost
   where GDGID = @gdgid and WRH = @wrh
   and (INVPRC <> @nw_invprc or INVCOST <> @nw_invcost)
 end

 select @g_invcost = isnull(sum(INVCOST), 0)
  from GDWRH where GDGID = @gdgid
 /*2005-8-19 有差异再更新goods，尽量避免零售单使用IC卡时死锁*/
 if @i_tqty = 0
  update GOODS set INVCOST = @g_invcost
   where GID = @gdgid and INVCOST <> @g_invcost
 else
  update GOODS set
   INVPRC = @g_invcost / @i_tqty, INVCOST = @g_invcost
   where GID = @gdgid and (INVPRC <> @g_invcost / @i_tqty or INVCOST <> @g_invcost)
end
GO
