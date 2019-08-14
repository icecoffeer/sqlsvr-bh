SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSIPAAINVDTL](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @line smallint,
    @usergid int,
    @m_adjdate datetime,
    @m_gdgid int,
    @m_src int,
    @adj_settleno int,
    @adj_begindate datetime,
    @r_store int,
    @r_wrh int,
    @r_subwrh int,
    @r_qty money,
    @r_total money,
    @r_fildate datetime,
    @o_line smallint,
    @o_qty money,
    @o_total money

  if @p_cls <> '库存' return(0)

  select @m_adjdate = ADJDATE, @m_gdgid = GDGID, @m_src = SRC
    from INPRCADJ where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  select @line = 1, @usergid = USERGID from SYSTEM

  delete from INPRCADJAINVDTL
    where CLS = @p_cls and NUM = @p_num and STORE = @usergid

  -- 本店
  --   选出当月期初库存结构
  select @adj_settleno = NO, @adj_begindate = BEGINDATE from MONTHSETTLE
    where BEGINDATE <= @m_adjdate and ENDDATE >= @m_adjdate
  declare c cursor for
    select BWRH, BSUBWRH, CQ, CI
    from SWINVMRPT
    where ASETTLENO = @adj_settleno and BGDGID = @m_gdgid
      and ASTORE = @usergid
    for read only
  open c
  fetch next from c into @r_wrh, @r_subwrh, @r_qty, @r_total
  while @@fetch_status = 0
  begin
    insert into INPRCADJAINVDTL (CLS, NUM, LINE,
      STORE, WRH, SUBWRH, QTY, COST)
    values (@p_cls, @p_num, @line,
      @usergid, @r_wrh, @r_subwrh, @r_qty, @r_total)
    select @line = @line + 1
    fetch next from c into @r_wrh, @r_subwrh, @r_qty, @r_total
  end
  close c
  deallocate c
  --   区间进出货单据：
  declare c cursor for
    -- STKIN 进货
    select d.WRH, d.SUBWRH, sum(d.QTY) QTY, sum(d.PRICE * d.QTY) TOTAL
    from STKIN m inner join STKINDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- STKOUTBCK 出货退货
    select d.WRH, d.SUBWRH, sum(d.QTY) QTY, sum(d.INPRC * d.QTY) TOTAL
    from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- RTLBCK 零售退货
    select m.WRH, d.SUBWRH, sum(d.QTY) QTY, sum(d.INPRC * d.QTY) TOTAL
    from RTLBCK m inner join RTLBCKDTL d on m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by m.WRH, d.SUBWRH
    union
    -- DIRALC 直配进货
    select d.WRH, d.SUBWRH, sum(d.QTY) QTY, sum(d.PRICE * d.QTY) TOTAL
    from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and m.CLS = '直配进'
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- XF 内部调拨 调入
    -- 使用FILDATE,而不用INDATE.
    -- 因为当时库存中还应包括内部调拨未提与在途的商品,应被作为调入仓的未到数计入,参与成本调整.
    select m.TOWRH WRH, d.TOSUBWRH SUBWRH, sum(d.QTY) QTY, sum(d.INPRC * d.QTY) TOTAL
    from XF m inner join XFDTL d on m.NUM = d.NUM
    where m.STAT in (9)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)		
      and d.GDGID = @m_gdgid
    group by m.TOWRH, d.TOSUBWRH
    union
    -- STKINBCK 进货退货
    select d.WRH, d.SUBWRH, - sum(d.QTY) QTY, - sum(d.INPRC * d.QTY) TOTAL
    from STKINBCK m inner join STKINBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- STKOUT 出货
    select d.WRH, d.SUBWRH, - sum(d.QTY) QTY, - sum(d.INPRC * d.QTY) TOTAL
    from STKOUT m inner join STKOUTDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- RTL 零售
    select m.WRH, d.SUBWRH, - sum(d.QTY) QTY, - sum(d.INPRC * d.QTY) TOTAL
    from RTL m inner join RTLDTL d on m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by m.WRH, d.SUBWRH
    union
    -- DIRALC 直配进货退货
    select d.WRH, d.SUBWRH, - sum(d.QTY) QTY, - sum(d.INPRC * d.QTY) TOTAL
    from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT not in (0, 7)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and m.CLS = '直配进退'
      and d.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    union
    -- XF 内部调拨 调出
    select m.FROMWRH WRH, d.FROMSUBWRH SUBWRH, - sum(d.QTY), - sum(d.INPRC * d.QTY) TOTAL
    from XF m inner join XFDTL d on m.NUM = d.NUM
    where m.SETTLENO = @adj_settleno and m.STAT in (1, 8, 9)
      and m.FILDATE between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.GDGID = @m_gdgid
    group by m.FROMWRH, d.FROMSUBWRH
    union
    -- 库存成本调整
    select d.WRH, d.SUBWRH, 0 QTY, sum(d.ADJCOST) TOTAL
    from INPRCADJ m inner join INPRCADJINVDTL d on m.CLS = d.CLS and m.NUM = d.NUM
    where d.LACTIME between @adj_begindate and dateadd(day, 1, @m_adjdate)
      and d.STORE = @usergid
      and m.GDGID = @m_gdgid
    group by d.WRH, d.SUBWRH
    for read only
  open c
  fetch next from c into @r_wrh, @r_subwrh, @r_qty, @r_total
  while @@fetch_status = 0
  begin
    select @o_line = LINE, @o_qty = QTY, @o_total = COST
      from INPRCADJAINVDTL
      where CLS = @p_cls and NUM = @p_num and WRH = @r_wrh and SUBWRH = @r_subwrh
    if @@rowcount > 0
    begin
      if @o_qty + @r_qty = 0 and @o_total + @r_total = 0
        delete from INPRCADJAINVDTL where CLS = @p_cls and NUM = @p_num and LINE = @o_line
      else
        update INPRCADJAINVDTL set
          QTY = QTY + @r_qty, COST = COST + @r_total
          where CLS = @p_cls and NUM = @p_num and LINE = @o_line
    end
    else
      if @r_qty <> 0 or @r_total <> 0
      begin
        insert into INPRCADJAINVDTL (CLS, NUM, LINE,
          STORE, WRH, SUBWRH, QTY, COST)
        values (@p_cls, @p_num, @line,
          @usergid, @r_wrh, @r_subwrh, @r_qty, @r_total)
        select @line = @line + 1
      end
    fetch next from c into @r_wrh, @r_subwrh, @r_qty, @r_total
  end
  close c
  deallocate c

  -- 门店
  if @m_src = @usergid
  begin
    -- 选出当月期初库存
    declare c cursor for
      select ASTORE, sum(CQ), sum(CI)
      from SWINVMRPT
      where ASETTLENO = @adj_settleno and BGDGID = @m_gdgid
        and ASTORE <> @usergid 
        and ASTORE in (
          select STORE from INPRCADJLACDTL where CLS = @p_cls and NUM = @p_num)
      group by ASTORE
      for read only
    open c
    fetch next from c into @r_store, @r_qty, @r_total
    while @@fetch_status = 0
    begin
      insert into INPRCADJAINVDTL (CLS, NUM, LINE,
        STORE, WRH, SUBWRH, QTY, COST)
      values (@p_cls, @p_num, @line,
        @r_store, null, null, @r_qty, @r_total)
      select @line = @line + 1
      fetch next from c into @r_store, @r_qty, @r_total
    end
    close c
    deallocate c
    declare c cursor for
      -- 区间进货
      select ASTORE, sum(DQ1 + DQ2 + DQ3 - DQ4), sum(DI1 + DI2 + DI3 - DI4)
      from INDRPT
      where ADATE < dateadd(day, 1, @m_adjdate)
        and BGDGID = @m_gdgid and ASETTLENO = @adj_settleno
        and ASTORE <> @usergid
        and ASTORE in (
          select STORE from INPRCADJLACDTL where CLS = @p_cls and NUM = @p_num)
      group by ASTORE
      union
      -- 区间出货
      select ASTORE, - sum(DQ1 + DQ2 + DQ3 + DQ4 - DQ5 - DQ6 - DQ7),
        - sum(DI1 + DI2 + DI3 + DI4 - DI5 - DI6 - DI7)
      from OUTDRPT
      where ADATE < dateadd(day, 1, @m_adjdate)
        and BGDGID = @m_gdgid and ASETTLENO = @adj_settleno
        and ASTORE <> @usergid
        and ASTORE in (
          select STORE from INPRCADJLACDTL where CLS = @p_cls and NUM = @p_num)
      group by ASTORE
      union
      -- 区间库存调整
      select ASTORE, 0, sum(DI3 + DI4 - DI5)
      from INVCHGDRPT
      where ADATE < dateadd(day, 1, @m_adjdate)
        and BGDGID = @m_gdgid and ASETTLENO = @adj_settleno
        and ASTORE <> @usergid
        and ASTORE in (
          select STORE from INPRCADJLACDTL where CLS = @p_cls and NUM = @p_num)
      group by ASTORE
      for read only
    open c
    fetch next from c into @r_store, @r_qty, @r_total
    while @@fetch_status = 0
    begin
      select @o_line = LINE from INPRCADJAINVDTL
        where CLS = @p_cls and NUM = @p_num and STORE = @r_store
      if @@rowcount > 0
        update INPRCADJAINVDTL set
          QTY = QTY + @r_qty, COST = COST + @r_total
          where CLS = @p_cls and NUM = @p_num and LINE = @o_line
      else
      begin
        insert into INPRCADJAINVDTL (CLS, NUM, LINE,
          STORE, WRH, SUBWRH, QTY, COST)
        values (@p_cls, @p_num, @line,
          @r_store, null, null, @r_qty, @r_total)
        select @line = @line + 1
      end
      fetch next from c into @r_store, @r_qty, @r_total
    end
    close c
    deallocate c
  end

  -- 整理行号
  select @line = 1
  declare c cursor for
    select WRH, SUBWRH
    from INPRCADJAINVDTL
    where CLS = @p_cls and NUM = @p_num
    for update
  open c
  fetch next from c into @r_wrh, @r_subwrh
  while @@fetch_status = 0
  begin
    update INPRCADJAINVDTL set LINE = @line
      where CLS = @p_cls and NUM = @p_num and WRH = @r_wrh and SUBWRH = @r_subwrh
    select @line = @line + 1
    fetch next from c into @r_wrh, @r_subwrh
  end
  close c
  deallocate c

  return(0)
end

GO
