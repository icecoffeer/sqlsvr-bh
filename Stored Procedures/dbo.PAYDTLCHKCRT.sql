SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PAYDTLCHKCRT](
  @cur_date datetime,
  @cur_settleno int,
  @fildate datetime,
  @settleno int,
  @billto int,
  @gdgid int,
  @wrh int,
  @qty money,
  @total money,
  @stotal money,
  @inprc money,
  @rtlprc money
) with encryption as
begin
  if @cur_date = convert(datetime,convert(char,@fildate,102)) begin
    insert into ZK (ADATE, ASETTLENO, BVDRGID, BGDGID, BWRH,
      FK_Q, FK_A, FX_A, FK_I, FK_R)
      values (@cur_date, @cur_settleno, @billto, @gdgid, @wrh,
      @qty, @total, @stotal, @qty * @inprc, @qty * @rtlprc)
  end else if @cur_settleno = @settleno begin
    insert into ZK (ADATE, ASETTLENO, BVDRGID, BGDGID, BWRH,
      FK_Q_B, FK_A_B, FX_A_B, FK_I_B, FK_R_B)
      values (@cur_date, @cur_settleno, @billto, @gdgid, @wrh,
      @qty, @total, @stotal, @qty * @inprc, @qty * @rtlprc)
  end else begin
    insert into ZK (ADATE, ASETTLENO, BVDRGID, BGDGID, BWRH,
      FK_Q_S, FK_A_S, FX_A_S, FK_I_S, FK_R_S)
      values (@cur_date, @cur_settleno, @billto, @gdgid, @wrh,
      @qty, @total, @stotal, @qty * @inprc, @qty * @rtlprc)
  end
  /* 00-12-8 10:39 */
  return 0
end
GO
