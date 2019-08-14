SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[LSDTLCHK](
  @cur_date datetime,
  @cur_settleno int,
  @p_wrh int,
  @p_gdgid int,
  @p_qtyls money,
  @p_amtls money,
  @p_inprc money,
  @p_rtlprc money,
  @p_outcost money = null /*2002-06-13*/
) with encryption as
begin
  insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
    KS_Q, KS_A, KS_I, KS_R)
    values (@cur_date, @cur_settleno, @p_wrh, @p_gdgid,
    @p_qtyls, @p_amtls, isnull(@p_outcost,@p_qtyls * @p_inprc/*2002-06-13*/), @p_qtyls * @p_rtlprc)
end
GO
