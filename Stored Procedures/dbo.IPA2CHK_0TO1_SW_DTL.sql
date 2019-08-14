SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[IPA2CHK_0TO1_SW_DTL](
  @p_cls char(10),
  @p_num char(10),
  @p_subwrh int,
  @p_line smallint,
  @p_gdgid int,
  @usergid int,
  @cur_settleno int,
  @cur_date datetime,
  @err_msg varchar(200) = '' output
) as
begin
  declare @d_bill char(10), @d_billcls char(10), @d_billnum varchar(14),
    @d_billline smallint, @d_wrh int, @d_adjincost money,
    @d_adjoutcost money, @d_adjalcamt money
  declare @b_vdrgid int, @b_psrgid int, @b_cstgid int,
    @b_slrgid int

  select @d_bill = BILL, @d_billcls = BILLCLS, @d_billnum = BILLNUM,
    @d_billline = BILLLINE, @d_wrh = WRH, @d_adjincost = ADJINCOST,
    @d_adjoutcost = ADJOUTCOST, @d_adjalcamt = ADJALCAMT
    from IPA2DTL
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh and LINE = @p_line

  --可能的单据类型有：
  --STKIN（自营、配货）, STKINBCK（自营）, STKOUT（批发、配货）, STKOUTBCK（批发、配货）
  --DIRALC（直配出、直配出退、直配进、直配进退、直销、直销退）
  --RTL, RTLBCK, LS, OVF, XF（调入、调出）, MXF, 出货
  if @d_bill = 'STKIN'
  begin
    --不考虑：调入
    select @b_vdrgid = BILLTO, @b_psrgid = PSR
      from STKIN (nolock) where CLS = @d_billcls and NUM = @d_billnum
    if @d_billcls = '自营'
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        @d_adjincost, @d_adjincost)
    else if @d_billcls = '配货'
      insert into PJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        PJ_T_B, PJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        @d_adjincost, @d_adjincost)
  end else if @d_bill = 'STKINBCK'
  begin
    --不需要考虑：配货
    select @b_vdrgid = BILLTO, @b_psrgid = PSR
      from STKINBCK (nolock) where CLS = @d_billcls and NUM = @d_billnum
    if @d_billcls = '自营'
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        - @d_adjincost)
  end else if @d_bill = 'STKOUT'
  begin
    --暂不考虑调出单
    select @b_cstgid = BILLTO, @b_slrgid = SLR
      from STKOUT (nolock) where CLS = @d_billcls and NUM = @d_billnum
    select @b_vdrgid = BILLTO
      from GOODSH (nolock) where GID = @p_gdgid
    if @d_billcls = '批发'
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        @d_adjoutcost)
    else if @d_billcls = '配货'
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PC_I_B, PC_T_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        @d_adjoutcost, @d_adjalcamt)
  end else if @d_bill = 'STKOUTBCK'
  begin
    select @b_cstgid = BILLTO, @b_slrgid = SLR
      from STKOUTBCK (nolock) where CLS = @d_billcls and NUM = @d_billnum
    select @b_vdrgid = BILLTO
      from GOODSH (nolock) where gid = @p_gdgid
    if @d_billcls = '批发'
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        - @d_adjoutcost)
    else if @d_billcls = '配货'
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        PCT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        - @d_adjoutcost)
  end else if @d_bill = 'DIRALC'
  begin
    select @b_vdrgid = VENDOR, @b_cstgid = RECEIVER,
      @b_psrgid = PSR, @b_slrgid = SLR
      from DIRALC (nolock) where CLS = @d_billcls and NUM = @d_billnum
    if @d_billcls = '直配出'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        @d_adjincost, @d_adjincost)
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_I_B, ZPC_T_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        @d_adjoutcost, @d_adjalcamt)
    end else if @d_billcls = '直配出退'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        - @d_adjincost)
      insert into PC (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        ZPC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        - @d_adjoutcost)
    end else if @d_billcls = '直配进'
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_T_B, ZPJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        @d_adjincost, @d_adjincost)
    else if @d_billcls = '直配进退'
      insert into ZPJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZPJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        - @d_adjincost)
    else if @d_billcls = '直销'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJ_T_B, ZJ_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        @d_adjincost, @d_adjincost)
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WC_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        @d_adjoutcost)
    end else if @d_billcls = '直销退'
    begin
      insert into ZJ (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BPSRGID,
        ZJT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_psrgid,
        - @d_adjincost)
      insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
        WCT_I_B)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
        - @d_adjoutcost)
    end
  end else if @d_bill = 'RTL'
  begin
    select @b_cstgid = 1, @b_slrgid = 1, @b_vdrgid = BILLTO
      from GOODSH (nolock) where GID = @p_gdgid
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LS_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
      @d_adjoutcost)
  end else if @d_bill = 'RTLBCK'
  begin
    select @b_cstgid = 1, @b_slrgid = 1, @b_vdrgid = BILLTO
      from GOODSH (nolock) where GID = @p_gdgid
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,
      LST_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_cstgid, @b_slrgid, @b_vdrgid,
      - @d_adjoutcost)
  end else if @d_bill = 'LS'
  begin
    insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
      KS_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid,
      @d_adjoutcost)
  end else if @d_bill = 'OVF'
  begin
    insert into KC (ADATE, ASETTLENO, BWRH, BGDGID,
      KY_I_B)
      values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid,
      @d_adjincost)
  end else if @d_bill = 'XF'
  begin
    if @d_billcls = '调出'
    begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDC_I)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, 1, 1,
        @d_adjoutcost)
    end else if @d_billcls = '调入'
    begin
      insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
        NDJ_I)
        values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, 1, 1,
        @d_adjincost)
    end
  end else if @d_bill = 'MXF'
  begin
    if (select PROPERTY from STORE where GID = @usergid) >= 8
    begin
      --总部，调出记到进货报表调入项，调入记到出货报表调出项。
      select @b_vdrgid = FROMSTORE, @b_cstgid = TOSTORE
        from MXF (nolock) where NUM = @d_billnum
      if @d_billcls = '调出'
        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID,
          DJ_I_B)
          values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid,
          @d_adjincost)
      else if @d_billcls = '调入'
        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID, BCSTGID,
          DC_I_B, DC_T_B)
          values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid, @b_cstgid,
          @d_adjoutcost, @d_adjalcamt)
    end else
    begin
      --门店
      select @b_vdrgid = XCHGSTORE
        from MXF (nolock) where NUM = @d_billnum
      if @d_billcls = '调入'
        insert into DB (ADATE, ASETTLENO, BWRH, BGDGID, BVDRGID,
          DJ_I_B, DJ_T_B)
          values (@cur_date, @cur_settleno, @d_wrh, @p_gdgid, @b_vdrgid,
          @d_adjincost, @d_adjincost)
    end
  end else if @d_bill = '出货'
  begin
    if not exists (select 1 from INVCHGDRPT
      where ASTORE = @usergid and ASETTLENO = @cur_settleno
      and ADATE = @cur_date and BGDGID = @p_gdgid and BWRH = @d_wrh)
      insert into INVCHGDRPT (ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
        DI8, LSTUPDTIME)
        values (@usergid, @cur_settleno, @cur_date, @p_gdgid, @d_wrh,
        @d_adjoutcost, getdate())
    else
      update INVCHGDRPT set
        DI8 = DI8 + @d_adjoutcost,
        LSTUPDTIME = getdate()
        where ASTORE = @usergid and ASETTLENO = @cur_settleno
        and ADATE = @cur_date and BGDGID = @p_gdgid and BWRH = @d_wrh
  end

  update IPA2DTL set
    LACTIME = getdate()
    where CLS = @p_cls and NUM = @p_num and SUBWRH = @p_subwrh
      and LINE = @p_line

  return(0)
end
GO
