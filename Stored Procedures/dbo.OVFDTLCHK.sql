SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OVFDTLCHK](
  @cur_date datetime,
  @cur_settleno int,
  @p_wrh int,
  @p_gdgid int,
  @p_qtyovf money,
  @p_amtovf money,
  @p_inprc money,
  @p_rtlprc money,
  @p_cost money = null /*2002-06-13*/
) with encryption as
begin
  insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
    KY_Q, KY_A, KY_I, KY_R)
    values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
    @p_qtyovf, @p_amtovf, isnull(@p_cost, @p_qtyovf * @p_inprc), @p_qtyovf * @p_rtlprc)
end
GO
