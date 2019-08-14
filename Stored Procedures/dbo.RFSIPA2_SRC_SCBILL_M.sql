SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFSIPA2_SRC_SCBILL_M](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @usergid int,
  @err_msg varchar(200) = '' output
) as
begin
  declare @n_bill char(10), @n_billcls char(10), @n_billnum varchar(14),
    @n_billsrcnum char(10)
  declare @d_bill char(10), @d_billcls char(10), @d_billnum varchar(14),
    @d_billline smallint, @d_adjalcamt money
  
  declare c3 cursor for
    select BILL, BILLCLS, BILLNUM, BILLLINE, BILLSRCNUM, ADJALCAMT
    from IPA2DTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
    and STORE <> @usergid
    for update
  open c3
  fetch next from c3 into @n_bill, @n_billcls, @n_billnum, @d_billline, @n_billsrcnum,
    @d_adjalcamt
  while @@fetch_status = 0
  begin
    if @n_bill = 'STKOUT' and @n_billcls = '配货'
    begin
      select @d_bill = 'STKIN', @d_billcls = CLS, @d_billnum = NUM 
        from STKIN 
        where CLS = '配货' and (SRCNUM = @n_billnum or NUM = @n_billsrcnum)
        and STAT not in (0, 7)
      if @@rowcount = 1
      begin
        insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
          SRCNUM, WRH, QTY, ADJFLAG, BILLCOST,
          ADJCOST)
          select @@spid, 'STKIN', m.CLS, m.NUM, d.LINE,
          m.SRCNUM, d.WRH, d.QTY, '100', d.COST,
          @d_adjalcamt
          from STKIN m, STKINDTL2 d
          where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
          and m.CLS = @d_billcls and m.NUM = @d_billnum and d.LINE = @d_billline
          and d.SUBWRH = @p_subwrh
        delete from IPA2DTL where current of c3
      end
    end
    else if @n_bill = 'DIRALC' and @n_billcls = '直配出'
    begin
      select @d_bill = 'DIRALC', @d_billcls = CLS, @d_billnum = NUM 
        from DIRALC 
        where CLS = '直配进' and (SRCNUM = @n_billnum or NUM = @n_billsrcnum)
        and STAT not in (0, 7)
      if @@rowcount = 1
      begin
        insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
          SRCNUM, WRH, QTY, ADJFLAG, BILLCOST,
          ADJCOST)
          select @@spid, 'DIRALC', m.CLS, m.NUM, d.LINE,
          m.SRCNUM, d.WRH, d.QTY, '100', d.COST,
          @d_adjalcamt
          from DIRALC m, DIRALCDTL2 d
          where m.CLS = d.CLS and m.NUM = d.NUM and m.STAT not in (0, 7)
          and m.CLS = @d_billcls and m.NUM = @d_billnum and d.LINE = @d_billline
          and d.SUBWRH = @p_subwrh
        delete from IPA2DTL where current of c3
      end
    end
    else if @n_bill = 'MXF' and @n_billcls = '调入'
    begin
      select @d_bill = 'MXF', @d_billcls = '调入', @d_billnum = NUM
        from MXF
        where NUM = @n_billnum and STAT not in (0, 7)
        and TOSTORE = @usergid
      if @@rowcount = 1
      begin
        insert into TMP_IPADTL (SPID, BILL, CLS, NUM, LINE, 
          SRCNUM, WRH, QTY, ADJFLAG, BILLCOST,
          ADJCOST)
          select @@spid, 'MXF', '调入', m.NUM, d.LINE,
          null, d.WRH, d.QTY, '100', d.COST,
          @d_adjalcamt
          from MXF m, MXFDTL2 d
          where m.NUM = d.NUM and m.STAT not in (0, 7)
          and m.NUM = @d_billnum and d.LINE = @d_billline
          and d.SUBWRH = @p_subwrh and d.FROMTO = 1
        delete from IPA2DTL where current of c3
      end
    end
    fetch next from c3 into @n_bill, @n_billcls, @n_billnum, @d_billline, @n_billsrcnum,
      @d_adjalcamt
  end
  close c3
  deallocate c3
  
  return(0)
end
GO
