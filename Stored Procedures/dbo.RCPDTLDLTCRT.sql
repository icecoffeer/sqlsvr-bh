SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RCPDTLDLTCRT](
  @cur_date datetime,
  @cur_settleno int,
  @fildate datetime,
  @settleno int,
  @client int,
  @gdgid int,
  @wrh int,
  @qty money,
  @total money,
  @inprc money,
  @rtlprc money
) with encryption as
begin
  if @cur_date = convert(datetime, convert(char,@fildate,102)) begin
    insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
      SK_Q, SK_A, SK_I, SK_R)
      values (@cur_date, @cur_settleno, @client, @gdgid, @wrh,
      -@qty, -@total, -@qty * @inprc, -@qty * @rtlprc)
  end else if @cur_settleno = @settleno begin
    insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
      SK_Q_B, SK_A_B, SK_I_B, SK_R_B)
      values (@cur_date, @cur_settleno, @client, @gdgid, @wrh,
      -@qty, -@total, -@qty * @inprc, -@qty * @rtlprc)
  end else begin
    insert into ZK (ADATE, ASETTLENO, BCSTGID, BGDGID, BWRH,
      SK_Q_S, SK_A_S, SK_I_S, SK_R_S)
      values (@cur_date, @cur_settleno, @client, @gdgid, @wrh,
      -@qty, -@total, -@qty * @inprc, -@qty * @rtlprc)
  end
end
GO
