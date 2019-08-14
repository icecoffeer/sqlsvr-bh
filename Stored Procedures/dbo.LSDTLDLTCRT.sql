SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LSDTLDLTCRT](
  @cur_date datetime,
  @cur_settleno int,
  @p_date datetime,
  @p_settleno int,
  @p_wrh int,
  @p_gdgid int,
  @p_qty money,
  @p_amt money,
  @p_inprc money,
  @p_rtlprc money,
  @p_cost money = null /*2002-06-13*/
) with encryption as
begin
  if convert(datetime, convert(char,@p_date,102))=@cur_date begin
    insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID,
      KS_Q, KS_A, KS_I, KS_R )
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      -@p_qty, -@p_amt, isnull(-@p_cost, -@p_qty * @p_inprc), -@p_qty * @p_rtlprc)
  end else if @p_settleno = @cur_settleno begin
    insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID,
      KS_Q_B, KS_A_B, KS_I_B, KS_R_B )
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      -@p_qty, -@p_amt, isnull(-@p_cost, -@p_qty * @p_inprc), -@p_qty * @p_rtlprc)
  end else begin
    insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID,
      KS_Q_S, KS_A_S, KS_I_S, KS_R_S )
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      -@p_qty, -@p_amt, isnull(-@p_cost, -@p_qty * @p_inprc), -@p_qty * @p_rtlprc)
  end
end
GO
