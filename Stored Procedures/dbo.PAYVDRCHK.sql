SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[PAYVDRCHK] (
  @num char(10)
) with encryption as
begin
  declare
    @cls char(10),
    @cur_date datetime,
    @cur_settleno int,
    @wrh int,
    @billto int,
    @stat int,
    @pay money
  select
    @cls = CLS,
    @cur_date = convert(char(10), GETDATE(), 102),
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @wrh = WRH,
    @billto = VENDOR,
    @stat = STAT,
    @pay = PAY
  from PAYVDR
  where NUM = @num
  if @stat <> 0
  begin
    raiserror('审核的不是未审核的单据.', 16, 1)
    return (1)
  end
  update PAYVDR
  set FILDATE = GETDATE(), SETTLENO = @cur_settleno, STAT = 1
  where NUM = @num
  if @cls = '付款'
    insert into ZK (ADATE, ASETTLENO, BWRH, BVDRGID, BGDGID, FK_A)
    values (@cur_date, @cur_settleno, @wrh, @billto, 1, @pay)
  else
    insert into ZK (ADATE, ASETTLENO, BWRH, BVDRGID, BGDGID, YFKT_A)
    values (@cur_date, @cur_settleno, @wrh, @billto, 1, @pay)
  return (0)
end
GO
