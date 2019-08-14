SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[INPRCADJDTLCHK](
  @p_cls char(10),
  @p_num char(10),
  @p_line smallint,
  @p_gdgid int,
  @cur_date datetime,
  @cur_settleno int,
  @err_msg varchar(200) = '' output
) as
begin
  declare
    @d_wrh int,
    @d_bill char(10),
    @d_billcls char(10),
    @d_billnum char(10),
    @d_billline smallint,
    @d_subwrh int,
    @d_adjincost money,
    @d_adjoutcost money,
    @d_adjamt money,
    @d_vdrgid int,
    @d_psrgid int,
    @d_cstgid int,
    @d_slrgid int,
    @d_fromwrh int,
    @d_towrh int

  select @d_bill = BILL, @d_billcls = BILLCLS,
    @d_billnum = BILLNUM, @d_billline = BILLLINE,
    @d_subwrh = SUBWRH, @d_adjincost = ADJINCOST,
    @d_adjoutcost = ADJOUTCOST, @d_adjamt = ADJAMT
    from INPRCADJDTL
    where CLS = @p_cls and NUM = @p_num and LINE = @p_line

  if @d_bill = 'STKIN'
  begin
    select @d_vdrgid = m.BILLTO, @d_psrgid = m.PSR, @d_wrh = d.WRH
      from STKIN m inner join STKINDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where m.CLS = @d_billcls and m.NUM = @d_billnum
        and d.LINE = @d_billline
    if @d_billcls = '自营'
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)
    else if @d_billcls = '配货'
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJ_T_B, PJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)
/*    else if @d_billcls = '调入'
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        DJ_T_B, DJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)*/
  end

  if @d_bill = 'STKINBCK'
  begin
    select @d_vdrgid = m.BILLTO, @d_psrgid = m.PSR, @d_wrh = d.WRH
      from STKINBCK m inner join STKINBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where m.CLS = @d_billcls and m.NUM = @d_billnum
        and d.LINE = @d_billline
    if @d_billcls = '自营'
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_T_B, ZJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        - @d_adjincost, - @d_adjincost)
    else if @d_billcls = '配货'
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJT_T_B, PJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        - @d_adjincost, - @d_adjincost)
  end

  if @d_bill = 'STKOUT'
  begin
    select @d_cstgid = m.BILLTO, @d_slrgid = m.SLR, @d_wrh = d.WRH
      from STKOUT m inner join STKOUTDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where m.CLS = @d_billcls and m.NUM = @d_billnum
        and d.LINE = @d_billline
    select @d_vdrgid = BILLTO
      from GOODSH where GID = @p_gdgid
    if @d_billcls = '批发'
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        @d_adjoutcost)
    else if @d_billcls = '配货'
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PC_I_B, PC_T_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        @d_adjoutcost, @d_adjamt)
/*    else if @d_billcls = '调出'
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        DC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        @d_adjoutcost)*/
  end

  if @d_bill = 'STKOUTBCK'
  begin
    select @d_cstgid = m.BILLTO, @d_slrgid = m.SLR, @d_wrh = d.WRH
      from STKOUTBCK m inner join STKOUTBCKDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where m.CLS = @d_billcls and m.NUM = @d_billnum
        and d.LINE = @d_billline
    select @d_vdrgid = BILLTO
      from GOODSH where GID = @p_gdgid
    if @d_billcls = '批发'
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        - @d_adjoutcost)
    else if @d_billcls = '配货'
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PCT_T_B, PCT_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        - @d_adjamt, - @d_adjoutcost)
  end

  if @d_bill = 'RTL'
  begin
    select @d_cstgid = 1, @d_slrgid = 1, @d_wrh = m.WRH
      from RTL m inner join RTLDTL d on m.NUM = d.NUM
      where m.NUM = @d_billnum and d.LINE = @d_billline
    select @d_vdrgid = BILLTO
      from GOODSH where GID = @p_gdgid
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LS_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
      @d_adjoutcost)
  end

  if @d_bill = 'RTLBCK'
  begin
    select @d_cstgid = 1, @d_slrgid = 1, @d_wrh = m.WRH
      from RTLBCK m inner join RTLBCKDTL d on m.NUM = d.NUM
      where m.NUM = @d_billnum and d.LINE = @d_billline
    select @d_vdrgid = BILLTO
      from GOODSH where GID = @p_gdgid
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LST_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
      - @d_adjoutcost)
  end

  if @d_bill = 'DIRALC'
  begin
    select @d_vdrgid = m.VENDOR, @d_cstgid = m.RECEIVER,
      @d_psrgid = PSR, @d_slrgid = SLR, @d_wrh = d.WRH
      from DIRALC m inner join DIRALCDTL d on m.CLS = d.CLS and m.NUM = d.NUM
      where m.CLS = @d_billcls and m.NUM = @d_billnum
        and d.LINE = @d_billline
    if @d_billcls = '直配进'
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_T_B, ZPJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)
    else if @d_billcls = '直配进退'
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJT_T_B, ZPJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        - @d_adjincost, - @d_adjincost)
    else if @d_billcls = '直配出'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_I_B, ZPC_T_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        @d_adjoutcost, @d_adjamt)
    end
    else if @d_billcls = '直配出退'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_T_B, ZJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        - @d_adjincost, - @d_adjincost)
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPCT_I_B, ZPCT_T_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        - @d_adjoutcost, - @d_adjamt)
    end
    else if @d_billcls = '直销'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        @d_adjincost, @d_adjincost)
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        @d_adjoutcost)
    end
    else if @d_billcls = '直销退'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_T_B, ZJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_vdrgid, @d_psrgid,
        - @d_adjincost, - @d_adjincost)
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @d_cstgid, @d_slrgid, @d_vdrgid,
        - @d_adjoutcost)
    end
  end
  
  if @d_bill = 'XF'
  begin
    select @d_fromwrh = FROMWRH, @d_towrh = TOWRH
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where m.NUM = @d_billnum
        and d.LINE = @d_billline
    if @d_billcls = '调出'
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDC_I)
        values (@cur_date, @cur_settleno, @d_fromwrh, @p_gdgid, 1, 1,
        @d_adjoutcost)
    else if @d_billcls = '调入'
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDJ_I)
        values (@cur_date, @cur_settleno, @d_towrh, @p_gdgid, 1, 1,
        @d_adjincost)
  end

  update INPRCADJDTL set LACTIME = getdate()
    where CLS = @p_cls and NUM = @p_num and LINE = @p_line

  return(0)
end

GO
