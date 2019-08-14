SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[StkOutChkUnLoad]
  @gendsp smallint,
  @wrh int,
  @subwrh int,
  @gdgid int,
  @qty money,
  @rtlprc money,
  @validdate datetime,
  @qpc money,
  @gftflag int,
  @ckord smallint, @avalt float,
  @ordqty money,
  @price money, @inprc money, @wsprc money, @taxrate money,
  @cls char(10), @num char(10),
  @store int,  @cur_settleno int,
  @client int, @slr int, @filler int,
  @ordnum char(10),

  @dsp_num char(10),
  @line int
as begin
  declare @return_status int, @lackratio money, @total money,
          @ordtotal money, @lackqty money, @lacktotal money,
          @outnum char(10)
  select @return_status = 0
  if (@subwrh is not null) /* 00-3-3 and (@gendsp = 0) */
  begin
    execute @return_status = UNLOADSUBWRH @wrh, @subwrh, @gdgid, @qty
    if @return_status <> 0 return(@return_status)
  end
  execute @return_status = UNLOAD @wrh, @gdgid, @qty, @rtlprc, @validdate

  /* 2000-10-23 */
  select @total = @qty * @price

  if @ckord <> 0
  begin
    if @ordqty <> 0 
      select @lackratio = (@ordqty - @qty) / @ordqty * 100
    else
      select @lackratio = 0;
    if @qty < 0 select @lackratio = -1
    if @lackratio > @avalt
    begin
      select @ordtotal = @ordqty * @price,
             @lackqty = @ordqty - @qty,
             @lacktotal = @lackqty * @price,
             @total = @qty * @price
      execute @return_status = StkOutChkRegLack
              @ckord,
              @gdgid, @price, @inprc, @rtlprc, @wsprc, @taxrate, @qpc, @gftflag,
              @wrh, @ordqty, @ordtotal, @qty, @total, @lackqty, @lacktotal,
              @cls, @num, @store, @cur_settleno, @client, @slr, @filler,
              @ordnum,
              @outnum output
    end
  end
  /* 2000-10-12 从StkOutChk中移动到这里*/
  if @gendsp = 1 /* 2000-10-27 */ and @qty <> 0
  begin
    insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
      SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE,  SUBWRH )
    values ( @dsp_num, @line, @line, @gdgid, @total/@qty, @qty,
      @total, 0, 0, 0, null, @subwrh )
    execute @return_status = IncDspQty @wrh, @gdgid, @qty, @subwrh
  end
  return(@return_status)
end
GO
