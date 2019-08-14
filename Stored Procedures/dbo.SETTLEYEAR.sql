SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SETTLEYEAR](
  @empcode char(10),
  @domonth smallint
) with encryption as
begin
--
--  return 0 if success
--         1 if has been done today
--         2 if time is earlier than before
--  期末值: 库存年报
--  增加:   年结转
--  期初值: 进货年报,库存调整年报,出货年报,供应商帐款年报,客户帐款年报
--
  declare
    @new_settleno int,
    @old_settleno int,
    @begindate datetime,
    @begintime datetime,
    @endtime datetime,
    @empname char(20),
    @store int,
    @nano int

  -- check validity
  select @old_settleno = MAX(NO) from YEARSETTLE
  select
    @begindate = convert(datetime, convert(char, BEGINDATE, 102)),
    @begintime = BEGINDATE,
    @endtime = ENDDATE
    from YEARSETTLE
    where NO = @old_settleno
  if @begindate = convert(datetime, convert(char, getdate(), 102))
    return 1
  if (@begintime > getdate()) or (@endtime < getdate())
    return 2

  select
    @store = USERGID
    from SYSTEM

  -- 库存年报期末值
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '库存年报期末值' )
  waitfor delay '0:0:1'
  update INVYRPT set
    FQ = V_INV.QTY,
    FT = V_INV.TOTAL,
    FINPRC = GOODS.INPRC,
    FRTLPRC = GOODS.RTLPRC,
    FDXPRC = GOODS.DXPRC,
    FPAYRATE = GOODS.PAYRATE,
    FINVPRC = isnull(GDWRH.INVPRC, GOODS.INVPRC),
    FLSTINPRC = GOODS.LSTINPRC,
    FINVCOST = isnull(GDWRH.INVCOST, 0) --2002-06-13
    from V_INV, GOODS, GDWRH --2002.08.18
    where INVYRPT.ASETTLENO = @old_settleno
    and INVYRPT.BWRH = V_INV.WRH
    and INVYRPT.BGDGID = V_INV.GDGID
    and INVYRPT.BGDGID = GOODS.GID
    and INVYRPT.ASTORE = @store
    and V_INV.STORE = @store
    and INVYRPT.BGDGID *= GDWRH.GDGID
    and INVYRPT.BWRH *= GDWRH.WRH
  --Added by wang xin 2003.02.17
  if (select BATCHFLAG from SYSTEM) = 2
  begin
      update INVYRPT set 
      FINVCOST = isnull(COST, 0) 
      from V_SUBINV
      where INVYRPT.ASETTLENO = @old_settleno
      and INVYRPT.BWRH *= V_SUBINV.WRH 
      and INVYRPT.BGDGID *= V_SUBINV.GDGID
      and INVYRPT.ASTORE = @store     		
  end
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '修改库存年报期末值失败' )
    raiserror('修改库存年报期末值失败', 16, 1)
    RETURN 3
  end

  -- 修改YEARSETTLE：本期结束时间，结转人
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '修改YEARSETTLE：本期结束时间，结转人' )
  waitfor delay '0:0:1'
  select @empname = NAME from EMPLOYEE where CODE = @empcode
  update YEARSETTLE set
    ENDDATE = GETDATE(),
    EMPLOYEECODE = @empcode,
    EMPLOYEENAME = @empname
    where NO = @old_settleno
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '修改YEARSETTLE失败' )
    raiserror('修改YEARSETTLE失败', 16, 1)
    RETURN 3
  end

  -- 增加YEARSETTLE：起始时间
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加YEARSETTLE' )
  waitfor delay '0:0:1'
  select @new_settleno = (select max(NO) from monthsettle) + 1
  select @nano = NANO from monthsettle where no = (select max(NO) from monthsettle)/*2003.04.15*/
  exec NextNaNo @nano, @nano output
  insert into YEARSETTLE (NO, BEGINDATE, NANO)
  values (@new_settleno, GETDATE(), @nano)
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加YEARSETTLE失败' )
    raiserror('增加YEARSETTLE失败', 16, 1)
    RETURN 3
  end

  -- 库存年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '库存年报' )
  waitfor delay '0:0:1'
  insert into INVYRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
    CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST)
  select @new_settleno, V_INV.GDGID, V_INV.WRH, @store,
    V_INV.QTY, V_INV.TOTAL, V_INV.QTY, V_INV.TOTAL,
    GOODS.INPRC, GOODS.RTLPRC, GOODS.DXPRC, GOODS.PAYRATE, isnull(GDWRH.INVPRC, GOODS.INVPRC),
    GOODS.LSTINPRC, isnull(GDWRH.INVCOST, 0)
  from V_INV, GOODS, GDWRH 
  where V_INV.GDGID = GOODS.GID and V_INV.STORE = @store
    and V_INV.GDGID *= GDWRH.GDGID and V_INV.WRH *= GDWRH.WRH
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加库存年报失败' )
    raiserror('增加库存年报失败', 16, 1)
    RETURN 3
  end

  -- 进货年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '进货年报' )
  waitfor delay '0:0:1'
  insert into INYRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE,
    CQ1, CQ2, CQ3, CQ4,
    CT1, CT2, CT3, CT4,
    CI1, CI2, CI3, CI4,
    CR1, CR2, CR3, CR4)
  select @new_settleno, BGDGID, BVDRGID, BWRH, @store,
    CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
    CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
    CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4,
    CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4
  from INYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加进货年报失败' )
    raiserror('增加进货年报失败', 16, 1)
    RETURN 3
  end

  -- 库存调整年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '库存调整年报' )
  waitfor delay '0:0:1'
  insert into INVCHGYRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
    CQ1, CQ2, CQ4, CQ5,
    CI1, CI2, CI3, CI4, CI5,
    CR1, CR2, CR3, CR4, CR5)
  select @new_settleno, BGDGID, BWRH, @store,
    CQ1 + DQ1, CQ2 + DQ2, CQ4 + DQ4, CQ5 + DQ5,
    CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4, CI5 + DI5,
    CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4, CR5 + DR5
  from INVCHGYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加库存调整年报失败' )
    raiserror('增加库存调整年报失败', 16, 1)
    RETURN 3
  end

  -- 出货年报
  /*insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '出货年报' )
  waitfor delay '0:0:1'
  insert into OUTYRPT ( ASETTLENO, BGDGID, BWRH, BCSTGID, ASTORE,
    CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7,
    CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
    CI1, CI2, CI3, CI4, CI5, CI6, CI7,
    CR1, CR2, CR3, CR4, CR5, CR6, CR7 )
  select @new_settleno, BGDGID, BWRH, BCSTGID, @store,
    CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4, CQ5 + DQ5, CQ6 + DQ6, CQ7 + DQ7,
    CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4, CT5 + DT5, CT6 + DT6, CT7 + DT7,
    CT91 + DT91, CT92 + DT92,
    CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4, CI5 + DI5, CI6 + DI6, CI7 + DI7,
    CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4, CR5 + DR5, CR6 + DR6, CR7 + DR7
  from OUTYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加出货年报失败' )
    raiserror('增加出货年报失败', 16, 1)
    RETURN 3
  end
*/
  -- 供应商帐款年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '供应商帐款年报' )
  waitfor delay '0:0:1'
  insert into VDRYRPT ( ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE,
   CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
   CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, ci2)
  select @new_settleno, BVDRGID, BWRH, BGDGID, @store,
    CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4, CQ5 + DQ5, CQ6 + DQ6,
    CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4, CT5 + DT5, CT6 + DT6,
    CT7 + DT7, CT8 + DT3 - DT4 + DT6, ci2 + di2
  from VDRYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加供应商帐款年报失败' )
    raiserror('增加供应商帐款年报失败', 16, 1)
    RETURN 3
  end

  -- 客户年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '客户年报' )
  waitfor delay '0:0:1'
  insert into CSTYRPT ( ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE,
   CQ1, CQ2, CQ3,
   CT1, CT2, CT3, CT4 )
  select @new_settleno, BCSTGID, BWRH, BGDGID, @store,
    CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3,
    CT1 + DT1, CT2 + DT2, CT3 + DT3,
    CT4 + DT3 - DT1
  from CSTYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加客户年报失败' )
    raiserror('增加客户年报失败', 16, 1)
    RETURN 3
  end

  -- 加工年报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '加工年报' )
  waitfor delay '0:0:1'
  insert into PROCYRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
    CQ1, CT1, CI1, CR1, CD1)
  select @new_settleno, BGDGID, BWRH, @store,
    CQ1 + DQ1, CT1 + DT1, CI1 + DI1, CR1 + DR1, CD1 + DD1 
  from PROCYRPT
  where ASETTLENO = @old_settleno
  and ASTORE = @store
  if @@error <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEYEAR', '', 'SETTLEYEAR', 101, '增加加工年报失败' )
    raiserror('增加加工年报失败', 16, 1)
    RETURN 3
  end

  --if @domonth = 1
    execute SETTLEMONTH @empcode, 0

  return 0
end
GO
