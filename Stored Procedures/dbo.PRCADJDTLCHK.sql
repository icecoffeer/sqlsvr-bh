SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
cREATE procedure [dbo].[PRCADJDTLCHK](
  @cur_date datetime,
  @cur_settleno int,
  @d_cls char(8),
  @d_num char(10),
  @d_line smallint,
  @d_gdgid int,
  @d_gdqpcstr char(15),
  @d_gdqpc money,
  @d_newprc money,
  @d_adjamt money output
) with encryption as
begin
  declare
    @iwrh int,
    @qty money,
    @t_qty money,
    @total money,
    @rtlprc money,
    @inprc money,
    @dxprc money,
    @lwtrtlprc money,
    @mbrprc money,
    @whsprc money,
    @payrate money,
    @cntinprc money,
    @sale smallint,
    @s_usergid int,
    @date datetime,
    @yno int,
    @score money,
    @InvPrc money,
    @g_invcost money,  --2002-06-13
    @m_wrh int    --2002-09-30

  select @s_usergid = USERGID from system
  select @date = convert(datetime, convert(char, @cur_date, 102))
  select @yno = yno from v_ym where mno = @cur_settleno

  if @d_cls = '核算售价' begin

    select @sale = SALE, @rtlprc = isnull(QPCRTLPRC, 0),
      @payrate = isnull(PAYRATE, 75)
      from V_QPCGOODS where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
    declare c_wrh cursor for
      select WRH, sum(QTY), sum(TOTAL)
      from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
      group by WRH
      for read only
    open c_wrh
    fetch next from c_wrh into @iwrh, @qty, @total
    select @t_qty = 0
    while @@fetch_status = 0 begin
      select @t_qty = @t_qty + @qty
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
        values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc)))
      update INV set TOTAL = TOTAL + convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc))
        where GDGID = @d_gdgid and STORE = @s_usergid and WRH = @iwrh

      -- 库存报表
      execute CRTINVRPT @s_usergid, @cur_settleno, @date, @iwrh, @d_gdgid
      update INVDRPT
        set FT = FT + convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc)),
        LSTUPDTIME = getdate()
        where INVDRPT.ASETTLENO = @cur_settleno and INVDRPT.ADATE = @date
        and INVDRPT.ASTORE = @s_usergid and INVDRPT.BWRH = @iwrh and INVDRPT.BGDGID = @d_gdgid
      update INVMRPT
        set FT = FT + convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc))
        where INVMRPT.ASETTLENO = @cur_settleno and INVMRPT.ASTORE = @s_usergid
        and INVMRPT.BWRH = @iwrh and INVMRPT.BGDGID = @d_gdgid
      update INVYRPT
        set FT = FT + convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc))
        where INVYRPT.ASETTLENO = @yno and INVYRPT.ASTORE = @s_usergid
        and INVYRPT.BWRH = @iwrh and INVYRPT.BGDGID = @d_gdgid

      if @sale = 3
      begin
        insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
          convert(decimal(20, 2), @qty / @d_gdqpc * (@d_newprc - @rtlprc) * @payrate / 100.00))
        /* 2001.1.10
        update INV set
          TOTAL = TOTAL + convert(decimal(20, 2), @qty * (@d_newprc - @rtlprc) * @payrate / 100.00)
          where GDGID = @d_gdgid and STORE = @s_usergid and WRH = @iwrh */
      end
      fetch next from c_wrh into @iwrh, @qty, @total
    end
    close c_wrh
    deallocate c_wrh

    if @d_gdqpcstr = '1*1'
    begin
      update GOODS set RTLPRC = @d_newprc, LSTUPDTIME = getdate() where GID = @d_gdgid
      update GDQPC set RTLPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr
    end
    else
      update GDQPC set RTLPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr

    update PRCADJDTL set
      OLDPRC = @rtlprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line

  end else if @d_cls = '核算价' begin

    select @inprc = isnull(INPRC, 0) from GOODS
      where GID = @d_gdgid
    declare c_wrh cursor for
      select WRH, sum(QTY), sum(TOTAL)
      from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
      group by WRH
      for read only
    open c_wrh
    fetch next from c_wrh into @iwrh, @qty, @total
    select @t_qty = 0
    while @@fetch_status = 0 begin
      select @t_qty = @t_qty + @qty
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @inprc)) )
      fetch next from c_wrh into @iwrh, @qty, @total
    end
    close c_wrh
    deallocate c_wrh
    update GOODS set INPRC = @d_newprc where GID = @d_gdgid
    update PRCADJDTL set
      OLDPRC = @inprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line

  end else if @d_cls = '最低售价' begin

    select @t_qty = sum(QTY) from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
    if @t_qty is null select @t_qty = 0
    select @lwtrtlprc = QPCLWTRTLPRC from V_QPCGOODS
      where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
    if @lwtrtlprc is null select @lwtrtlprc = 0
    update PRCADJDTL set
      OLDPRC = @lwtrtlprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line

    if @d_gdqpcstr = '1*1'
    begin
      update GOODS set LWTRTLPRC = @d_newprc where GID = @d_gdgid
      update GDQPC set LWTRTLPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr
    end
    else
      update GDQPC set LWTRTLPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr

  end else if @d_cls = '会员价' begin

    select @t_qty = sum(QTY) from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
    if @t_qty is null select @t_qty = 0
    select @mbrprc = QPCMBRPRC from V_QPCGOODS
      where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
    if @mbrprc is null select @mbrprc = 0
    update PRCADJDTL set
      OLDPRC = @mbrprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    if @d_gdqpcstr = '1*1'
    begin
      update GOODS set MBRPRC = @d_newprc where GID = @d_gdgid
      update GDQPC set MBRPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr
    end
    else
      update GDQPC set MBRPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr

  end else if @d_cls = '批发价' begin

    select @t_qty = sum(QTY) from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
    if @t_qty is null select @t_qty = 0
    select @whsprc = QPCWHSPRC from V_QPCGOODS
      where GID = @d_gdgid and qpcqpcstr = @d_gdqpcstr
    if @whsprc is null select @whsprc = 0
    update PRCADJDTL set
      OLDPRC = @whsprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    if @d_gdqpcstr = '1*1'
    begin
      update GOODS set WHSPRC = @d_newprc where GID = @d_gdgid
      update GDQPC set WHSPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr
    end
    else
      update GDQPC set WHSPRC = @d_newprc where GID = @d_gdgid and QPCSTR = @d_gdqpcstr

  end else if @d_cls = '代销价' begin

    select @dxprc = isnull(DXPRC, 0) from GOODS where GID = @d_gdgid
    declare c_wrh cursor for
      select WRH, sum(QTY), sum(TOTAL)
      from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
      group by WRH
      for read only
    open c_wrh
    fetch next from c_wrh into @iwrh, @qty, @total
    select @t_qty = 0
    while @@fetch_status = 0 begin
      select @t_qty = @t_qty + @qty
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @dxprc)) )
      fetch next from c_wrh into @iwrh, @qty, @total
    end
    close c_wrh
    deallocate c_wrh
    update GOODS set DXPRC = @d_newprc where GID = @d_gdgid
    update PRCADJDTL set
      OLDPRC = @dxprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line

  end else if @d_cls = '联销率' begin

    select @rtlprc = isnull(RTLPRC, 0), @payrate = isnull(PAYRATE, 75)
      from GOODS where GID = @d_gdgid
    declare c_wrh cursor for
      select WRH, sum(QTY), sum(TOTAL)
      from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
      group by WRH
      for read only
    open c_wrh
    fetch next from c_wrh into @iwrh, @qty, @total
    select @t_qty = 0
    while @@fetch_status = 0 begin
      select @t_qty = @t_qty + @qty
      insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
        values (@cur_date, @cur_settleno, @iwrh, @d_gdgid, @qty,
        convert(decimal(20, 2), @qty * (@d_newprc - @payrate) / 100.00 * @rtlprc) )
      fetch next from c_wrh into @iwrh, @qty, @total
    end
    close c_wrh
    deallocate c_wrh
    update GOODS set PAYRATE = @d_newprc where GID = @d_gdgid
    update PRCADJDTL set
      OLDPRC = @payrate, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC) / 100.00 * @rtlprc)
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line

  end else if @d_cls = '合同进价' begin

    select @t_qty = sum(QTY) from INV
      where GDGID = @d_gdgid and STORE = @s_usergid
    if @t_qty is null select @t_qty = 0
    select @cntinprc = isnull(CNTINPRC, 0) from GOODS
      where GID = @d_gdgid
    update PRCADJDTL set
      OLDPRC = @cntinprc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), QTY * (NEWPRC - OLDPRC))
      from PRCADJDTL
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    update GOODS set CNTINPRC = @d_newprc where GID = @d_gdgid

  end else if @d_cls = '积分' begin     --add by CQH for 积分

    select @score = isnull(score,0) from gdscore
      where GDGID = @d_gdgid and STORE = @s_usergid
    update PRCADJDTL set OLDPRC = @score
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    if exists(select 1 from GDSCORE where GDGID = @d_gdgid and STORE = @s_usergid)
    update GDSCORE set SCORE = @d_newprc where GDGID = @d_gdgid and STORE = @s_usergid
    else
    insert into GDSCORE(STORE, GDGID, SCORE) values(@s_usergid, @d_gdgid, @d_newprc)
  end

  else if @d_Cls = '库存价' begin      --Added By Wang Xin 2002-03-11

    select @m_wrh = WRH from PRCADJ
      where CLS = @d_cls and NUM = @d_num
    select @g_invcost = INVCOST, @InvPrc = INVPRC from GDWRH
      where GDGID = @d_gdgid and WRH = @m_wrh
    select @t_qty = sum(QTY) from INV
      where GDGID = @d_gdgid and STORE = @s_usergid and WRH = @m_wrh
    insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
      values (@cur_date, @cur_settleno, @m_wrh, @d_gdgid, @t_qty,
      convert(decimal(20, 2), @t_qty * @d_newprc - @g_invcost) )
    update GDWRH set INVCOST = @t_qty * @d_newprc, INVPRC = @d_newprc
      where GDGID = @d_gdgid and WRH = @m_wrh
    if (select isnull(sum(QTY), 0) from INV where GDGID = @d_gdgid) <> 0
      update GOODS set
        INVPRC = (select isnull(sum(INVCOST), 0) from GDWRH where GDGID = @d_gdgid)
          / (select isnull(sum(QTY), 0) from INV where GDGID = @d_gdgid),
        INVCOST = (select isnull(sum(INVCOST), 0) from GDWRH where GDGID = @d_gdgid)
        where GID = @d_gdgid
    else
      update GOODS set
        INVCOST = 0
        where GID = @d_gdgid
    update PRCADJDTL set OLDPRC = @InvPrc, QTY = @t_qty
      where CLS = @d_cls and NUM = @d_num and LINE = @d_line
    select @d_adjamt = convert(decimal(20, 2), @t_qty * @d_newprc - @g_invcost)

  end
--Added End
end
GO
