SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTBCKDTLCHKCRT](
  @cls char(10), @cur_date datetime,  @cur_settleno int,      @fildate datetime,
  @settleno int, @client int,         @slr int,               @wrh int,
  @gdgid int,    @qty money,          @total money,           @tax money,
  @inprc money,  @rtlprc money,       @vdr int,               @VStat smallint,
  @optvalue_chk int,@outcost money = null   /* 加@VStat，@optvalue_chk这两个参数 by jinlei 3692*/
) with encryption as
begin
  declare @amount money, @inamt money
  select @amount = @total - @tax,
    @inamt = isnull(@outcost, @qty * @inprc)  --2002-06-13
  if convert(datetime, convert(char, @fildate, 102)) = @cur_date begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q, WCT_A, WCT_T, WCT_I, WCT_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q, WCT_A, WCT_T, WCT_I, WCT_R, ACNT)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc, @optvalue_Chk)
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PCT_Q, PCT_A, PCT_T, PCT_I, PCT_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPCT_Q, ZPCT_A, ZPCT_T, ZPCT_I, ZPCT_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '零售' begin  /*2001-09-18*/
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        LST_Q, LST_A, LST_T, LST_I, LST_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end
  end else if @settleno = @cur_settleno begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q_B, WCT_A_B, WCT_T_B, WCT_I_B, WCT_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q_B, WCT_A_B, WCT_T_B, WCT_I_B, WCT_R_B, Acnt)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc, @optvalue_Chk)
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PCT_Q_B, PCT_A_B, PCT_T_B, PCT_I_B, PCT_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPCT_Q_B, ZPCT_A_B, ZPCT_T_B, ZPCT_I_B, ZPCT_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '零售' begin  /*2001-09-18*/
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        LST_Q_B, LST_A_B, LST_T_B, LST_I_B, LST_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end
  end else begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q_S, WCT_A_S, WCT_T_S, WCT_I_S, WCT_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_Q_S, WCT_A_S, WCT_T_S, WCT_I_S, WCT_R_S, ACNT)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc, @optvalue_Chk)
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PCT_Q_S, PCT_A_S, PCT_T_S, PCT_I_S, PCT_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPCT_Q_S, ZPCT_A_S, ZPCT_T_S, ZPCT_I_S, ZPCT_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end else if @cls = '零售' begin /*2001-09-18*/
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        LST_Q_S, LST_A_S, LST_T_S, LST_I_S, LST_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @inamt, @qty * @rtlprc)
    end
  end
end
GO
