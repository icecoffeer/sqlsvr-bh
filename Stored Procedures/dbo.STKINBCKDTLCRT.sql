SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKINBCKDTLCRT](
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
  @inprc money,
  @rtlprc money,
  @acnt smallint,
  @outcost money = null	/*2002-06-13*/
) with encryption as
begin
  declare
    @t_qty money,
    @t_amt money,
    @t_tax money,
    @t_in money,
    @t_rtl money

  select
    @t_qty = @qty,
    @t_amt = @total - @tax,
    @t_tax = @tax,
    @t_in = isnull(@outcost, @qty * @inprc), --2002-06-13
    @t_rtl = @qty * @rtlprc
  if @cur_date = convert(datetime, convert(char,@fildate,102)) begin
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_Q, ZJT_A, ZJT_T, ZJT_I, ZJT_R, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJT_Q, PJT_A, PJT_T, PJT_I, PJT_R, ACNT ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJT_Q, ZPJT_A, ZPJT_T, ZPJT_I, ZPJT_R, ACNT ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt )
      if @@error <> 0 return(@@error)
    end
  end else if @cur_settleno = @settleno begin
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_Q_B, ZJT_A_B, ZJT_T_B, ZJT_I_B, ZJT_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl , @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJT_Q_B, PJT_A_B, PJT_T_B, PJT_I_B, PJT_R_B, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJT_Q_B, ZPJT_A_B, ZPJT_T_B, ZPJT_I_B, ZPJT_R_B, ACNT ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt )
      if @@error <> 0 return(@@error)
    end
  end else begin
    if @cls = '自营' begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_Q_S, ZJT_A_S, ZJT_T_S, ZJT_I_S, ZJT_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '配货' begin
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJT_Q_S, PJT_A_S, PJT_T_S, PJT_I_S, PJT_R_S, ACNT) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt)
      if @@error <> 0 return(@@error)
    end else if @cls = '直配' begin
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJT_Q_S, ZPJT_A_S, ZPJT_T_S, ZPJT_I_S, ZPJT_R_S, ACNT ) values (
        @cur_date, @cur_settleno, @wrh, @gdgid, @billto, @psr,
        @t_qty, @t_amt, @t_tax, @t_in, @t_rtl, @acnt )
      if @@error <> 0 return(@@error)
    end
  end
end
GO
