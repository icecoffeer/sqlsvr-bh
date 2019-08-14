SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[StkOutChkRegLack]
  /* 指示记录缺货列表和/或出货单 */
  @ckinv int,
  /* 商品信息 */
  @gdgid int,
  @price money,
  @inprc money,
  @rtlprc money,
  @wsprc money,
  @taxrate money,
  @qpc money,
  @gftflag int,
  /* 库存信息 */
  @wrh int,
  @invqty money,
  @invtotal money,
  /* 出货前 */
  @qty money,
  @total money,
  /* 实际出货 */
  @lackqty money,
  @lacktotal money,
  /* 缺货 */
  @cls char(10),
  @num char(10),
  @store int,
  @cur_settleno int,
  @client int,
  @slr int,
  @filler int,
  /* 由哪张单子产生的及该单据信息 */
  @ordnum char(10),
  @outnum char(10) output,
  /* 记录缺货的出货单号 */
  @qhdpaddmode smallint = 0   /*缺货待配累加或覆盖*/
With Encryption
As
begin
  declare @return_status int,
          @lacknum char(10), @lackline int,
          @lacktax money,
          @mtotal money,     @mtax money,
          @note varchar(100),  --Modified by Wang Xin 2002-04-01
          @maxline int         --Added by Jianweicheng 回写配货池 2003.01.03
  select @return_status = 0
  /* 记缺货列表和/或缺货单 */
  if (@ckinv & 1) <> 0
  begin
    /* 记缺货列表:增加一条记录 */
    insert into GDLACK (GDGID, WRH, ACNTQTY, ACNTTOTAL,REQQTY, REQTOTAL, BILLNUM, BILLCLS)
    values (@gdgid, @wrh, @invqty-@qty, @invtotal-@total, @lackqty, @lacktotal, @num, @cls)
  end
  if (@ckinv & 2) <> 0
  begin
    /* 记在同类型的未审核的备注='缺货待配'的单据上:新增或更新 */
    select @lacknum = null
    select @lacknum = num
    from stkout(nolock)
    where cls = @cls and client = @client and stat = 0 and wrh = @wrh and note = '缺货待配'
    if @lacknum is null
    begin
      select @lacknum = (select max(num) from stkout(nolock) where cls = @cls)
      if @lacknum is null select @lacknum = '0000000001'
      else execute nextbn @lacknum, @lacknum output
      while 1=1
      begin
        insert into stkout (cls, num, client, ocrdate, stat, billto,
                           filler, wrh, fildate, slr, src,
                           reccnt, total, tax, note, settleno, ordnum)
        values (@cls, @lacknum, @client, getdate(), 0, @client,
               @filler, @wrh, getdate(), @slr, @store,
               0, 0, 0, '缺货待配', @cur_settleno, @ordnum)
        if @@error = 0 break
        else execute nextbn @lacknum, @lacknum output
      end
    end
    select @lackline = null
    select @lackline = line
    from stkoutdtl(nolock)
    where cls = @cls and num = @lacknum and gdgid = @gdgid
    if @lackline is null
    begin
      select @lackline =
             (select max(line) from stkoutdtl(nolock) where cls = @cls and num = @lacknum)
      if @lackline is null select @lackline = 1
      else select @lackline = @lackline + 1
      insert into stkoutdtl (CASES, CLS, GDGID, INPRC, INVQTY, LINE, NUM, PRICE, QTY,
        RTLPRC, SETTLENO, TAX, TOTAL, VALIDDATE, WRH, WSPRC, gftflag)
      values (0, @cls, @gdgid, @inprc, 0, @lackline,
             @lacknum, @price, 0, @rtlprc, @cur_settleno,
             0, 0, null, @wrh, @wsprc, @gftflag)
      update stkout set reccnt = reccnt + 1 where cls = @cls and num = @lacknum
    end
    if @qhdpaddmode = 1  /*累加*/
      select @lackqty = @lackqty + qty
      from stkoutdtl(nolock)
      where cls = @cls and num = @lacknum and line = @lackline

    select @lacktotal = round(@lackqty * @price, 2)
    select @lacktax = @lacktotal - round(@lacktotal/(1+@taxrate/100), 2)
    select @note = NOTE from STKOUT(nolock) where cls = @cls and num = @num    --Added By Wang Xin 2002-04-01
    update stkoutdtl
      set qty = @lackqty, total = @lacktotal, tax = @lacktax,
          inprc = @inprc, rtlprc = @rtlprc, wsprc = @wsprc, /* 2001-1-12*/ cases = @lackqty / @qpc,
          note = @num + '  ' + rtrim(@note)                --Modified By Wang Xin 2002-04-01
      where cls = @cls and num = @lacknum and line = @lackline
    select @mtotal = sum(total), @mtax = sum(tax)
      from stkoutdtl(nolock)
      where cls = @cls and num = @lacknum
    update stkout
      set ocrdate = getdate(), total = @mtotal, tax = @mtax
      where cls = @cls and num = @lacknum
    select @outnum = @lacknum
  end
  if (@ckinv & 4) <> 0  --Added by Jianweicheng 回写配货池 2003.01.03
  begin
        select @maxline = max(line) from AlcPool(nolock)
                where storegid = @client and gdgid = @gdgid
        if @maxline is null
                set @maxline = 1
        else
                set @maxline = @maxline + 1
        Insert into Alcpool(storegid, gdgid, line, qty, dmddate, srcgrp, srcbill, srccls, srcnum, srcline, ordtime)
                values(@client, @gdgid, @maxline, @lackqty, convert(varchar(10), getdate(), 102), 2,
                '配货回写', @cls, @num, null, getdate())
  end
  return(@return_status)
end
GO
