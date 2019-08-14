SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[UPDSTKOUTPRC_ALC](
  @cls char(10),
  @num char(10)
) as
begin
  declare @d_line smallint, @d_gdgid int, @d_qty money,
    @opt_value int, @g_cntinprc money, @g_taxrate money,
    @d_price money, @d_wrh int, @gw_qty money,
    @gw_invcost money, @d_total money

  exec OPTREADINT 0, 'InitInvPrc', 1, @opt_value output

  declare c cursor for
    select s.LINE, s.GDGID, s.QTY, s.WRH
    from STKOUTDTL s(nolock)
    where CLS = @cls and NUM = @num
    for read only
  open c
  fetch next from c into @d_line, @d_gdgid, @d_qty, @d_wrh
  while @@fetch_status = 0
  begin
  	select @g_taxrate = TAXRATE, @g_cntinprc = CNTINPRC
  	  from GOODS (nolock)
  	  where GID = @d_gdgid
  	select @gw_qty = QTY
  	  from INV(nolock)
  	  where GDGID = @d_gdgid and WRH = @d_wrh
  	if @@rowcount = 0 set @gw_qty = 0
  	select @d_price = INVPRC, @gw_invcost = INVCOST
  	  from GDWRH(nolock)
  	  where GDGID = @d_gdgid and WRH = @d_wrh
  	if @@rowcount = 0
  	begin
  	  if @opt_value = 1
  	    set @d_price = @g_cntinprc
  	  else
  	    set @d_price = 0
  	end
  	if @gw_qty - @d_qty = 0
  	  set @d_total = @gw_invcost
  	else if @gw_qty = 0
  	  set @d_total = round(@d_qty * @d_price, 2)
  	else
  	  set @d_total = round(@d_qty * @gw_invcost / @gw_qty, 2)
  	update STKOUTDTL set
  	  PRICE = @d_total / @d_qty, TOTAL = @d_total,
  	  TAX = round(@d_total * @g_taxrate / (100 + @g_taxrate), 2)
  	  where CLS = @cls and NUM = @num and LINE = @d_line
  	fetch next from c into @d_line, @d_gdgid, @d_qty, @d_wrh
  end
  close c
  deallocate c

  update STKOUT set
    TOTAL = (select sum(TOTAL) from STKOUTDTL(nolock) where CLS = @cls and NUM = @num),
    TAX = (select sum(TAX) from STKOUTDTL(nolock) where CLS = @cls and NUM = @num)
    where CLS = @cls and NUM = @num

  return(0)
end
GO
