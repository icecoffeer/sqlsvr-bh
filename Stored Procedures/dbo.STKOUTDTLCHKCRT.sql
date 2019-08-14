SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[STKOUTDTLCHKCRT](
  @cls char(10), @cur_date datetime,   @cur_settleno int,  @fildate datetime,
  @settleno int, @client int,          @slr int,           @wrh int,
  @gdgid int,    @qty money,           @total money,       @tax money,
  @inprc money,  @rtlprc money,        @vdr int,           @outcost money = null, /*2002-06-13*/
  @VStat smallint,@optvalue_chk int  /* 加@VStat，@optvalue_chk这两个参数 by jinlei 3692*/
) --with encryption 
as
begin
  declare @amount money
  select @amount = @total - @tax
  if convert(datetime, convert(char, @fildate, 102)) = @cur_date begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q, WC_A, WC_T, WC_I, WC_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q, WC_A, WC_T, WC_I, WC_R, ACNT)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc, @optvalue_chk)
    end else if @cls = '调出' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        DC_Q, DC_A, DC_T, DC_I, DC_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PC_Q, PC_A, PC_T, PC_I, PC_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_Q, ZPC_A, ZPC_T, ZPC_I, ZPC_R)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @qty * @inprc, @qty * @rtlprc)
    end
  end else if @settleno = @cur_settleno begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q_B, WC_A_B, WC_T_B, WC_I_B, WC_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    END ELSE IF (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q_B, WC_A_B, WC_T_B, WC_I_B, WC_R_B, ACNT)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc, @optvalue_chk)
    end else if @cls = '调出' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        DC_Q_B, DC_A_B, DC_T_B, DC_I_B, DC_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PC_Q_B, PC_A_B, PC_T_B, PC_I_B, PC_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_Q_B, ZPC_A_B, ZPC_T_B, ZPC_I_B, ZPC_R_B)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @qty * @inprc, @qty * @rtlprc)
    end
  end else begin
    if @cls = '批发' and (((@VStat = 6 and @optvalue_Chk = 1) or (@VStat = 1 and @optvalue_chk = 0))) begin
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q_S, WC_A_S, WC_T_S, WC_I_S, WC_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    END ELSE IF (@CLS = '批发') and (((@VStat = 1) and (@optvalue_Chk = 1)) or @optvalue_Chk = 2) BEGIN
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_Q_S, WC_A_S, WC_T_S, WC_I_S, WC_R_S, ACNT)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc, @optvalue_chk)
    end else if @cls = '调出' begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        DC_Q_S, DC_A_S, DC_T_S, DC_I_S, DC_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '配货' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PC_Q_S, PC_A_S, PC_T_S, PC_I_S, PC_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, isnull(@outcost, @qty * @inprc), @qty * @rtlprc)  -- 2002-06-13
    end else if @cls = '直配' begin
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_Q_S, ZPC_A_S, ZPC_T_S, ZPC_I_S, ZPC_R_S)
        values (@cur_date, @cur_settleno, @wrh, @gdgid, @client, @slr, @vdr,
        @qty, @amount, @tax, @qty * @inprc, @qty * @rtlprc)
    end
  end
end

GO
