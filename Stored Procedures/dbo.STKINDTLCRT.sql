SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINDTLCRT](
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
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q, ZJ_A, ZJ_T, ZJ_I, ZJ_R,
        ZJS_Q, ZJS_A, ZJS_T, ZJS_I, ZJS_R,
        ZJY_Q, ZJY_A, ZJY_T, ZJY_I, ZJY_R, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJ_Q, PJ_A, PJ_T, PJ_I, PJ_R,
        PJS_Q, PJS_A, PJS_T, PJS_I, PJS_R,
        PJY_Q, PJY_A, PJY_T, PJY_I, PJY_R, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '调入' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        DJ_Q, DJ_A, DJ_T, DJ_I, DJ_R,
        DJS_Q, DJS_A, DJS_T, DJS_I, DJS_R,
        DJY_Q, DJY_A, DJY_T, DJY_I, DJY_R, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_Q, ZPJ_A, ZPJ_T, ZPJ_I, ZPJ_R, ACNT,
        /* 2000-10-24 */
        ZPJS_Q, ZPJS_A, ZPJS_T, ZPJS_I, ZPJS_R,
        ZPJY_Q, ZPJY_A, ZPJY_T, ZPJY_I, ZPJY_R ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl)
      if @@error <> 0 return(@@error)
    end
  end else if @cur_settleno = @settleno begin
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q_B, ZJ_A_B, ZJ_T_B, ZJ_I_B, ZJ_R_B,
        ZJS_Q_B, ZJS_A_B, ZJS_T_B, ZJS_I_B, ZJS_R_B,
        ZJY_Q_B, ZJY_A_B, ZJY_T_B, ZJY_I_B, ZJY_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJ_Q_B, PJ_A_B, PJ_T_B, PJ_I_B, PJ_R_B,
        PJS_Q_B, PJS_A_B, PJS_T_B, PJS_I_B, PJS_R_B,
        PJY_Q_B, PJY_A_B, PJY_T_B, PJY_I_B, PJY_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '调入' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        DJ_Q_B, DJ_A_B, DJ_T_B, DJ_I_B, DJ_R_B,
        DJS_Q_B, DJS_A_B, DJS_T_B, DJS_I_B, DJS_R_B,
        DJY_Q_B, DJY_A_B, DJY_T_B, DJY_I_B, DJY_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_Q_B, ZPJ_A_B, ZPJ_T_B, ZPJ_I_B, ZPJ_R_B, ACNT,
        /* 2000-10-24 */
        ZPJS_Q_B, ZPJS_A_B, ZPJS_T_B, ZPJS_I_B, ZPJS_R_B,
        ZPJY_Q_B, ZPJY_A_B, ZPJY_T_B, ZPJY_I_B, ZPJY_R_B ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl)
      if @@error <> 0 return(@@error)
    end
  end else begin
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_Q_S, ZJ_A_S, ZJ_T_S, ZJ_I_S, ZJ_R_S,
        ZJS_Q_S, ZJS_A_S, ZJS_T_S, ZJS_I_S, ZJS_R_S,
        ZJY_Q_S, ZJY_A_S, ZJY_T_S, ZJY_I_S, ZJY_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJ_Q_S, PJ_A_S, PJ_T_S, PJ_I_S, PJ_R_S,
        PJS_Q_S, PJS_A_S, PJS_T_S, PJS_I_S, PJS_R_S,
        PJY_Q_S, PJY_A_S, PJY_T_S, PJY_I_S, PJY_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '调入' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        DJ_Q_S, DJ_A_S, DJ_T_S, DJ_I_S, DJ_R_S,
        DJS_Q_S, DJS_A_S, DJS_T_S, DJS_I_S, DJS_R_S,
        DJY_Q_S, DJY_A_S, DJY_T_S, DJY_I_S, DJY_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_Q_S, ZPJ_A_S, ZPJ_T_S, ZPJ_I_S, ZPJ_R_S, ACNT,
        /* 2000-10-24 */
        ZPJS_Q_S, ZPJS_A_S, ZPJS_T_S, ZPJS_I_S, ZPJS_R_S,
        ZPJY_Q_S, ZPJY_A_S, ZPJY_T_S, ZPJY_I_S, ZPJY_R_S ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt,
        @t_losqty, @t_losamt, @t_lostax, @t_losin, @t_losrtl,
        @t_ovfqty, @t_ovfamt, @t_ovftax, @t_ovfin, @t_ovfrtl)
      if @@error <> 0 return(@@error)
    end
  end
end
GO
