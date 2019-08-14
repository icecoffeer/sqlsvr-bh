SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJRCVGO](
  @p_src int,
  @p_id int,
  @p_cls char(10),
  @p_num char(10),
  @p_oldsrc int,
  @p_checker int,
  @p_vendor int,
  @p_gdgid int,
  @p_filler int,
  @p_psr int,
  @p_frcflag smallint,
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @usergid int,
    @cur_date datetime,
    @cur_settleno int,
    @m_adjdate datetime,
    @m_newprc money,
    @m_chkdate datetime,
    @d_store int,
    @d_bill char(10),
    @d_billcls char(10),
    @d_billnum char(10),
    @d_billline smallint,
    @d_qty money,
    @d_incost money,
    @d_outcost money,
    @d_amt money,
    @d_adjincost money,
    @d_adjoutcost money,
    @d_adjamt money,
    @d_lactime datetime,
    @d_billsrcnum char(10),
    @d_note varchar(255),
    @d_subwrh int,
    @ld_bill char(10),
    @ld_billcls char(10),
    @ld_billnum char(10),
    @ld_billsrcnum char(10),
    @ld_incost money,
    @ld_subwrh int,
    @l_line smallint,
    @ainv_qty money,
    @ainv_cost money,
    @inv_qty money,
    @inv_cost money,
    @inv_adjcost money,
    @m_invadjamt money,
    @m_inadjamt money,
    @m_outadjamt money,
    @m_alcadjamt money

  select @ret_status = 0, @l_line = 1,
    @usergid = USERGID, @cur_date = convert(char, getdate(), 102)
    from SYSTEM
  select @cur_settleno = max(NO) from MONTHSETTLE
  select @m_newprc = NEWPRC, @m_adjdate = ADJDATE, @m_chkdate = CHKDATE
    from NINPRCADJ
    where SRC = @p_src and ID = @p_id

  if @p_oldsrc <> @usergid
  begin
    -- 门店接收来自总部的单据
    if exists (select 1 from INPRCADJ where CLS = @p_cls and NUM = @p_num)
      return(0)

    insert into INPRCADJ (
      CLS, NUM, SETTLENO, ADJDATE, INBILL,
      INCLS, INNUM, INLINE, SUBWRH, VENDOR,
      GDGID, NEWPRC, INADJAMT, INVADJAMT, OUTADJAMT,
      ALCADJAMT, FILDATE, FILLER, STAT, CHECKER,
      CHKDATE, SRC, SNDTIME, PRNTIME, PSR,
      NOTE)
      select
      @p_cls, @p_num, @cur_settleno, ADJDATE, INBILL,
      INCLS, INNUM, INLINE, SUBWRH, @p_vendor,
      @p_gdgid, NEWPRC, 0, 0, 0,
      0, FILDATE, @p_filler, 0, 1,
      null, SRC, null, null, @p_psr,
      NOTE
      from NINPRCADJ
      where SRC = @p_src and ID = @p_id

    declare c cursor for
      select STORE, BILL, BILLCLS, BILLNUM, BILLLINE,
        QTY
      from NINPRCADJDTL
      where SRC = @p_src and ID = @p_id
      for read only
    open c
    fetch next from c into @d_store, @d_bill, @d_billcls, @d_billnum, @d_billline,
      @d_qty
    while @@fetch_status = 0
    begin
      if @d_bill = 'STKOUT' and @d_billcls = '配货'
      begin

        select @ld_bill = 'STKIN', @ld_billcls = '配货'
        select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
          from STKIN
          where CLS = @ld_billcls and SRC = @p_src
            and SRCNUM = @d_billnum and STAT not in (0)
        if @@rowcount = 0
        begin
          select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
            from STKIN
            where CLS = @ld_billcls and NUM = @d_billsrcnum
              and STAT not in (0, 7)
          if @@rowcount = 0
          begin
            select @err_msg = case when @ld_billsrcnum is null then '单号=''' + rtrim(@d_billsrcnum) + '''' else '来源单号=''' + rtrim(@ld_billnum) + '''' end
            select @err_msg = '本地找不到已审核或已预审的配货进货单(' + @err_msg + ')。'
            select @ret_status = 1
            break
          end
        end
        select @ld_subwrh = SUBWRH
          from STKINDTL
          where CLS = @ld_billcls and NUM = @ld_billnum and LINE = @d_billline

      end
      else if @d_bill = 'STKOUTBCK' and @d_billcls = '配货'
      begin

        select @ld_bill = 'STKINBCK', @ld_billcls = '配货'
        select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
          from STKINBCK
          where CLS = @ld_billcls and SRC = @p_src
            and SRCNUM = @d_billnum and STAT not in (0)
        if @@rowcount = 0
        begin
          select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
            from STKINBCK
            where CLS = @ld_billcls and NUM = @d_billsrcnum
              and STAT not in (0, 7)
          if @@rowcount = 0
          begin
            select @err_msg = case when @ld_billsrcnum is null then '单号=''' + rtrim(@d_billsrcnum) + '''' else '来源单号=''' + rtrim(@ld_billnum) + '''' end
            select @err_msg = '本地找不到已审核或已预审的配货进货退货单(' + @err_msg + ')。'
            select @ret_status = 1
            break
          end
        end
        select @ld_subwrh = SUBWRH
          from STKINBCKDTL
          where CLS = @ld_billcls and NUM = @ld_billnum and LINE = @d_billline

      end
      else if @d_bill = 'DIRALC' and @d_billcls in ('直配出', '直配出退')
      begin

		if @d_billcls = '直配出'
          select @ld_bill = 'DIRALC', @ld_billcls = '直配进'
        else
          select @ld_bill = 'DIRALC', @ld_billcls = '直配进退'
        select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
          from DIRALC
          where CLS = @ld_billcls and SRC = @p_src
            and SRCNUM = @d_billnum and STAT not in (0)
        if @@rowcount = 0
        begin
          select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
            from DIRALC
            where CLS = @ld_billcls and NUM = @d_billsrcnum
              and STAT not in (0, 7)
          if @@rowcount = 0
          begin
            select @err_msg = case when @ld_billsrcnum is null then '单号=''' + rtrim(@d_billsrcnum) + '''' else '来源单号=''' + rtrim(@ld_billnum) + '''' end
            select @err_msg = '本地找不到已审核或已预审的' + 
            	(case when @ld_billcls = '直配进' then '直配进货' else '直配进货退货' end)
            	+'单(' + @err_msg + ')。'
            select @ret_status = 1
            break
          end
        end
        select @ld_subwrh = SUBWRH
          from DIRALCDTL
          where CLS = @ld_billcls and NUM = @ld_billnum and LINE = @d_billline

      end

      exec @ret_status = RFSIPADTLONE @p_cls, @p_num, @l_line,
        @ld_bill, @ld_billcls, @ld_billnum, @d_billline, @ld_billsrcnum, @ld_subwrh,
        @m_newprc, @d_qty, @m_adjdate, @p_src, @cur_settleno, @usergid, 
        @err_msg output
      if @ret_status <> 0
      begin
        select @err_msg = '刷新进出货成本调整明细时出错(单据=' + rtrim(@d_bill) + ' - ' + rtrim(@d_billcls) + ';' + rtrim(@d_billnum) + ';' + convert(char, @d_billline) + ')。' + @err_msg
        break
      end

      select @l_line = @l_line + 1
      fetch next from c into @d_store, @d_bill, @d_billcls, @d_billnum, @d_billline,
        @d_qty
    end
    close c
    deallocate c
    if @ret_status <> 0
    begin
      raiserror(@err_msg, 16, 1)
      return(@ret_status)
    end

    if @p_frcflag <> 0
    begin
      update INPRCADJ set CHECKER = @p_checker where CLS = @p_cls and NUM = @p_num
      exec @ret_status = INPRCADJCHK @p_cls, @p_num, @err_msg output
      if @ret_status <> 0
      begin
        raiserror(@err_msg, 16, 1)
        return(@ret_status)
      end
      if @p_frcflag = 2
      begin
        exec @ret_status = INPRCADJSND @p_cls, @p_num, 1, @err_msg output
        if @ret_status <> 0
        begin
          raiserror(@err_msg, 16, 1)
          return(@ret_status)
        end
      end
    end

  end
  else
  begin

    -- 总部接收门店回送的单据
    if not exists (select 1 from INPRCADJ where CLS = @p_cls and NUM = @p_num)
    begin
      select @err_msg = '意外地无法找到进价调整单(' + @p_cls + ',' + @p_num + ')。'
      raiserror(@err_msg, 16, 1)
      return(1)
    end

    -- 接收门店当时库存明细
    if @p_cls = '库存'
    begin
      select @ainv_qty = isnull(sum(QTY), 0), 
        @ainv_cost = isnull(sum(COST), 0)
        from NINPRCADJAINVDTL
        where SRC = @p_src and ID = @p_id
      select @l_line = LINE from INPRCADJAINVDTL
        where CLS = @p_cls and NUM = @p_num and STORE = @p_src
      if @@rowcount = 0
      begin
        select @l_line = isnull(max(LINE), 0) + 1 from INPRCADJAINVDTL
          where CLS = @p_cls and NUM = @p_num
        insert into INPRCADJAINVDTL (
          CLS, NUM, LINE, STORE, WRH,
          SUBWRH, QTY, COST)
          values (@p_cls, @p_num, @l_line, @p_src, null,
          null, @ainv_qty, @ainv_cost)
      end
      else
        update INPRCADJAINVDTL set QTY = @ainv_qty, COST = @ainv_cost
          where CLS = @p_cls and NUM = @p_num and LINE = @l_line
    end

    -- 接收门店库存成本调整的明细
    select @inv_qty = isnull(sum(QTY), 0), 
      @inv_cost = isnull(sum(COST), 0), 
      @inv_adjcost = isnull(sum(ADJCOST), 0)
      from NINPRCADJINVDTL
      where SRC = @p_src and ID = @p_id
    select @l_line = LINE from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num and STORE = @p_src
    if @@rowcount = 0
    begin
      select @l_line = isnull(max(LINE), 0) + 1 from INPRCADJINVDTL
        where CLS = @p_cls and NUM = @p_num
      insert into INPRCADJINVDTL (
        CLS, NUM, LINE, SETTLENO, STORE,
        WRH, SUBWRH, QTY, COST, ADJCOST,
        LACTIME, NOTE)
        values (@p_cls, @p_num, @l_line, @cur_settleno, @p_src,
        null, null, @inv_qty, @inv_cost, @inv_adjcost,
        @m_chkdate, null)
    end
    else
      update INPRCADJINVDTL set
        QTY = @inv_qty, COST = @inv_cost, ADJCOST = @inv_adjcost, LACTIME = @m_chkdate
        where CLS = @p_cls and NUM = @p_num and LINE = @l_line

    -- 接收门店进出货调整的明细
    select @l_line = isnull(max(LINE), 0) + 1 from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num
    declare c cursor for
      select BILL, BILLCLS, BILLNUM, BILLLINE, QTY,
        INCOST, OUTCOST, AMT, ADJINCOST, ADJOUTCOST,
        ADJAMT, LACTIME, BILLSRCNUM, NOTE, SUBWRH
      from NINPRCADJDTL
      where SRC = @p_src and ID = @p_id
      for read only
    open c
    fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_qty,
      @d_incost, @d_outcost, @d_amt, @d_adjincost, @d_adjoutcost,
      @d_adjamt, @d_lactime, @d_billsrcnum, @d_note, @d_subwrh
    while @@fetch_status = 0
    begin
      insert into INPRCADJDTL (
        CLS, NUM, LINE, SETTLENO, STORE,
        BILL, BILLCLS, BILLNUM, BILLLINE, SUBWRH,
        QTY, INCOST, OUTCOST, AMT, ADJINCOST,
        ADJOUTCOST, ADJAMT, SRC, LACTIME, BILLSRCNUM,
        NOTE, WRH)
        values (@p_cls, @p_num, @l_line, @cur_settleno, @p_src,
        @d_bill, @d_billcls, @d_billnum, @d_billline, @d_subwrh,
        @d_qty, @d_incost, @d_outcost, @d_amt, @d_adjincost,
        @d_adjoutcost, @d_adjamt, @p_src, @d_lactime, @d_billsrcnum,
        @d_note, 1)
      select @l_line = @l_line + 1

      if @d_bill = 'STKIN' and @d_billcls = '配货'
      begin

        select @ld_bill = 'STKOUT', @ld_billcls = '配货'
        select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
          from STKOUT
          where CLS = @ld_billcls and NUM = @d_billsrcnum
            and STAT not in (0, 7)
        if @@rowcount = 0
        begin
          select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
            from STKOUT
            where CLS = @ld_billcls and SRCNUM = @d_billnum
              and STAT not in (0) and SRC = @usergid
          if @@rowcount = 0
          begin
            select @err_msg = case when @ld_billsrcnum is null then '单号=''' + rtrim(@d_billsrcnum) + '''' else '来源单号=''' + rtrim(@ld_billnum) + '''' end
            select @err_msg = '本地找不到已审核或已预审的配货出货单(' + @err_msg + ')。'
            select @ret_status = 1
            break
          end
        end
        select @ld_subwrh = @d_subwrh
        if not exists (select 1 from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid
            and BILL = @ld_bill and BILLCLS = @ld_billcls
            and BILLNUM = @ld_billnum and BILLLINE = @d_billline
            and SUBWRH = @ld_subwrh)
        begin
          exec @ret_status = RFSIPADTLONE @p_cls, @p_num, @l_line,
            @ld_bill, @ld_billcls, @ld_billnum, @d_billline, @ld_billsrcnum, @ld_subwrh,
            @m_newprc, @d_qty, @m_adjdate, @p_src, @cur_settleno, @usergid, 
            @err_msg output
          if @ret_status <> 0
          begin
            select @err_msg = '刷新进出货成本调整明细时出错(单据=' + rtrim(@d_bill) + ' - ' + rtrim(@d_billcls) + ';' + rtrim(@d_billnum) + ';' + convert(char, @d_billline) + ')。' + @err_msg
            break
          end
          exec @ret_status = INPRCADJDTLCHK @p_cls, @p_num, @l_line, @p_gdgid,
            @cur_date, @cur_settleno, @err_msg output
          if @ret_status <> 0 break
          select @l_line = @l_line + 1

          exec @ret_status = CVTSUBWRHBILL @ld_subwrh,
            @ld_bill output, @ld_billcls output, @ld_billnum output, @d_billline output
          if @ret_status <> 0 break
          exec @ret_status = RFSIPADTLONE @p_cls, @p_num, @l_line,
            @ld_bill, @ld_billcls, @ld_billnum, @d_billline, null, @ld_subwrh,
            @m_newprc, @d_qty, @m_adjdate, @p_src, @cur_settleno, @usergid, 
            @err_msg output
          if @ret_status <> 0
          begin
            select @err_msg = '刷新进出货成本调整明细时出错(单据=' + rtrim(@d_bill) + ' - ' + rtrim(@d_billcls) + ';' + rtrim(@d_billnum) + ';' + convert(char, @d_billline) + ')。' + @err_msg
            break
          end
          exec @ret_status = INPRCADJDTLCHK @p_cls, @p_num, @l_line, @p_gdgid,
            @cur_date, @cur_settleno, @err_msg output
          if @ret_status <> 0 break
          select @l_line = @l_line + 1
        end

      end
      else if @d_bill = 'DIRALC' and @d_billcls = '直配进'
      begin

        select @ld_bill = 'DIRALC', @ld_billcls = '直配出'
        select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
          from DIRALC
          where CLS = @ld_billcls and NUM = @d_billsrcnum
            and STAT not in (0, 7)
        if @@rowcount = 0
        begin
          select @ld_billnum = NUM, @ld_billsrcnum = SRCNUM
            from DIRALC
            where CLS = @ld_billcls and SRCNUM = @d_billnum
             and STAT not in (0) and SRC = @usergid
          if @@rowcount = 0
          begin
            select @err_msg = case when @ld_billsrcnum is null then '单号=''' + rtrim(@d_billsrcnum) + '''' else '来源单号=''' + rtrim(@ld_billnum) + '''' end
            select @err_msg = '本地找不到已审核的配货出货单(' + @err_msg + ')。'
            select @ret_status = 1
            break
          end
        end
        select @ld_subwrh = @d_subwrh
        if not exists (select 1 from INPRCADJDTL
          where CLS = @p_cls and NUM = @p_num and STORE = @usergid
            and BILL = @ld_bill and BILLCLS = @ld_billcls
            and BILLNUM = @ld_billnum and BILLLINE = @d_billline
            and SUBWRH = @ld_subwrh)
        begin
          exec @ret_status = RFSIPADTLONE @p_cls, @p_num, @l_line,
            @ld_bill, @ld_billcls, @ld_billnum, @d_billline, @ld_billsrcnum, @ld_subwrh,
            @m_newprc, @d_qty, @m_adjdate, @p_src, @cur_settleno, @usergid, 
            @err_msg output
          if @ret_status <> 0
          begin
            select @err_msg = '刷新进出货成本调整明细时出错(单据=' + rtrim(@d_bill) + ' - ' + rtrim(@d_billcls) + ';' + rtrim(@d_billnum) + ';' + convert(char, @d_billline) + ')。' + @err_msg
            break
          end
          select @l_line = @l_line + 1
          exec @ret_status = INPRCADJDTLCHK @p_cls, @p_num, @l_line, @p_gdgid,
            @cur_date, @cur_settleno, @err_msg output
          if @ret_status <> 0 break
        end

      end

      fetch next from c into @d_bill, @d_billcls, @d_billnum, @d_billline, @d_qty,
        @d_incost, @d_outcost, @d_amt, @d_adjincost, @d_adjoutcost,
        @d_adjamt, @d_lactime, @d_billsrcnum, @d_note, @d_subwrh
    end
    close c
    deallocate c


    select @m_invadjamt = isnull(sum(ADJCOST), 0)
      from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num and STORE = @p_src
    select @m_inadjamt = isnull(sum(ADJINCOST), 0),
      @m_outadjamt = isnull(sum(ADJOUTCOST), 0),
      @m_alcadjamt = isnull(sum(ADJAMT), 0)
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num and STORE = @p_src
    update INPRCADJLACDTL set
      INVADJAMT = @m_invadjamt, INADJAMT = @m_inadjamt,
      OUTADJAMT = @m_outadjamt, ALCADJAMT = @m_alcadjamt,
      LACTIME = @m_chkdate, STAT = 1
      where CLS = @p_cls and NUM = @p_num and STORE = @p_src

    select @m_invadjamt = isnull(sum(ADJCOST), 0)
      from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num and STORE = @usergid
    select @m_inadjamt = isnull(sum(ADJINCOST), 0),
      @m_outadjamt = isnull(sum(ADJOUTCOST), 0),
      @m_alcadjamt = isnull(sum(ADJAMT), 0)
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num and STORE = @usergid
    update INPRCADJLACDTL set
      INVADJAMT = @m_invadjamt, INADJAMT = @m_inadjamt,
      OUTADJAMT = @m_outadjamt, ALCADJAMT = @m_alcadjamt
      where CLS = @p_cls and NUM = @p_num and STORE = @usergid

    select @m_invadjamt = isnull(sum(ADJCOST), 0)
      from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num
    select @m_inadjamt = isnull(sum(ADJINCOST), 0),
      @m_outadjamt = isnull(sum(ADJOUTCOST), 0),
      @m_alcadjamt = isnull(sum(ADJAMT), 0)
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num
    update INPRCADJ set
      INVADJAMT = @m_invadjamt, INADJAMT = @m_inadjamt,
      OUTADJAMT = @m_outadjamt, ALCADJAMT = @m_alcadjamt
      where CLS = @p_cls and NUM = @p_num
    if not exists (select 1 from INPRCADJLACDTL
      where CLS = @p_cls and NUM = @p_num and LACTIME is null)
      update INPRCADJ set STAT = 2
        where CLS = @p_cls and NUM = @p_num

  end

  return(@ret_status)
end

GO
