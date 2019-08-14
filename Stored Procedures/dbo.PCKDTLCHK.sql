SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCKDTLCHK](
  @m_wrh int,
  @d_settleno int,
  @d_gdgid int,
  @d_qty money,
  @d_total money,
  @d_subwrh  int
) with encryption as
begin
  declare
    @return_status int,
    @t_line int,
    @t_acntqty money,
    @t_qty money,
    @t_acnttl money,
    @t_total money,
    @t_inprc money,
    @t_rtlprc money,
    @t_ovfamt money,
    @t_losamt money,
    @prctype smallint,
    @e_gdgid int,
    @mult money

  select @t_line = null
  if @d_subwrh = 0
       select @t_line = LINE from PCKS where GDGID = @d_gdgid and WRH = @m_wrh
  else
        select @t_line = line from pcks where gdgid = @d_gdgid and wrh =@m_wrh and subwrh =@d_subwrh
  if @t_line is null begin
--    select @t_line = max(LINE)+1 from PCKS
--    if @t_line is null select @t_line = 1
  if @d_subwrh = 0
    select
      @t_acntqty = QTY,
      @t_acnttl = TOTAL,
      @t_inprc = INPRC,
      @t_rtlprc = RTLPRC
      from CKINV where WRH = @m_wrh and GDGID = @d_gdgid
    else
      select @t_acntqty =qty,@t_acnttl = total ,@t_inprc = inprc, @t_rtlprc=rtlprc
             from ckswi  where gdgid = @d_gdgid and wrh =@m_wrh and subwrh =@d_subwrh

    if @@rowcount = 0 begin
      select @t_acntqty = 0, @t_acnttl = 0
      select @t_inprc = INPRC, @t_rtlprc = RTLPRC
        from GOODS where GID = @d_gdgid
    end
      insert into PCKS ( SETTLENO, GDGID, WRH, ACNTQTY, QTY,
      ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh)
      values ( @d_settleno, @d_gdgid, @m_wrh, @t_acntqty, 0,
      @t_acnttl, 0, 0, 0, @t_inprc, @t_rtlprc,@d_subwrh)
      select @t_line = line from pcks where wrh=@m_wrh and gdgid=@d_gdgid and subwrh = @d_subwrh

  end

  if (select ISPKG from GOODS where GID = @d_gdgid) = 1
  begin
    /* 如果该商品是大包装的,进行转换 */
    execute @return_status = GETPKG @d_gdgid, @e_gdgid output, @mult output
    /* 99-10-20: getpkg return 1 if found, not 0. */
    if @return_status <> 1   Return(@Return_status)
    select @return_status = 0
    select @d_gdgid = @e_gdgid, @d_qty = @d_qty * @mult--, @d_total = @d_total * @mult  Modified by qyx  2002-04-08
    /* 2000-1-27 */
    select @t_line = null
    select @t_line = LINE from PCKS where GDGID = @d_gdgid and WRH = @m_wrh and subwrh =@d_subwrh
    if @t_line is null begin
      /* 2000-1-27
      select @t_line = max(LINE)+1 from PCKS
      if @t_line is null select @t_line = 1
      */
      if @d_subwrh =0
       select
        @t_acntqty = QTY,
        @t_acnttl = TOTAL,
        @t_inprc = INPRC,
        @t_rtlprc = RTLPRC
        from CKINV where WRH = @m_wrh and GDGID = @d_gdgid
      else
        select @t_acntqty = qty , @t_acnttl =total, @t_inprc =inprc ,@t_rtlprc = rtlprc
        from ckswi where wrh = @m_wrh and gdgid =@d_gdgid and subwrh = @d_subwrh
      if @@rowcount = 0 begin
        select @t_acntqty = 0, @t_acnttl = 0
        select @t_inprc = INPRC, @t_rtlprc = RTLPRC
          from GOODS where GID = @d_gdgid
      end
      insert into PCKS ( SETTLENO, GDGID, WRH, ACNTQTY, QTY,
        ACNTTL, TOTAL, OVFAMT, LOSAMT, INPRC, RTLPRC,subwrh )
        values ( @d_settleno, @d_gdgid, @m_wrh, @t_acntqty, 0,
        @t_acnttl, 0, 0, 0, @t_inprc, @t_rtlprc,@d_subwrh)
      select @t_line = line from pcks where wrh=@m_wrh and gdgid=@d_gdgid and subwrh =@d_subwrh
    end
  end

  select @prctype = PRCTYPE from GOODS where GID = @d_gdgid
  select
    @t_acntqty = ACNTQTY,
    @t_qty = QTY,
    @t_acnttl = ACNTTL,
    @t_total = TOTAL,
    @t_rtlprc = RTLPRC
    from PCKS where GDGID = @d_gdgid and WRH = @m_wrh and subwrh = @d_subwrh
  select
    @t_qty = @t_qty + @d_qty,
    @t_total = @t_total + @d_total
  if @prctype = 1 begin
    if @t_total > @t_acnttl
      select @t_losamt = 0, @t_ovfamt = @t_total - @t_acnttl
    else
      select @t_losamt = @t_acnttl - @t_total, @t_ovfamt = 0
  end else begin
    if @t_qty > @t_acntqty
      select @t_losamt = 0, @t_ovfamt = (@t_qty-@t_acntqty)*@t_rtlprc
    else
      select @t_losamt = (@t_acntqty-@t_qty)*@t_rtlprc, @t_ovfamt = 0
  end
  update PCKS set
    QTY = @t_qty, TOTAL = @t_total,
    LOSAMT = @t_losamt, OVFAMT = @t_ovfamt
    where WRH = @m_wrh and GDGID = @d_gdgid  and subwrh = @d_subwrh
  update PCKDTL set STAT = 0, CKNUM = NULL, CKLINE = @t_line
    where current of c_pck
    /* 注意,必须使用CURRENT OF.
    原因之一是可能有多条记录具有相同的WRH和GDGID
    原因之二是该商品可能是大包装商品转换的 */
end
GO
