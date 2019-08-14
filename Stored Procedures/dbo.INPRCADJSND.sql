SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJSND](
  @p_cls char(10),
  @p_num char(10),
  @p_frcflag smallint = 2,
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @ret_status int,
    @usergid int,
    @cur_time datetime,
    @m_stat smallint,
    @m_src int,
    @n_billid int,
    @d_rcv int

  select @ret_status = 0, @usergid = USERGID, @cur_time = getdate()
    from SYSTEM
  select @m_stat = STAT, @m_src = SRC
    from INPRCADJ
    where CLS = @p_cls and NUM = @p_num
  if @@rowcount = 0
  begin
    select @err_msg = '指定的单据不存在(CLS = ''' + rtrim(@p_cls) + ''', NUM = ''' + rtrim(@p_num) + ''')。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end
  if @m_stat = 0
  begin
    select @err_msg = '发送的不是已审核的单据。'
    raiserror(@err_msg, 16, 1)
    return(1)
  end

  if @m_src = @usergid
  begin
    -- 发送来源单位是本店的单据
    update INPRCADJ set
      SNDTIME = @cur_time
      where CLS = @p_cls and NUM = @p_num
    declare c cursor for
      select STORE
      from INPRCADJLACDTL
      where CLS = @p_cls and NUM = @p_num
        and STORE <> @usergid
      for read only
    open c
    fetch next from c into @d_rcv
    while @@fetch_status = 0
    begin
      exec GETNETBILLID @n_billid output
      insert into NINPRCADJ (
        SRC, ID, CLS, NUM, ADJDATE,
        INBILL, INCLS, INNUM, INLINE, SUBWRH,
        VENDOR, GDGID, NEWPRC, FILDATE, FILLER,
        STAT, CHECKER, CHKDATE, OLDSRC, PSR,
        NOTE, SNDTIME, RCV, RCVTIME, TYPE,
        NSTAT, FRCFLAG, NNOTE)
        select
        @usergid, @n_billid, CLS, NUM, ADJDATE,
        INBILL, INCLS, INNUM, INLINE, SUBWRH,
        VENDOR, GDGID, NEWPRC, FILDATE, FILLER,
        STAT, CHECKER, CHKDATE, SRC, PSR,
        NOTE, @cur_time, @d_rcv, null, 0,
        0, @p_frcflag, null
        from INPRCADJ
        where CLS = @p_cls and NUM = @p_num
      -- 配货出货单
      insert into NINPRCADJDTL (
        SRC, ID, LINE, STORE, BILL,
        BILLCLS, BILLNUM, BILLLINE, QTY, INCOST,
        OUTCOST, AMT, ADJINCOST, ADJOUTCOST, ADJAMT,
        LACTIME, BILLSRCNUM, NOTE, SUBWRH)
        select
        @usergid, @n_billid, i.LINE, i.STORE, i.BILL,
        i.BILLCLS, i.BILLNUM, i.BILLLINE, i.QTY, 0,
        0, i.AMT, 0, 0, i.ADJAMT,
        i.LACTIME, i.BILLSRCNUM, i.NOTE, i.SUBWRH
        from INPRCADJDTL i inner join STKOUT s on i.BILLCLS = s.CLS and i.BILLNUM = s.NUM
        where i.CLS = @p_cls and i.NUM = @p_num
          and i.BILL = 'STKOUT' and i.BILLCLS = '配货'
          and i.STORE = @usergid and s.BILLTO = @d_rcv
      -- 配货出货退货单
      insert into NINPRCADJDTL (
        SRC, ID, LINE, STORE, BILL,
        BILLCLS, BILLNUM, BILLLINE, QTY, INCOST,
        OUTCOST, AMT, ADJINCOST, ADJOUTCOST, ADJAMT,
        LACTIME, BILLSRCNUM, NOTE, SUBWRH)
        select
        @usergid, @n_billid, i.LINE, i.STORE, i.BILL,
        i.BILLCLS, i.BILLNUM, i.BILLLINE, i.QTY, 0,
        0, i.AMT, 0, 0, i.ADJAMT,
        i.LACTIME, i.BILLSRCNUM, i.NOTE, i.SUBWRH
        from INPRCADJDTL i inner join STKOUTBCK s on i.BILLCLS = s.CLS and i.BILLNUM = s.NUM
        where i.CLS = @p_cls and i.NUM = @p_num
          and i.BILL = 'STKOUTBCK' and i.BILLCLS = '配货'
          and i.STORE = @usergid and s.BILLTO = @d_rcv
      -- 直配出货单、直配出货退货单
      insert into NINPRCADJDTL (
        SRC, ID, LINE, STORE, BILL,
        BILLCLS, BILLNUM, BILLLINE, QTY, INCOST,
        OUTCOST, AMT, ADJINCOST, ADJOUTCOST, ADJAMT,
        LACTIME, BILLSRCNUM, NOTE, SUBWRH)
        select
        @usergid, @n_billid, i.LINE, i.STORE, i.BILL,
        i.BILLCLS, i.BILLNUM, i.BILLLINE, i.QTY, 0,
        0, i.AMT, 0, 0, i.ADJAMT,
        i.LACTIME, i.BILLSRCNUM, i.NOTE, i.SUBWRH
        from INPRCADJDTL i inner join DIRALC s on i.BILLCLS = s.CLS and i.BILLNUM = s.NUM
        where i.CLS = @p_cls and i.NUM = @p_num
          and i.BILL = 'DIRALC' and i.BILLCLS in ('直配出', '直配出退')
          and i.STORE = @usergid and s.RECEIVER = @d_rcv

      fetch next from c into @d_rcv
    end
    close c
    deallocate c

  end else
  begin
    -- 发送来源单据非本店的单据，发送回来源单位
    exec GETNETBILLID @n_billid output
    insert into NINPRCADJ (
      SRC, ID, CLS, NUM, ADJDATE,
      INBILL, INCLS, INNUM, INLINE, SUBWRH,
      VENDOR, GDGID, NEWPRC, FILDATE, FILLER,
      STAT, CHECKER, CHKDATE, OLDSRC, PSR,
      NOTE, SNDTIME, RCV, RCVTIME, TYPE,
      NSTAT, FRCFLAG, NNOTE)
      select
      @usergid, @n_billid, CLS, NUM, ADJDATE,
      INBILL, INCLS, INNUM, INLINE, SUBWRH,
      VENDOR, GDGID, NEWPRC, FILDATE, FILLER,
      STAT, CHECKER, CHKDATE, SRC, PSR,
      NOTE, @cur_time, SRC, null, 0,
      0, @p_frcflag, null
      from INPRCADJ
      where CLS = @p_cls and NUM = @p_num
    update INPRCADJ set
      SNDTIME = @cur_time
      where CLS = @p_cls and NUM = @p_num
    insert into NINPRCADJAINVDTL (
      SRC, ID, LINE, WRH, SUBWRH,
      QTY, COST)
      select
      @usergid, @n_billid, LINE, WRH, SUBWRH,
      QTY, COST
      from INPRCADJAINVDTL
      where CLS = @p_cls and NUM = @p_num
    insert into NINPRCADJINVDTL (
      SRC, ID, LINE, STORE, QTY,
      COST, ADJCOST, LACTIME, NOTE)
      select
      @usergid, @n_billid, LINE, STORE, QTY,
      COST, ADJCOST, LACTIME, NOTE
      from INPRCADJINVDTL
      where CLS = @p_cls and NUM = @p_num
    insert into NINPRCADJDTL (
      SRC, ID, LINE, STORE, BILL,
      BILLCLS, BILLNUM, BILLLINE, QTY, INCOST,
      OUTCOST, AMT, ADJINCOST, ADJOUTCOST, ADJAMT,
      LACTIME, BILLSRCNUM, NOTE, SUBWRH)
      select
      @usergid, @n_billid, LINE, STORE, BILL,
      BILLCLS, BILLNUM, BILLLINE, QTY, INCOST,
      OUTCOST, AMT, ADJINCOST, ADJOUTCOST, ADJAMT,
      LACTIME, BILLSRCNUM, NOTE, SUBWRH
      from INPRCADJDTL
      where CLS = @p_cls and NUM = @p_num

  end

  return(@ret_status)
end

GO
