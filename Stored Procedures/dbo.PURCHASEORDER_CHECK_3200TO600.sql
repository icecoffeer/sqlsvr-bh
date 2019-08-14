SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create Procedure [dbo].[PURCHASEORDER_CHECK_3200TO600]
(
  @NUM CHAR(14),
  @OPER CHAR(30),
  @CLS CHAR(10),
  @TOSTAT INT,
  @MSG VARCHAR(255) OUTPUT
)
with Encryption
as
begin
  declare
    @cur_date datetime,
    @cur_settleno int,
    @fildate datetime,
    @settleno int,
    @wrh int,
    @gdgid int,
    @billto int,
    @psr int,
    @qty money,
    @price money,
    @total money,
    @tax money,
    @loss money,
    @inprc money,
    @rtlprc money,
    @acnt smallint,
    @return_status int

  select @cur_settleno = MAX(NO) from MONTHSETTLE
  select
    @cur_date = convert(datetime, convert(char, getdate(), 102)),
    @settleno = SETTLENO,
    @fildate = FILDATE,
    @wrh = WRH,
    @billto = VENDOR,
    @psr = PSR,
    @acnt = 1,
    @loss = 0
  from PURCHASEORDER where CLS = @cls and NUM = @num

  declare c_cursor cursor for
    select p.GDGID, p.ARVQTY, p.PRICE, p.TOTAL, p.TAX, g.inprc, g.rtlprc
    from PURCHASEORDERDTL p(nolock), goodsh g(nolock)
    where p.CLS = @CLS and p.NUM = @NUM and p.gdgid = g.gid
  open c_cursor
  fetch next from c_cursor into
    @gdgid, @qty, @price, @total, @tax, @inprc, @rtlprc
  while @@fetch_status = 0
  begin
    execute @return_status = PURCHASEORDERDTLCRT
      @cur_date, @cur_settleno, @fildate, @settleno,
      @cls, @wrh, @gdgid, @billto, @psr, @qty, @price,
      @total, @tax, @loss, @inprc, @rtlprc, @acnt

    if @return_status <> 0 break

    fetch next from c_cursor into
      @gdgid, @qty, @price, @total, @tax, @inprc, @rtlprc
  end
  close c_cursor
  deallocate c_cursor



  update PURCHASEORDER set Stat = @ToStat, LSTUPDTIME = getdate()
  where num = @NUM and cls = @CLS

  EXEC PURCHASEORDERADDLOG @NUM, @CLS, 600, '复核', @OPER
  return(0)
end
GO
