SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSIPADTLONE](
	@p_cls char(10),
	@p_num char(10),
	@p_line smallint,
	@p_bill char(10),
	@p_billcls char(10),
	@p_billnum char(10),
	@p_billline smallint,
	@p_billsrcnum char(10),
	@p_subwrh int,
	@p_newprc money,
	@p_qty money,
	@p_adjdate datetime,
	@p_src int,
	@cur_settleno int,
	@usergid int,
	@err_msg varchar(200) = '' output
) as
begin
  declare 
  	@ret_status int,
  	@o_incost money,
  	@o_outcost money,
  	@o_amt money,
  	@o_adjincost money,
  	@o_adjoutcost money,
  	@o_adjamt money,
  	@o_wrh int

  select @ret_status = 0
      
  -- 取得原单据已经发生的成本调整
  select @o_incost = isnull(sum(ADJINCOST), 0),
    @o_outcost = isnull(sum(ADJOUTCOST), 0),
    @o_amt = isnull(sum(ADJAMT), 0)
    from INPRCADJDTL
    where STORE = @usergid and BILL = @p_bill and BILLCLS = @p_billcls
      and BILLNUM = @p_billnum and BILLLINE = @p_billline
      and LACTIME is not null
      
  select @o_adjincost = 0, @o_adjoutcost = 0, @o_adjamt = 0
  
  -- 取得原单据成本，得到调价前的单据成本
  select @o_incost = 0, @o_outcost = 0, @o_amt = 0
  if @p_bill = 'STKIN'
    select @o_incost = QTY * PRICE + @o_incost,
      @o_adjincost = round(@p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
      @o_wrh = WRH
      from STKINDTL
      where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
  else if @p_bill = 'STKINBCK'
    select @o_incost = - QTY * INPRC + @o_incost,
      @o_adjincost = round(- @p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
      @o_wrh = WRH
      from STKINBCKDTL
      where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
  else if @p_bill = 'STKOUT'
    select @o_outcost = QTY * INPRC + @o_outcost, 
      @o_adjoutcost = round(@p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
      @o_amt = case @p_billcls when '配货' then TOTAL + @o_amt else 0 end,
      @o_adjamt = case @p_billcls when '配货'
        then round(@p_qty * @p_newprc + @o_amt * (QTY - @p_qty) / QTY - @o_amt, 2)
        else 0 end,
      @o_wrh = WRH
      from STKOUTDTL
      where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
  else if @p_bill = 'STKOUTBCK'
    select @o_outcost = - QTY * INPRC + @o_outcost,
      @o_adjoutcost = round(- @p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
      @o_amt = case @p_billcls when '配货' then - TOTAL + @o_amt else 0 end,
      @o_adjamt = case @p_billcls when '配货'
        then round(@p_qty * @p_newprc + @o_amt * (QTY - @p_qty) / QTY - @o_amt, 2)
        else 0 end,
      @o_wrh = WRH
      from STKOUTBCKDTL
      where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
  else if @p_bill = 'RTL'
  begin
    select @o_outcost = QTY * INPRC + @o_outcost,
      @o_adjoutcost = round(@p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2)
      from RTLDTL
      where NUM = @p_billnum and LINE = @p_billline
    select @o_wrh = WRH
      from RTL where NUM = @p_billnum
  end
  else if @p_bill = 'RTLBCK'
  begin
    select @o_outcost = - QTY * INPRC + @o_outcost,
      @o_adjoutcost = round(- @p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2)
      from RTLBCKDTL
      where NUM = @p_billnum and LINE = @p_billline
    select @o_wrh = WRH
      from RTLBCK where NUM = @p_billnum
  end
  else --if @p_bill = 'DIRALC'
  begin
    if @p_billcls = '直配进'
      select @o_incost = QTY * ALCPRC + @o_incost,
        @o_adjincost = round(@p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
    else if @p_billcls = '直配进退'
      select @o_incost = - QTY * INPRC + @o_incost,
        @o_adjincost = round(- @p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
    else if @p_billcls = '直配出'
      select @o_incost = QTY * PRICE + @o_incost, 
        @o_adjincost = round(@p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_outcost = QTY * INPRC + @o_outcost, 
        @o_adjoutcost = round(@p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
        @o_amt = ALCAMT + @o_amt,
        @o_adjamt = round(@p_qty * @p_newprc + @o_amt * (QTY - @p_qty) / QTY - @o_amt, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
    else if @p_billcls = '直配出退'
      select @o_incost = - QTY * PRICE + @o_incost, 
        @o_adjincost = round(- @p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_outcost = - QTY * INPRC + @o_outcost, 
        @o_adjoutcost = round(- @p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
        @o_amt = - ALCAMT + @o_amt,
        @o_adjamt = round(- @p_qty * @p_newprc + @o_amt * (QTY - @p_qty) / QTY - @o_amt, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
    else if @p_billcls = '直销'
      select @o_incost = QTY * PRICE + @o_incost, 
        @o_adjincost = round(@p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_outcost = QTY * INPRC + @o_outcost,
        @o_adjoutcost = round(@p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
    else --if @p_billcls = '直销退'
      select @o_incost = - QTY * PRICE + @o_incost, 
        @o_adjincost = round(- @p_qty * @p_newprc + @o_incost * (QTY - @p_qty) / QTY - @o_incost, 2),
        @o_outcost = - QTY * INPRC + @o_outcost,
        @o_adjoutcost = round(- @p_qty * @p_newprc + @o_outcost * (QTY - @p_qty) / QTY - @o_outcost, 2),
        @o_wrh = WRH
        from DIRALCDTL
        where CLS = @p_billcls and NUM = @p_billnum and LINE = @p_billline
  end
  
  insert into INPRCADJDTL(
    CLS, NUM, LINE, SETTLENO, STORE,
    BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
    QTY, INCOST, OUTCOST, AMT, ADJINCOST,
    ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
    NOTE, WRH)
    values (
    @p_cls, @p_num, @p_line, @cur_settleno, @usergid,
    @p_bill, @p_billcls, @p_billnum, @p_billline, @p_subwrh,
    @p_qty, @o_incost, @o_outcost, @o_amt, @o_adjincost,
    @o_adjoutcost, @o_adjamt, @p_src, null, @p_billsrcnum,
    null, @o_wrh)

  return(@ret_status)
end

GO
