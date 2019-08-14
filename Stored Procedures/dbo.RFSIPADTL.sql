SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[RFSIPADTL](
  @p_cls char(10),
  @p_num char(10),
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @cur_settleno int,
    @nextline smallint,
    @usergid int,
    @m_newprc money,
    @m_adjdate datetime,
    @m_inbill char(10),
    @m_incls char(10),
    @m_innum char(10),
    @m_inline smallint,
    @m_subwrh int,
    @m_gdgid int,
    @m_src int,
    @d_bill char(10),
    @d_billcls char(10),
    @d_billnum char(10),
    @d_billline smallint,
    @d_billsrcnum char(10),
    @d_qty money,
    @d_incost money,
    @d_outcost money,
    @d_amt money,
    @d_adjincost money,
    @d_adjoutcost money,
    @d_adjamt money,
    @o_gdgid int,
    @o_cost money,
    @o_qty money,
    @o_adjcost money,
    @o_adjcost2 money,
    @o_line smallint,
    @o_wrh int,
    @o_subwrh int,
    @r_qty money,
    @r_cost money

  select @ret_status = 0, @cur_settleno = max(NO) from MONTHSETTLE
  select @m_newprc = NEWPRC, @m_adjdate = ADJDATE,
    @m_inbill = INBILL, @m_incls = INCLS, @m_innum = INNUM, @m_inline = INLINE,
    @m_subwrh = SUBWRH, @m_gdgid = GDGID, @m_src = SRC
    from INPRCADJ
    where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  select @usergid = USERGID from SYSTEM
  delete from INPRCADJDTL
    where CLS = @p_cls and NUM = @p_num and STORE = @usergid
      and LACTIME is null and SRC = @usergid
  select @nextline = isnull(max(LINE) + 1, 1) from INPRCADJDTL
    where CLS = @p_cls and NUM = @p_num

  if @p_cls = '批次'
  begin
    -- 批次
    if @m_src = @usergid
    begin
      --   产生批次的单据，包括：STKIN、STKOUTBCK、RTLBCK、DIRALC
      select @d_incost = 0, @d_outcost = 0, @d_amt = 0,
        @d_adjincost = 0, @d_adjoutcost = 0, @d_adjamt = 0
      --   得到原单据的成本额
      if @m_inbill = 'STKIN'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.PRICE, 
          @d_billsrcnum = m.SRCNUM, @o_wrh = d.WRH, 
          @o_gdgid = d.GDGID /* 2000.11.9 */
          from STKIN m inner join STKINDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @m_incls and m.NUM = @m_innum
            and d.LINE = @m_inline
      else if @m_inbill = 'STKOUTBCK'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.INPRC, 
          @d_billsrcnum = m.SRCNUM, @o_wrh = d.WRH,
          @o_gdgid = d.GDGID /* 2000.11.9 */
          from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @m_incls and m.NUM = @m_innum
            and d.LINE = @m_inline
      else if @m_inbill = 'RTLBCK'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.INPRC, 
          @d_billsrcnum = null, @o_wrh = m.WRH,
          @o_gdgid = d.GDGID /* 2000.11.9 */
          from RTLBCK m inner join RTLBCKDTL d on m.NUM = d.NUM
          where m.NUM = @m_innum
            and d.LINE = @m_inline
      else if @m_inbill = 'DIRALC'
      begin
        select @o_qty = d.QTY, @o_cost = d.QTY * d.PRICE,
          @d_billsrcnum = m.SRCNUM, @d_amt = d.ALCAMT, @o_wrh = d.WRH,
          @o_gdgid = d.GDGID /* 2000.11.9 */
          from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @m_incls and m.NUM = @m_innum
            and d.LINE = @m_inline
        if @m_incls not in ('直配出', '直配出退')
          select @d_amt = 0
      end
      
      /* 2000.11.9 */
      if @o_gdgid <> @m_gdgid
      begin
        select @err_msg = '当前单据指定的批次与商品不符。'
        raiserror(@err_msg, 16, 1)
        return(1)
      end
      
      --   得到原单据已发生调整总额
      select @d_qty = @o_qty
      if @m_inbill in ('STKIN', 'DIRALC')
      begin
        select @o_adjcost = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @m_inbill and BILLCLS = @m_incls
            and BILLNUM = @m_innum and BILLLINE = @m_inline
            and LACTIME is not null
        if @m_inbill = 'DIRALC'
        begin
          if @m_incls = '直配进'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(@m_newprc * @d_qty - @d_incost, 2)
          else if @m_incls = '直配进退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(- @m_newprc * @d_qty - @d_incost, 2)
          else if @m_incls = '直配出'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(@m_newprc * @d_qty - @d_incost, 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = @d_amt + @o_adjcost,
              @d_adjamt = @d_adjincost
          else if @m_incls = '直配出退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(- @m_newprc * @d_qty - @d_incost, 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = - @d_amt + @o_adjcost,
              @d_adjamt = @d_adjincost
          else if @m_incls = '直销'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(@m_newprc * @d_qty - @d_incost, 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost
          else if @m_incls = '直销退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(- @m_newprc * @d_qty - @d_incost, 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost
        end
        else if @m_inbill = 'STKIN'
          select @d_incost = @o_cost + @o_adjcost,
            @d_adjincost = round(@m_newprc * @d_qty - @d_incost, 2)
      end else -- @m_inbill in ('STKOUTBCK', 'RTLBCK')
      begin
        select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @m_inbill and BILLCLS = @m_incls
            and BILLNUM = @m_innum and BILLLINE = @m_inline
            and LACTIME is not null
        select @d_outcost = - @o_cost + @o_adjcost,
          @d_adjoutcost = round(- @m_newprc * @d_qty - @d_outcost, 2)
        if @m_inbill = 'STKOUTBCK' and @m_incls in ('配货')   --配货出货退货单
          select @d_amt = - @d_amt + @o_adjcost,
            @d_adjamt = @d_adjoutcost
      end
      --   写入进货调整明细
      select @o_line = LINE
        from INPRCADJDTL
        where CLS = @p_cls and NUM = @p_num
          and STORE = @usergid and BILL = @m_inbill and BILLCLS = @m_incls
          and BILLNUM = @m_innum and BILLLINE = @m_inline
          and LACTIME is null
      if @@rowcount > 0
        delete from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and LINE = @o_line
      insert into INPRCADJDTL(
        CLS, NUM, LINE, SETTLENO, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
        QTY, INCOST, OUTCOST, AMT, ADJINCOST,
        ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
        NOTE, WRH)
        values (
        @p_cls, @p_num, @nextline, @cur_settleno, @usergid,
        @m_inbill, @m_incls, @m_innum, @m_inline, isnull(@m_subwrh, 1),
        @d_qty, @d_incost, @d_outcost, @d_amt, @d_adjincost,
        @d_adjoutcost, @d_adjamt, @usergid, null, @d_billsrcnum,
        null, @o_wrh)
      select @nextline = @nextline + 1
    end
      
    --   使用批次的单据，包括：STKOUT、RTL、STKINBCK、XF、STKOUTBCK
    if @m_incls not in ('直配出', '直配出退', '直销', '直销出')
    begin
      declare c cursor for
        select 'STKOUT', m.CLS, m.NUM, d.LINE, m.SRCNUM,
          d.WRH, d.SUBWRH, d.QTY, d.QTY * d.INPRC COST,
          case m.CLS when '配货' then d.TOTAL else 0 end
        from STKOUT m inner join STKOUTDTL d on m.CLS = d.CLS and m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.SUBWRH = @m_subwrh
          and m.STAT not in (0, 7)
        union
        select 'STKOUTBCK', m.CLS, m.NUM, d.LINE, m.SRCNUM,
          d.WRH, d.SUBWRH, d.QTY, - d.QTY * d.INPRC COST,
          case m.CLS when '配货' then - d.TOTAL else 0 end
        from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.SUBWRH = @m_subwrh
          and m.STAT not in (0, 7)
        union
        select 'STKINBCK', m.CLS, m.NUM, d.LINE, m.SRCNUM,
          d.WRH, d.SUBWRH, d.QTY, - d.QTY * d.INPRC COST, 0
        from STKINBCK m inner join STKINBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.SUBWRH = @m_subwrh
          and m.STAT not in (0, 7)
        union
        select 'RTL', '', m.NUM, d.LINE, null,
          m.WRH, d.SUBWRH, d.QTY, d.QTY * d.INPRC COST, 0
        from RTL m inner join RTLDTL d on m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.SUBWRH = @m_subwrh
          and m.STAT <> 0
        union 
        select 'XF', '调出', m.NUM, d.LINE, null,
          m.FROMWRH WRH, d.FROMSUBWRH SUBWRH, d.QTY, d.QTY * d.INPRC COST, 0
        from XF m inner join XFDTL d on m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.FROMSUBWRH = @m_subwrh
          and m.STAT in (1, 8, 9)
        union
        select 'XF', '调入', m.NUM, d.LINE, null,
          m.TOWRH WRH, d.TOSUBWRH SUBWRH, d.QTY, d.QTY * d.INPRC COST, 0
        from XF m inner join XFDTL d on m.NUM = d.NUM
        where d.GDGID = @m_gdgid and d.TOSUBWRH = @m_subwrh
          and m.STAT in (1, 8, 9)
        for read only
      open c
      fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
        @o_wrh, @o_subwrh, @o_qty, @o_cost, @d_amt
      while @@fetch_status = 0
      begin
      	--  与指定批次来源单据相同的记录应被跳过，因为前面已经处理过
      	if @d_bill = @m_inbill and @d_billcls = @m_incls 
      	    and @d_billnum = @m_innum and @d_billline = @m_inline
      	begin
          fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
            @o_wrh, @o_subwrh, @o_qty, @o_cost, @d_amt
          continue
        end
        --  得到已经发生的成本调整额
        select @d_qty = @o_qty
        if @d_bill in ('STKOUT', 'RTL')
          or (@d_bill = 'XF' and @d_billcls = '调出')
        begin
          select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
            from INPRCADJDTL
            where STORE = @usergid and BILL = @d_bill
              and BILLCLS = @d_billcls and BILLNUM = @d_billnum
              and BILLLINE = @d_billline and LACTIME is not null
          select @d_incost = 0,
            @d_adjincost = 0,
            @d_outcost = @o_cost + @o_adjcost,
            @d_adjoutcost = round(@o_qty * @m_newprc - @d_outcost, 2)
          if @d_billcls = '配货'
            select @d_amt = @d_amt + @o_adjcost,
              @d_adjamt = @d_adjoutcost
          else
            select @d_amt = 0, @d_adjamt = 0
        end
        else if @d_bill = 'STKOUTBCK'
        begin
          select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
            from INPRCADJDTL
            where STORE = @usergid and BILL = @d_bill
              and BILLCLS = @d_billcls and BILLNUM = @d_billnum
              and BILLLINE = @d_billline and LACTIME is not null
          select @d_incost = 0,
            @d_adjincost = 0,
            @d_outcost = @o_cost + @o_adjcost,
            @d_adjoutcost = round(- @o_qty * @m_newprc - @d_outcost, 2)
          if @d_billcls = '配货'
            select @d_amt = @d_amt + @o_adjcost,
              @d_adjamt = @d_adjoutcost
          else
            select @d_amt = 0, @d_adjamt = 0
        end
        else if @d_bill = 'STKINBCK'
        begin
          select @o_adjcost = isnull(sum(ADJINCOST), 0)
            from INPRCADJDTL
            where STORE = @usergid and BILL = @d_bill
              and BILLCLS = @d_billcls and BILLNUM = @d_billnum
              and BILLLINE = @d_billline and LACTIME is not null
          select @d_incost = @o_cost + @o_adjcost,
            @d_adjincost = round(- @o_qty * @m_newprc - @d_incost, 2),
            @d_outcost = 0,
            @d_adjoutcost = 0,
            @d_amt = 0,
            @d_adjamt = 0
        end
        else if @d_bill = 'XF' and @d_billcls = '调入'
        begin
          select @o_adjcost = isnull(sum(ADJINCOST), 0)
            from INPRCADJDTL
            where STORE = @usergid and BILL = @d_bill
              and BILLCLS = @d_billcls and BILLNUM = @d_billnum
              and BILLLINE = @d_billline and LACTIME is not null
          select @d_incost = @o_cost + @o_adjcost,
            @d_adjincost = round(@o_qty * @m_newprc - @d_incost, 2),
            @d_outcost = 0,
            @d_adjoutcost = 0,
            @d_amt = 0,
            @d_adjamt = 0
        end
        --  写入出货调整明细
        insert into INPRCADJDTL(
          CLS, NUM, LINE, SETTLENO, STORE,
          BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
          QTY, INCOST, OUTCOST, AMT, ADJINCOST,
          ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
          NOTE, WRH)
          values (
          @p_cls, @p_num, @nextline, @cur_settleno, @usergid,
          @d_bill, @d_billcls, @d_billnum, @d_billline, @o_subwrh,
          @d_qty, @d_incost, @d_outcost, @d_amt, @d_adjincost,
          @d_adjoutcost, @d_adjamt, @usergid, null, @d_billsrcnum,
          null, @o_wrh)
        select @nextline = @nextline + 1
        fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
          @o_wrh, @o_subwrh, @o_qty, @o_cost, @d_amt
      end
      close c
      deallocate c
    end

  end
  else if @p_cls = '库存'
  begin
    -- 库存
    --   产生批次的单据，包括：STKIN、STKOUTBCK、RTLBCK、DIRALC
    declare c cursor for
      select WRH, SUBWRH, QTY, COST
      from INPRCADJAINVDTL
      where CLS = @p_cls and NUM = @p_num
      for read only
    open c
    fetch next from c into @o_wrh, @o_subwrh, @r_qty, @r_cost
    while @@fetch_status = 0
    begin
      exec @ret_status = CVTSUBWRHBILL @o_subwrh,
        @d_bill output, @d_billcls output, @d_billnum output, @d_billline output
      if @ret_status <> 0
      begin
        select @err_msg = '找不到货位(GID=' + convert(char, @o_subwrh) + ')对应的进货单据。'
        break
      end
      -- 得到原单据的成本额
      if @d_bill = 'STKIN'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.PRICE, @d_billsrcnum = m.SRCNUM
          from STKIN m inner join STKINDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @d_billcls and m.NUM = @d_billnum
            and d.LINE = @d_billline
      else if @d_bill = 'STKOUTBCK'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.INPRC, @d_billsrcnum = m.SRCNUM,
          @d_amt = d.TOTAL
          from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @d_billcls and m.NUM = @d_billnum
            and d.LINE = @d_billline
      else if @d_bill = 'RTLBCK'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.INPRC, @d_billsrcnum = null
          from RTLBCK m inner join RTLBCKDTL d on m.NUM = d.NUM
          where m.NUM = @d_billnum
            and d.LINE = @d_billline
      else -- @d_bill = 'DIRALC'
        select @o_qty = d.QTY, @o_cost = d.QTY * d.PRICE, @d_billsrcnum = m.SRCNUM
          from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
          where m.CLS = @d_billcls and m.NUM = @d_billnum
            and d.LINE = @d_billline
      -- 得到原单据的调整总额
      select @d_qty = @r_qty
      if @d_bill in ('STKIN', 'DIRALC')
      begin
        select @o_adjcost2 = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and WRH = @o_wrh
            and LACTIME > dateadd(day, 1, @m_adjdate)
        select @o_adjcost = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and WRH = @o_wrh
            and LACTIME is not null
        if @d_bill = 'DIRALC'
        begin
          if @d_billcls = '直配进'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = 0,
              @d_adjoutcost = 0,
              @d_amt = 0,
              @d_adjamt = 0
          else if @d_billcls = '直配进退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, - @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = 0,
              @d_adjoutcost = 0,
              @d_amt = 0,
              @d_adjamt = 0
          else if @d_billcls = '直配出'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = @d_amt + @o_adjcost,
              @d_adjamt = @d_adjincost
          else if @d_billcls = '直配出退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, - @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = - @d_amt + @o_adjcost,
              @d_adjamt = @d_adjincost
          else if @d_billcls = '直销'
            select @d_incost = @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = 0,
              @d_adjamt = 0
          else if @d_billcls = '直销退'
            select @d_incost = - @o_cost + @o_adjcost,
              @d_adjincost = round(convert(real, - @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
              @d_outcost = @d_incost,
              @d_adjoutcost = @d_adjincost,
              @d_amt = 0,
              @d_adjamt = 0
        end
        else if @d_bill = 'STKIN'
          select @d_incost = @o_cost + @o_adjcost,
            @d_adjincost = round(convert(real, @r_qty) * @m_newprc - (@r_cost + @o_adjcost2), 2),
            @d_outcost = 0,
            @d_adjoutcost = 0,
            @d_amt = 0,
            @d_adjamt = 0
      end
      else if @d_bill in ('STKOUTBCK', 'RTLBCK')
      begin
        select @o_adjcost2 = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and WRH = @o_wrh
            and LACTIME > dateadd(day, 1, @m_adjdate)
        select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and WRH = @o_wrh
            and LACTIME is not null
        select @d_incost = 0,
          @d_adjincost = 0,
          @d_outcost = - @o_cost + @o_adjcost,
          @d_adjoutcost = round(convert(real, - @r_qty) * @m_newprc - (- @r_cost + @o_adjcost2), 2)
        if @m_inbill = 'STKOUTBCK' and @m_incls in ('配货')   --配货出货退货单
          select @d_amt = - @d_amt + @o_adjcost,
            @d_adjamt = @d_adjoutcost
        else
          select @d_amt = 0, @d_adjamt = 0
      end
      -- 将调整写入单据明细
      insert into INPRCADJDTL(
        CLS, NUM, LINE, SETTLENO, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
        QTY, INCOST, OUTCOST, AMT, ADJINCOST,
        ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
        NOTE, WRH)
        values (
        @p_cls, @p_num, @nextline, @cur_settleno, @usergid,
        @d_bill, @d_billcls, @d_billnum, @d_billline, isnull(@o_subwrh, 1),
        @d_qty, @d_incost, @d_outcost, @d_amt, @d_adjincost,
        @d_adjoutcost, @d_adjamt, @usergid, null, @d_billsrcnum,
        null, @o_wrh)
      select @nextline = @nextline + 1
      fetch next from c into @o_wrh, @o_subwrh, @r_qty, @r_cost
    end
    close c
    deallocate c
    --   使用批次的单据，包括：STKOUT、STKOUTBCK、RTL、STKINBCK、XF
    declare c cursor for
      select 'STKOUT', m.CLS, m.NUM, d.LINE, m.SRCNUM,
        d.WRH, d.SUBWRH, d.QTY, d.QTY * d.INPRC,
        case m.CLS when '配货' then d.TOTAL else 0 end
      from STKOUT m inner join STKOUTDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.FILDATE > dateadd(day, 1, @m_adjdate)
        and m.STAT not in (0, 7)
        and d.SUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      union
      select 'STKOUTBCK', m.CLS, m.NUM, d.LINE, m.SRCNUM,
        d.WRH, d.SUBWRH, d.QTY, - d.QTY * d.INPRC,
        case m.CLS when '配货' then - d.TOTAL else 0 end
      from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.FILDATE > dateadd(day, 1, @m_adjdate)
        and m.STAT not in (0, 7)
        and d.SUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      union
      select 'STKINBCK', m.CLS, m.NUM, d.LINE, m.SRCNUM,
        d.WRH, d.SUBWRH, d.QTY, - d.QTY * d.INPRC,
        case m.CLS when '配货' then - d.TOTAL else 0 end
      from STKINBCK m inner join STKINBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.FILDATE > dateadd(day, 1, @m_adjdate)
        and m.STAT not in (0, 7)
        and d.SUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      union
      select 'RTL', '', m.NUM, d.LINE, null,
        m.WRH, d.SUBWRH, d.QTY, d.QTY * d.INPRC, 0
      from RTL m inner join RTLDTL d on m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and m.FILDATE > dateadd(day, 1, @m_adjdate)
        and m.STAT not in (0)
        and d.SUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      union
      select 'XF', '调出', m.NUM, d.LINE, null,
        m.FROMWRH WRH, d.FROMSUBWRH SUBWRH, d.QTY, d.QTY * d.INPRC, 0
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and (m.FILDATE > dateadd(day, 1, @m_adjdate) 
          or isnull(m.INDATE, getdate()) > dateadd(day, 1, @m_adjdate))
        and m.STAT not in (0)
        and d.FROMSUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      union
      select 'XF', '调入', m.NUM, d.LINE, null,
        m.TOWRH WRH, d.TOSUBWRH SUBWRH, d.QTY, d.QTY * d.INPRC, 0
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where d.GDGID = @m_gdgid
        and (m.FILDATE > dateadd(day, 1, @m_adjdate) 
          or isnull(m.INDATE, getdate()) > dateadd(day, 1, @m_adjdate))
        and m.STAT not in (0)
        and d.TOSUBWRH in (
          select distinct SUBWRH from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid)
      for read only
    open c
    fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
      @o_wrh, @o_subwrh, @o_qty, @o_cost, @d_amt
    while @@fetch_status = 0
    begin
      --  得到已经发生的成本调整额
      select @d_qty = @o_qty
      if @d_bill in ('STKOUT', 'RTL')
        or (@d_bill = 'XF' and @d_billcls = '调出')
      begin
        select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and LACTIME is not null
            and WRH = @o_wrh
        select @d_incost = 0,
          @d_adjincost = 0,
          @d_outcost = @o_cost + @o_adjcost,
          @d_adjoutcost = round(@o_qty * @m_newprc - @d_outcost, 2)
        if @d_billcls = '配货'
          select @d_amt = @d_amt + @o_adjcost,
            @d_adjamt = @d_adjoutcost
        else
          select @d_amt = 0, @d_adjamt = 0
      end
      else if @d_bill = 'STKOUTBCK'
      begin
        select @o_adjcost = isnull(sum(ADJOUTCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and LACTIME is not null
            and WRH = @o_wrh
        select @d_incost = 0,
          @d_adjincost = 0,
          @d_outcost = @o_cost + @o_adjcost,
          @d_adjoutcost = round(- @o_qty * @m_newprc - @d_outcost, 2)
        if @d_billcls = '配货'
          select @d_amt = @d_amt + @o_adjcost,
            @d_adjamt = @d_adjoutcost
        else
          select @d_amt = 0, @d_adjamt = 0
      end
      else if @d_bill = 'STKINBCK'
      begin
        select @o_adjcost = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and LACTIME is not null
            and WRH = @o_wrh
        select @d_incost = @o_cost + @o_adjcost,
          @d_adjincost = round(- @o_qty * @m_newprc - @d_incost, 2),
          @d_outcost = 0,
          @d_adjoutcost = 0,
          @d_amt = 0,
          @d_adjamt = 0
      end
      else if @d_bill = 'XF' and @d_billcls = '调入'
      begin
        select @o_adjcost = isnull(sum(ADJINCOST), 0)
          from INPRCADJDTL
          where STORE = @usergid and BILL = @d_bill
            and BILLCLS = @d_billcls and BILLNUM = @d_billnum
            and BILLLINE = @d_billline and LACTIME is not null
            and WRH = @o_wrh
        select @d_incost = @o_cost + @o_adjcost,
          @d_adjincost = round(@o_qty * @m_newprc - @d_incost, 2),
          @d_outcost = 0,
          @d_adjoutcost = 0,
          @d_amt = 0,
          @d_adjamt = 0
      end
      --  写入出货调整明细
      insert into INPRCADJDTL(
        CLS, NUM, LINE, SETTLENO, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
        QTY, INCOST, OUTCOST, AMT, ADJINCOST,
        ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
        NOTE, WRH)
        values (
        @p_cls, @p_num, @nextline, @cur_settleno, @usergid,
        @d_bill, @d_billcls, @d_billnum, @d_billline, isnull(@o_subwrh, 1),
        @d_qty, @d_incost, @d_outcost, @d_amt, @d_adjincost,
        @d_adjoutcost, @d_adjamt, @usergid, null, @d_billsrcnum,
        null, @o_wrh)
      select @nextline = @nextline + 1
      fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_billsrcnum,
        @o_wrh, @o_subwrh, @o_qty, @o_cost, @d_amt
    end
    close c
    deallocate c

  end

  -- 整理行号
  select @nextline = 1
  declare c cursor for
    select LINE
    from INPRCADJDTL
    where CLS = @p_cls and NUM = @p_num
    order by LINE
    for update
  open c
  fetch next from c into @o_line
  while @@fetch_status = 0
  begin
    update INPRCADJDTL set LINE = @nextline
      where CLS = @p_cls and NUM = @p_num and LINE = @o_line
    select @nextline = @nextline + 1
    fetch next from c into @o_line
  end
  close c
  deallocate c

  return(@ret_status)
end

GO
