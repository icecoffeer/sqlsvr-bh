SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[SETTLEDAY](
  @old_settleno int,
  @old_date datetime,
  @new_settleno int,
  @new_date datetime
)
as
begin
--
--  期末值: 库存日报
--  期初值: 库存日报, 进货日报,库存调整日报,出货日报
--
  declare
    @store int,         @oldft money,
    @newct money
  declare @errmsg varchar(200)

  --Fanduoyi 2004.01.06 1186 解决期末库存日报两倍问题
  declare @isdouble integer, @newsettleno integer, @oldsettleno integer
  exec optreadint 0, 'InvDRptDoubleLastDayRec', 0 , @isdouble output


  select
    @store = USERGID
    from SYSTEM(nolock)

  --如修改请同步修改存储过程最后那段
  if @isdouble = 0
  begin
    select @oldsettleno = max(no) from monthsettle where dateadd(day,-1, getdate()) between begindate and enddate
    select @newsettleno = max(no) from monthsettle where getdate() between begindate and enddate

    if (@oldsettleno) <> (@newsettleno)
    begin
        if exists (select 1 from invdrpt(nolock) where asettleno = @newsettleno
                         and adate = convert(char(10),dateadd(day,-1, getdate()), 102) and astore=@store )
        begin
            delete from invdrpt
            where asettleno = @newsettleno and adate = convert(char(10),dateadd(day,-1, getdate()), 102)
        end
    end
  end

  --3114 判断是否已经日结的规则修正
  if exists (select 1 from INVDRPT(nolock) where ASETTLENO = @new_settleno and ADATE = @new_date and astore=@store)
  begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      select getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101, '当日已存在库存日报记录数：' +CAST(count(1) as varchar(10))
      from invdrpt(nolock) where ASETTLENO = @new_settleno and ADATE = @new_date and astore=@store
      return 1
  end

  if exists (select 1 from goods a(nolock) where not exists (select 1 from goodsh b(nolock) where a.gid=b.GID))
  begin
    begin try
    insert into goodsh
      select * from goods a(nolock) where not exists (select 1 from goodsh b(nolock) where a.gid=b.GID)
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,    TYPE, CONTENT)
      values (getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101, '补齐商品总表数据成功' )
  end try
  begin catch
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,    TYPE, CONTENT)
      values (getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101, '补齐商品总表数据失败' )
  end catch
  end

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,    TYPE, CONTENT)
  select getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101,
        '快照当前库存数，营销方式：'+cast(b.SALE as varchar(1))+',库存数:'+cast(SUM(a.QTY) as varchar)
  from inv a(nolock) left join goodsh b(nolock) on a.GDGID=b.GID
  group by b.SALE

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,    TYPE, CONTENT)
  select getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101,
        '快照当前库存额，营销方式：'+cast(b.SALE as varchar(1))+',库存额:'+cast(SUM(a.invcost) as varchar)
  from gdwrh a(nolock) left join goodsh b(nolock) on a.GDGID=b.GID
  group by b.SALE


  -- 上日库存日报期末值
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'SETTLEDAY', 'HDSVC',
  'SETTLEDAY', 101, '上日库存日报期末值' )
  waitfor delay '0:0:1'

  BEGIN TRY
    update INVDRPT set
      FQ = V_INV.QTY,
      FT = V_INV.TOTAL,
      FINPRC = GOODSH.INPRC,
      FRTLPRC = GOODSH.RTLPRC,
      FDXPRC = GOODSH.DXPRC,
      FPAYRATE = GOODSH.PAYRATE,
      FLSTINPRC = GOODSH.LSTINPRC,
      LSTUPDTIME = getdate()
      from V_INV, GOODSH
      where INVDRPT.ASETTLENO = @old_settleno
      and INVDRPT.ADATE = @old_date
      and INVDRPT.BWRH = V_INV.WRH
      and INVDRPT.BGDGID = V_INV.GDGID
      and V_INV.STORE = @store
      and INVDRPT.BGDGID = GOODSH.GID
      and INVDRPT.ASTORE = @store

    update INVDRPT set
      FINPRC = GOODSH.INPRC,
      FRTLPRC = GOODSH.RTLPRC,
      FDXPRC = GOODSH.DXPRC,
      FPAYRATE = GOODSH.PAYRATE,
      FLSTINPRC = GOODSH.LSTINPRC,
      FINVPRC = isnull(GDWRH.INVPRC, GOODSH.INVPRC),
      FINVCOST = isnull(GDWRH.INVCOST, 0),
      LSTUPDTIME = getdate()
      from GDWRH, GOODSH
      where INVDRPT.ASETTLENO = @old_settleno
      and INVDRPT.ADATE = @old_date
      and INVDRPT.BWRH = GDWRH.WRH
      and INVDRPT.BGDGID = GDWRH.GDGID
      and INVDRPT.BGDGID = GOODSH.GID
      and INVDRPT.ASTORE = @store

    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
      values (getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101, '更新上日库存日报期末值成功' )
    END TRY
  BEGIN CATCH
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
      values (getdate(), 'SETTLEDAY', 'HDSVC','SETTLEDAY', 101, '更新上日库存日报期末值失败' )
  END CATCH

  /*
  update INVDRPT set
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
    where INVDRPT.ASETTLENO = @old_settleno
    and INVDRPT.ADATE = @old_date
    and INVDRPT.BWRH = V_INV.WRH
    and INVDRPT.BGDGID = V_INV.GDGID
    and V_INV.STORE = @store
    and INVDRPT.BGDGID = GOODS.GID
    and INVDRPT.ASTORE = @store
    and INVDRPT.BGDGID *= GDWRH.GDGID
    and INVDRPT.BWRH *= GDWRH.WRH  */


  --Addded by wang xin 2003.02.17
  if (select BATCHFLAG from SYSTEM(nolock) ) = 2
  begin
      update INVDRPT set
      FINVCOST = isnull(COST, 0),
      LSTUPDTIME = getdate()
      from V_SUBINV
      where INVDRPT.ASETTLENO = @old_settleno
      and INVDRPT.ADATE = @old_date
      and INVDRPT.BWRH *= V_SUBINV.WRH
      and INVDRPT.BGDGID *= V_SUBINV.GDGID
      and INVDRPT.ASTORE = @store
  end

  if @@error <> 0 return 2

  -- 本日库存日报期初值
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'SETTLEDAY', 'HDSVC',
  'SETTLEDAY', 101, '本日库存日报期初值' )
  waitfor delay '0:0:1'

  BEGIN TRY
    insert into INVDRPT ( ASETTLENO, ADATE, BGDGID, BWRH, ASTORE,
      CQ, CT, FQ, FT,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,
      FINVCOST, LSTUPDTIME )--2002-06-13
    select @new_settleno, @new_date, V_INV.GDGID, V_INV.WRH, @store,
      V_INV.QTY, V_INV.TOTAL, V_INV.QTY, V_INV.TOTAL,
      GOODSH.INPRC, GOODSH.RTLPRC, GOODSH.DXPRC, GOODSH.PAYRATE, isnull(GDWRH.INVPRC, GOODSH.INVPRC),
      GOODSH.LSTINPRC, isnull(GDWRH.INVCOST, 0), getdate() --2002-06-13
    from V_INV, GOODSH, GDWRH  --2002.08.18
    where V_INV.GDGID = GOODSH.GID and V_INV.STORE = @store
      and V_INV.WRH = GDWRH.WRH and V_INV.GDGID = GDWRH.GDGID

     insert into INVDRPT ( ASETTLENO, ADATE, BGDGID, BWRH, ASTORE,
      CQ, CT, FQ, FT,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,
      FINVCOST, LSTUPDTIME )--2002-06-13
    select @new_settleno, @new_date, V_INV.GDGID, V_INV.WRH, @store,
      V_INV.QTY, V_INV.TOTAL, V_INV.QTY, V_INV.TOTAL,
      GOODSH.INPRC, GOODSH.RTLPRC, GOODSH.DXPRC, GOODSH.PAYRATE, GOODSH.INVPRC ,
      GOODSH.LSTINPRC, 0, getdate() --2002-06-13
    from V_INV, GOODSH
    where V_INV.GDGID = GOODSH.GID and V_INV.STORE = @store
      and NOT EXISTS (SELECT 1 FROM gdwrh WHERE V_INV.WRH = GDWRH.WRH and V_INV.GDGID = GDWRH.GDGID  )

    insert into INVDRPT ( ASETTLENO, ADATE, BGDGID, BWRH, ASTORE,
      CQ, CT, FQ, FT,
      FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC,
      FINVCOST, LSTUPDTIME )--2002-06-13
    select @new_settleno, @new_date, GDWRH.GDGID, GDWRH.WRH, @store,
      0 QTY, 0 TOTAL, 0 QTY,0 TOTAL,
      GOODSH.INPRC, GOODSH.RTLPRC, GOODSH.DXPRC, GOODSH.PAYRATE, isnull(GDWRH.INVPRC, GOODSH.INVPRC),
      GOODSH.LSTINPRC, isnull(GDWRH.INVCOST, 0), getdate() --2002-06-13
    from GOODSH, GDWRH  --2002.08.18
    where GDWRH.GDGID = GOODSH.GID
      and NOT EXISTS (SELECT 1 FROM V_INV WHERE V_INV.WRH = GDWRH.WRH and V_INV.GDGID = GDWRH.GDGID  )
    and gdwrh.invcost<>0


    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEDAY', 'HDSVC',
    'SETTLEDAY', 101, '新增本日库存日报期初值成功' )
  END TRY
  BEGIN CATCH
    set @errmsg=error_message()
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEDAY', 'HDSVC',
    'SETTLEDAY', 101, '新增本日库存日报期初值失败'+@errmsg )
  END CATCH

  --Addded by wang xin 2003.02.17
  if (select BATCHFLAG from SYSTEM(nolock) ) = 2
  begin
      update INVDRPT set
      FINVCOST = isnull(COST, 0),
      LSTUPDTIME = getdate()
      from V_SUBINV
      where INVDRPT.ASETTLENO = @new_settleno
      and INVDRPT.ADATE = @new_date
      and INVDRPT.BWRH *= V_SUBINV.WRH
      and INVDRPT.BGDGID *= V_SUBINV.GDGID
      and INVDRPT.ASTORE = @store
  end

  if @@error <> 0 return 3

  -- 进货日报期初值
  truncate table INDRPTI
  /*
  insert into INDRPTI (ASETTLENO, ADATE, BGDGID, BVDRGID, BWRH, ASTORE,
    CQ1, CQ2, CQ3, CQ4,
    CT1, CT2, CT3, CT4,
    CI1, CI2, CI3, CI4,
    CR1, CR2, CR3, CR4)
  select @new_settleno, @new_date, C.BGDGID, C.BVDRGID, C.BWRH, @store,
    CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0),
    CQ3 + ISNULL(DQ3,0), CQ4 + ISNULL(DQ4,0),
    CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0),
    CT3 + ISNULL(DT3,0), CT4 + ISNULL(DT4,0),
    CI1 + ISNULL(DI1,0), CI2 + ISNULL(DI2,0),
    CI3 + ISNULL(DI3,0), CI4 + ISNULL(DI4,0),
    CR1 + ISNULL(DR1,0), CR2 + ISNULL(DR2,0),
    CR3 + ISNULL(DR3,0), CR4 + ISNULL(DR4,0)
  from INDRPTI C, INDRPT D
  where C.ASETTLENO = @old_settleno
  and C.ADATE = @old_date
  and D.ASETTLENO = @old_settleno
  and D.ADATE = @old_date
  and C.BGDGID *= D.BGDGID
  and C.BVDRGID *= D.BVDRGID
  and C.BWRH *= D.BWRH
  and C.ASTORE = @store
  */

  -- 库存调整日报期初值
  truncate table INVCHGDRPTI
  /*
  insert into INVCHGDRPTI (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE,
    CQ1, CQ2, CQ4, CQ5,
    CI1, CI2, CI3, CI4, CI5,
    CR1, CR2, CR3, CR4, CR5)
  select @new_settleno, @new_date, C.BGDGID, C.BWRH, @store,
    CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0),
    CQ4 + ISNULL(DQ4,0), CQ5 + ISNULL(DQ5,0),
    CI1 + ISNULL(DI1,0), CI2 + ISNULL(DI2,0), CI3 + ISNULL(DI3,0),
    CI4 + ISNULL(DI4,0), CI5 + ISNULL(DI5,0),
    CR1 + ISNULL(DR1,0), CR2 + ISNULL(DR2,0), CR3 + ISNULL(DR3,0),
    CR4 + ISNULL(DR4,0), CR5 + ISNULL(DR5,0)
  from INVCHGDRPTI C, INVCHGDRPT D
  where C.ASETTLENO = @old_settleno
  and C.ADATE = @old_date
  and D.ASETTLENO = @old_settleno
  and D.ADATE = @old_date
  and C.BGDGID *= D.BGDGID
  and C.BWRH *= D.BWRH
  and C.ASTORE = @store
  */

  -- 出货日报期初值
  truncate table OUTDRPTI
  /*
  insert into OUTDRPTI (ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH, ASTORE,
    CQ1, CQ2, CQ3, CQ4, CQ5, CQ6, CQ7,
    CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT91, CT92,
    CI1, CI2, CI3, CI4, CI5, CI6, CI7,
    CR1, CR2, CR3, CR4, CR5, CR6, CR7)
  select @new_settleno, @new_date, C.BGDGID, C.BCSTGID, C.BWRH, @store,
    CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0), CQ3 + ISNULL(DQ3,0),
    CQ4 + ISNULL(DQ4,0), CQ5 + ISNULL(DQ5,0), CQ6 + ISNULL(DQ6,0),
    CQ7 + ISNULL(DQ7,0),
    CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0), CT3 + ISNULL(DT3,0),
    CT4 + ISNULL(DT4,0), CT5 + ISNULL(DT5,0), CT6 + ISNULL(DT6,0),
    CT7 + ISNULL(DT7,0),
    CT91 + ISNULL(DT91,0), CT92 + ISNULL(DT92,0),
    CI1 + ISNULL(DI1,0), CI2 + ISNULL(DI2,0), CI3 + ISNULL(DI3,0),
    CI4 + ISNULL(DI4,0), CI5 + ISNULL(DI5,0), CI6 + ISNULL(DI6,0),
    CI7 + ISNULL(DI7,0),
    CR1 + ISNULL(DR1,0), CR2 + ISNULL(DR2,0), CR3 + ISNULL(DR3,0),
    CR4 + ISNULL(DR4,0), CR5 + ISNULL(DR5,0), CR6 + ISNULL(DR6,0),
    CR7 + ISNULL(DR7,0)
  from OUTDRPTI C, OUTDRPT D
  where C.ASETTLENO = @old_settleno
  and C.ADATE = @old_date
  and D.ASETTLENO = @old_settleno
  and D.ADATE = @old_date
  and C.BGDGID *= D.BGDGID
  and C.BCSTGID *= D.BCSTGID
  and C.BWRH *= D.BWRH
  and C.ASTORE = @store
  */

  /*
  -- 客户帐款日报期初值
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'SETTLEDAY', 'HDSVC',
  'SETTLEDAY', 101, '客户帐款日报期初值' )
  waitfor delay '0:0:1'
  if @old_settleno <> @new_settleno
  begin
    insert into CSTDRPTI (ASTORE, ASETTLENO, ADATE, BCSTGID, BWRH, BGDGID,
      CT4 )
    select @store, @new_settleno, @new_date, C.BCSTGID, C.BWRH, C.BGDGID,
      CT4 + ISNULL(DT3,0) - ISNULL(DT1,0)
    from CSTDRPTI C, CSTDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BCSTGID *= D.BCSTGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store
  end
  else
  begin
    insert into CSTDRPTI (ASTORE, ASETTLENO, ADATE, BCSTGID, BWRH, BGDGID,
      CQ1, CQ2, CQ3,
      CT1, CT2, CT3, CT4 )
    select @store, @new_settleno, @new_date, C.BCSTGID, C.BWRH, C.BGDGID,
      CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0), CQ3 + ISNULL(DQ3,0),
      CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0), CT3 + ISNULL(DT3,0),
      CT4 + ISNULL(DT3,0) - ISNULL(DT1,0)
    from CSTDRPTI C, CSTDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BCSTGID *= D.BCSTGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store
  end
  if @@error <> 0 return 4

  -- 供应商帐款日报期初值
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'SETTLEDAY', 'HDSVC',
  'SETTLEDAY', 101, '供应商帐款日报期初值' )
  waitfor delay '0:0:1'
  if @old_settleno <> @new_settleno
  begin
    insert into VDRDRPTI (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID,
      CT8)
    select @store, @new_settleno, @new_date, C.BVDRGID, C.BWRH, C.BGDGID,
      CT8 + ISNULL(DT3,0) - ISNULL(DT4,0) + ISNULL(DT6,0)
    from VDRDRPTI C, VDRDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BVDRGID *= D.BVDRGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store
  end
  else
  begin
    insert into VDRDRPTI (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID,
      CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
      CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, CI2)
    select @store, @new_settleno, @new_date, C.BVDRGID, C.BWRH, C.BGDGID,
      CQ1 + ISNULL(DQ1,0), CQ2 + ISNULL(DQ2,0), CQ3 + ISNULL(DQ3,0),
      CQ4 + ISNULL(DQ4,0), CQ5 + ISNULL(DQ5,0), CQ6 + ISNULL(DQ6,0),
      CT1 + ISNULL(DT1,0), CT2 + ISNULL(DT2,0), CT3 + ISNULL(DT3,0),
      CT4 + ISNULL(DT4,0), CT5 + ISNULL(DT5,0), CT6 + ISNULL(DT6,0),
      CT7 + ISNULL(DT7,0), CT8 + ISNULL(DT3,0) - ISNULL(DT4,0) + ISNULL(DT6,0),
      CI2 + ISNULL(DI2,0)
    from VDRDRPTI C, VDRDRPT D
    where C.ASETTLENO = @old_settleno
    and C.ADATE = @old_date
    and D.ASETTLENO = @old_settleno
    and D.ADATE = @old_date
    and C.BGDGID *= D.BGDGID
    and C.BVDRGID *= D.BVDRGID
    and C.BWRH *= D.BWRH
    and C.ASTORE = @store
    and D.ASTORE = @store
  end    */


  if @isdouble = 0
  begin
   begin try
    select @oldsettleno = max(no) from monthsettle where dateadd(day,-1, getdate()) between begindate and enddate
    select @newsettleno = max(no) from monthsettle where getdate() between begindate and enddate
    if (@oldsettleno) <> (@newsettleno)
    begin
        if exists (select 1 from invdrpt(nolock) where asettleno = @newsettleno
          and adate = convert(char(10),dateadd(day,-1, getdate()), 102)
            )
        begin
            delete from invdrpt
            where asettleno = @newsettleno and adate = convert(char(10),dateadd(day,-1, getdate()), 102)
        end
    end
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
     values (getdate(), 'SETTLEDAY', 'HDSVC', 'SETTLEDAY', 101, '月结清除月末重复库存日报数据成功' )
   end try
   begin catch
     set @errmsg=error_message()
     insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
     values (getdate(), 'SETTLEDAY', 'HDSVC', 'SETTLEDAY', 101, '月结清除月末重复库存日报数据失败'+@errmsg )
   return 5
   end catch
  end

  --
  begin try
    declare @selday datetime
    set @selday = getdate()
    exec APPEND_SETTLEDAYRESULT @selday, 'SETTLEDAY', 0, ''  --合并日结
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEDAY', 'HDSVC', 'SETTLEDAY', 101, '合并日结记录成功')
  end try
  begin catch
    set @errmsg=error_message()
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEDAY', 'HDSVC', 'SETTLEDAY', 101, '合并日结记录成功'+@errmsg)
  end catch


  return 0
end
GO
