SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO
create procedure [dbo].[STKINPAY] (
  @cls char(10),
  @num char(10)
) with encryption as
begin
  declare
    @stat smallint,
    @vdrnum char(10),
    @settleno int,
    @fildate datetime,
    @filler int,
    @checker int,
    @wrh int,
    @billto int,
    @amt money,
    @gdgid int,
    @qty money,
    @price money,
    @line smallint,
    @inprc money,
    @rtlprc money,
    @payqty money

  select
    @vdrnum = VENDORNUM,
    @stat = STAT,
    @settleno = SETTLENO,
    @fildate = FILDATE,
    @filler = FILLER,
    @checker = CHECKER,
    @billto = BILLTO,
    @amt = TOTAL
  from STKIN
  where CLS = @cls and NUM = @num

  if @stat <> 1 begin
    raiserror('不能将未审核的单据转成结算单', 16, 1)
    return 1
  end
  if (@vdrnum is null) or @vdrnum = '' begin
    raiserror('请填写对方单号(发票号码)', 16, 1)
    return 1
  end
  if exists (
    select GDGID
    from STKINDTL S, GOODS G
    where S.CLS = @cls
    and S.NUM = @num
    and S.GDGID = G.GID
    and G.SALE <> 1
  ) begin
    raiserror('本进货单中存在非经销商品, 不能转成结算单', 16, 1)
    return 1
  end
  if (
    select count(distinct WRH)
    from STKINDTL
    where CLS = @cls and NUM = @num
  ) > 1 begin
    raiserror('本进货单中存在多仓位,不能转成结算单', 16, 1)
    return 1
  end

  select @wrh = WRH
  from STKINDTL
  where NUM = @num and CLS = @cls and LINE = 1

  insert into PAY (NUM, SETTLENO, FILDATE, FILLER, CHECKER,
    WRH, BILLTO, AMT, STAT )
  values (@vdrnum, @settleno, @fildate, @filler, @checker,
    @wrh, @billto, @amt, 0 )
  declare c_stkindtl cursor for
    select GDGID, QTY, PRICE, LINE, INPRC, RTLPRC, PAYQTY
    from STKINDTL
    where CLS = @cls and NUM = @num
  open c_stkindtl
  fetch next from c_stkindtl into
    @gdgid, @qty, @price, @line, @inprc, @rtlprc, @payqty
  while @@fetch_status = 0 begin
    insert into PAYDTL (NUM, LINE, SETTLENO, GDGID,
      QTY, TOTAL, STOTAL, NPQTY, NPTOTAL, NPSTOTAL, INPRC, RTLPRC)
    values (@vdrnum, @line, @settleno, @gdgid,
      @qty, @qty * @price, 0, 0, 0, 0, @inprc, @rtlprc)
    insert into PAYIN (CLS, STKINNUM, STKINLINE, PAYNUM, PAYLINE, QTY,PRC,NPQTY)
    values (@cls, @num, @line, @vdrnum, @line, @qty, @price, 0)
    update STKINDTL set PAYQTY = QTY
    where CLS = @cls and NUM = @num and LINE = @line
    fetch next from c_stkindtl into
      @gdgid, @qty, @price, @line, @inprc, @rtlprc, @payqty
  end
  close c_stkindtl
  deallocate c_stkindtl
end
GO
