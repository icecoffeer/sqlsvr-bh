SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKDTLDLT](
  @m_wrh int,
  @d_settleno int,
  @d_gdgid int,
  @d_qty money,
  @d_total money,
  @d_subwrh int
) with encryption as
begin
  declare
    @t_line int,
    @t_acntqty money,
    @t_qty money,
    @t_acnttl money,
    @t_total money,
    @t_inprc money,
    @t_rtlprc money,
    @t_ovfamt money,
    @t_losamt money,
    @prctype smallint
   select
    @t_acntqty = ACNTTL,
    @t_qty = QTY,
    @t_acnttl = ACNTTL,
    @t_total = TOTAL,
    @t_rtlprc = RTLPRC
    from PCKS where GDGID = @d_gdgid and WRH = @m_wrh and subwrh = @d_subwrh
  if @@rowcount = 0 begin
    raiserror('没有找到汇总资料!', 16, 1)
    return(1)
  end
  select @t_qty = @t_qty - @d_qty, @t_total = @t_total - @d_total
  select @prctype = PRCTYPE from GOODS where GID = @d_gdgid
  if @prctype = 1 begin
    if @t_total > @t_acnttl
      select @t_losamt = 0, @t_ovfamt = @t_total - @t_acnttl
    else
      select @t_losamt = @t_acnttl - @t_total, @t_ovfamt = 0
  end else begin
    if @t_qty > @t_acntqty
      select @t_losamt = 0, @t_ovfamt = (@t_qty-@t_acntqty)*@t_rtlprc
    else
      select @t_losamt = (@t_acntqty)*@t_rtlprc, @t_ovfamt = 0
  end
  /*
  if @t_qty = 0 and @t_total = 0 begin
    delete from PCKS where WRH = @m_wrh and GDGID = @d_gdgid
  小包装商品被删除后，大包装商品转换成的小包装商品将找不到
  或两张单子上该商品实盘为0，一张被删除将引起另一张不能删除
  end else begin
  */
    update PCKS set
      QTY = @t_qty, TOTAL = @t_total,
      LOSAMT = @t_losamt, OVFAMT = @t_ovfamt
    where WRH = @m_wrh and GDGID = @d_gdgid  and subwrh = @d_subwrh
  /* end */

end
GO
