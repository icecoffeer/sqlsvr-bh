SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFDTLCHKCRT](
  @cur_date datetime,
  @cur_settleno int,
  @p_date datetime,
  @p_settleno int,
  @p_wrh int,
  @p_gdgid int,
  @p_qtyovf money,
  @p_amtovf money,
  @p_inprc money,
  @p_rtlprc money
) with encryption as
begin
  if convert(datetime,convert(char,@p_date,102)) = @cur_date begin
    insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
      KY_Q, KY_A, KY_I, KY_R)
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      @p_qtyovf, @p_amtovf,
      @p_qtyovf * @p_inprc, @p_qtyovf * @p_rtlprc)
  end else if @p_settleno = @cur_settleno begin
    insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
      KY_Q_B, KY_A_B, KY_I_B, KY_R_B)
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      @p_qtyovf, @p_amtovf,
      @p_qtyovf * @p_inprc, @p_qtyovf * @p_rtlprc)
  end else begin
    insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
      KY_Q_S, KY_A_S, KY_I_S, KY_R_S)
      values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
      @p_qtyovf, @p_amtovf,
      @p_qtyovf * @p_inprc, @p_qtyovf * @p_rtlprc)
  end
end
GO
