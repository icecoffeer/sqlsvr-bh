SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PURCHASEORDERDTLCRT](
  @cur_date datetime,
  @cur_settleno int,
  @fildate datetime,
  @settleno int,
  @cls char(10),
  @wrh int,
  @gdgid int,
  @billto int,
  @psr int,
  @qty money,
  @price money,
  @total money,
  @tax money,
  @loss money,
  @inprc money,
  @rtlprc money,
  @acnt smallint
) with encryption as
begin
  declare
    @t_qty money,
    @t_amt money,
    @t_tax money,
    @t_in money,
    @t_rtl money,
    @t_losqty money,
    @t_losamt money,
    @t_lostax money,
    @t_losin money,
    @t_losrtl money,
    @t_ovfqty money,
    @t_ovfamt money,
    @t_ovftax money,
    @t_ovfin money,
    @t_ovfrtl money

  select
    @t_qty = @qty,
    @t_amt = @total - @tax,
    @t_tax = @tax,
    @t_in = @qty * @inprc,
    @t_rtl = @qty * @rtlprc,
    @t_losqty = 0,
    @t_losamt = 0,
    @t_lostax = 0,
    @t_losin = 0,
    @t_losrtl = 0,
    @t_ovfqty = 0,
    @t_ovfamt = 0,
    @t_ovftax = 0,
    @t_ovfin = 0,
    @t_ovfrtl = 0
  if @loss < 0 begin
    select
      @t_losqty = -@loss
    select
      @t_losamt = @t_losqty * @price,
      @t_lostax = @tax / @qty * @t_losqty,
      @t_losin = @t_losqty * @inprc,
      @t_losrtl = @t_losqty * @rtlprc
  end else if @loss > 0 begin
    select
      @t_ovfqty = @loss
    select
      @t_ovfamt = @t_ovfqty * @price,
      @t_ovftax = @tax / @qty * @t_ovfqty,
      @t_ovfin = @t_ovfqty * @inprc,
      @t_ovfrtl = @t_ovfqty * @rtlprc
  end
  if @cur_date = convert(datetime, convert(char,@fildate,102)) begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q, ZJ_A, ZJ_T, ZJ_I, ZJ_R,
        ZJS_Q, ZJS_A, ZJS_T, ZJS_I, ZJS_R,
        ZJY_Q, ZJY_A, ZJY_T, ZJY_I, ZJY_R, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
  end else if @cur_settleno = @settleno begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q_B, ZJ_A_B, ZJ_T_B, ZJ_I_B, ZJ_R_B,
        ZJS_Q_B, ZJS_A_B, ZJS_T_B, ZJS_I_B, ZJS_R_B,
        ZJY_Q_B, ZJY_A_B, ZJY_T_B, ZJY_I_B, ZJY_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
  end else begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q_S, ZJ_A_S, ZJ_T_S, ZJ_I_S, ZJ_R_S,
        ZJS_Q_S, ZJS_A_S, ZJS_T_S, ZJS_I_S, ZJS_R_S,
        ZJY_Q_S, ZJY_A_S, ZJY_T_S, ZJY_I_S, ZJY_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
  end
end
GO
