SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdInvChgDLTNum]
  @num char(10),
  @new_oper int,
  @neg_num char(10),
  @errmsg varchar(200) = '' output
with encryption as
begin
  declare
    @cur_date datetime,      @cur_settleno int,         @return_status int,
    @m_stat smallint

  select
    @cur_settleno = (select max(NO) from MONTHSETTLE),
    @cur_date = convert(datetime, convert(char(10), getdate(), 102)),
    @m_stat = STAT
    from GDINVCHG where NUM = @num

  if @m_stat <> 1
  begin
    raiserror('被冲单的不是已审核单据', 16, 1)
    return 1
  end

  update GDINVCHG set STAT = 2 where NUM = @num

  insert into GDINVCHG (NUM, SETTLENO, TOTAL, TAX, FILDATE, FILLER, CHECKER, STAT,
	  MODNUM, PSR, RECCNT, PRNTIME, PRECHECKER, PRECHKDATE, NOTE)
  select @neg_num, @cur_settleno, -TOTAL, -TAX, getdate(), @new_oper, @new_oper, 0,
	  @num,   PSR, RECCNT, null, PRECHECKER, PRECHKDATE, NOTE
  from GDINVCHG
  where NUM = @num

  insert into GDINVCHGDTL (NUM, LINE, GDGID, GDGID2, CASES, QTY, WRH, WRH2,
    PRICE, TOTAL, TAX, INPRC, RTLPRC, INPRC2, RTLPRC2, QTY2, CASES2, RELQTY, PRICE2)
  select @neg_num, LINE, GDGID, GDGID2, -CASES, -QTY, WRH, WRH2,
    PRICE, -TOTAL, -TAX, INPRC, RTLPRC, INPRC2, RTLPRC2, -QTY2, -CASES2, RELQTY, PRICE2
  from GDINVCHGDTL D
  where D.NUM = @num

  execute @return_status = GdInvChgCHK @neg_num, 1
  if @return_status <> 0 return @return_status
  update GDINVCHG set STAT = 4 where NUM = @neg_num

  return @return_status
end
GO
