SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPDTLCHK](
  @cur_date datetime,
  @cur_settleno int,
  @client int,
  @gdgid int,
  @wrh int,
  @qty money,
  @total money,
  @inprc money,
  @rtlprc money
) --with encryption 
as
begin
  insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
    SK_Q, SK_A, SK_I, SK_R)
    values (@cur_date, @cur_settleno, @client, @gdgid, @wrh,
    @qty, @total, @qty * @inprc, @qty * @rtlprc)
end

GO
