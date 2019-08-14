SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[SETTLEMONTH](
  @empcode char(10),
  @invprc2inprc smallint
) as
begin
--
--  return 0 if success
--         1 if has been done today
--         2 if time is earlier than before
--         3 if other errors
--  期末值: 库存月报
--  GOODS.OLDINVPRC := GOODS.INVPRC
--  使用上月库存价核算的话,调价INPRC, 调成INVPRC
--  增加: 月结转
--  期初值: 进货月报,库存调整月报,出货月报,供应商帐款月报,客户帐款月报
--
  declare
    @new_settleno int,
    @old_settleno int,
    @nano int,
    @begindate datetime,
    @begintime datetime,
    @endtime datetime,
    @empname char(20),
    @return_status int,
    @store int,
    @old_bn char(10),
    @bn char(10),
    @adjamt money,
    @reccnt int,
    @gdgid int,
    @inprc money,
    @qty money,
    @invprc money,
    @wrh int,		/* 2000.12.6 */
    @subwrh int,
    @cost_r money,
    @cost money,
    @cmd char(100)

  -- check validity
  select @old_settleno = MAX(NO) from MONTHSETTLE
  select @nano = NANO from MONTHSETTLE where no = @old_settleno/*2003.04.15*/
  select
    @begindate = convert(datetime, convert(char, BEGINDATE, 102)),
    @begintime = BEGINDATE,
    @endtime = ENDDATE
    from MONTHSETTLE
    where NO = @old_settleno
  if @begindate = convert(datetime, convert(char, getdate(), 102))
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '',
    'SETTLEMON', 101, '今天已经做过月度结转，一天中不能做两次月度结转。' )
    waitfor delay '0:0:1'
    raiserror('今天已经做过月度结转，一天中不能做两次月度结转。', 16, 1)
    return (1)
  end
  if (@begintime > getdate()) or (@endtime < getdate())
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '',
    'SETTLEMON', 101, '服务器日期有问题，上次结转的日期在现在日期之后.' )
    waitfor delay '0:0:1'
    raiserror('服务器日期有问题，上次结转的日期在现在日期之后.', 16, 1)
    return(2)
  end

  select
    @store = USERGID
    from SYSTEM

  select @cmd = 'dump transaction ' + rtrim(db_name()) + ' with no_log'
  exec (@cmd)

  -- 2990 计算可用商品范围临时表，去除删除一个月以上的商品
  if object_id('tempdb..#valgoods') is not null  drop table #valgoods
  create table #valgoods(gid int)
  
  insert into #valgoods(gid) select gid from goods(nolock) 
  insert into #valgoods(gid) select gid from goodsh(nolock) 
    where lstupdtime>dateadd(day, -32, getdate())
      and gid not in (select gid from goods(nolock))
      
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
  TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '',
  'SETTLEMON', 101, '上月库存月报期末值' )
  waitfor delay '0:0:1'
  -- 库存月报期末值
  update INVMRPT set
    FQ = V_INV.QTY,
    FT = V_INV.TOTAL,
    FINPRC = GOODS.INPRC,
    FRTLPRC = GOODS.RTLPRC,
    FDXPRC = GOODS.DXPRC,
    FPAYRATE = GOODS.PAYRATE,
    FINVPRC = isnull(GDWRH.INVPRC, GOODS.INVPRC),
    FLSTINPRC = GOODS.LSTINPRC,
    FINVCOST = isnull(GDWRH.INVCOST, 0)  --2002-06-13
    from V_INV, GOODS, GDWRH, #VALGOODS  --2002.08.18 --2004.11.09 2990
    where INVMRPT.ASETTLENO = @old_settleno
    and INVMRPT.BWRH = V_INV.WRH
    and INVMRPT.BGDGID = V_INV.GDGID
    and INVMRPT.BGDGID = GOODS.GID
    and INVMRPT.ASTORE = @store
    and V_INV.STORE = @store
    and INVMRPT.BWRH *= GDWRH.WRH
    and INVMRPT.BGDGID *= GDWRH.GDGID
    and GOODS.GID = #VALGOODS.GID
  --added by wang xin 2003.02.17
  if (select BATCHFLAG from SYSTEM)= 2
  begin
      update INVMRPT set 
      FINVCOST = isnull(COST, 0) 
      from V_SUBINV
      where INVMRPT.ASETTLENO = @old_settleno
      and INVMRPT.BWRH *= V_SUBINV.WRH 
      and INVMRPT.BGDGID *= V_SUBINV.GDGID
      and INVMRPT.ASTORE = @store         
  end
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '',
    'SETTLEMON', 101, '设置库存月报期末值失败' )
    waitfor delay '0:0:1'
    raiserror('设置库存月报期末值失败', 16, 1)
    RETURN(3)
  end
  
  /* 00-3-30 货位库存月报期末值 */
  if (select batchflag from system) = 1 begin
    update SWINVMRPT set
      FQ = SUBWRHINV.QTY,
      FT = SUBWRHINV.TOTAL,
      FI = SUBWRHINV.COST   /* 2000-09-21 */
      from SUBWRHINV
      where SWINVMRPT.ASETTLENO = @old_settleno
      and SWINVMRPT.ASTORE = @store
      and SWINVMRPT.BGDGID = SUBWRHINV.GDGID
      and SWINVMRPT.BWRH = SUBWRHINV.WRH
      and SWINVMRPT.BSUBWRH = SUBWRHINV.SUBWRH
    if @@ERROR <> 0 begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '',
      'SETTLEMON', 101, '设置货位库存月报期末值失败' )
      waitfor delay '0:0:1'
      raiserror('设置货位库存月报期末值失败', 16, 1)
      RETURN(3)
    end
  end

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '更新上月库存价' )
  waitfor delay '0:0:1'
  update GOODS set OLDINVPRC = INVPRC
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '',
    'SETTLEMON', 101, '更新上月库存价失败' )
    waitfor delay '0:0:1'
    raiserror('更新上月库存价失败', 16, 1)
    RETURN 3
  end


  if @invprc2inprc = 1 begin
    -- GOODS.INVPRC := GOODS.OLDINVPRC
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '',
    'SETTLEMON', 101, '做一张核算价调价单将当前库存价赋给核算价' )
    waitfor delay '0:0:1'
    -- 做一张核算价调价单将当前库存家赋给核算价
    select @return_status = 0
    select @old_bn = max(NUM) from PRCADJ where CLS = '核算价'
    if @old_bn is null or @old_bn = '' select @bn = '0000000001'
    else execute NEXTBN @old_bn, @bn output
    declare c_gd cursor for select GID, INPRC, INVPRC from GOODS where INPRC <> INVPRC
    /* 2000-07-04 */ and SALE = 1
    open c_gd
    select @adjamt = 0, @reccnt = 0
    fetch next from c_gd into @gdgid, @inprc, @invprc
    while @@fetch_status = 0 begin
      -- 生成调价单明细
      select @qty = isnull((select sum(QTY) from V_INV where GDGID = @gdgid), 0)
      select
        @adjamt = @adjamt + @qty * (@invprc - @inprc),
        @reccnt = @reccnt + 1
      insert into PRCADJDTL (CLS, NUM, LINE, SETTLENO, GDGID, OLDPRC, NEWPRC, QTY)
      values ('核算价', @bn, @reccnt, @old_settleno, @gdgid, @inprc, @invprc, @qty)
      if @@error <> 0
      begin
        select @return_status = 3
        break
      end
      fetch next from c_gd into @gdgid, @inprc, @invprc
    end
    close c_gd
    deallocate c_gd
    if @return_status <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '生成调价单明细失败' )
      waitfor delay '0:0:1'
      raiserror('生成调价单明细失败', 16, 1)
      return 3
    end
    if @reccnt > 0 begin
      insert into PRCADJ (CLS, NUM, SETTLENO, FILDATE, FILLER, CHECKER, ADJAMT,
        STAT, NOTE, RECCNT, LAUNCH, EON, SRC, SRCNUM, SNDTIME)
      values ('核算价', @bn, @old_settleno, getdate(), 1, 1, @adjamt,
        0, '月结转', @reccnt, NULL, 1, 1, NULL, NULL)
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
      TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '',
      'SETTLEMON', 101, '审核调价单' )
      waitfor delay '0:0:1'
      execute @return_status = PRCADJCHK '核算价', @bn
      if @return_status <> 0
      begin
        insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
        values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '审核调价单失败' )
        waitfor delay '0:0:1'
        raiserror('审核调价单失败', 16, 1)
        return (3)
      end
    end
  end


  -- 修改MONTHSETTLE：本期结束时间，结转人
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '','SETTLEMON', 101, '修改MONTHSETTLE：本期结束时间，结转人' )
  waitfor delay '0:0:1'
  select @empname = NAME from EMPLOYEE where CODE = @empcode
  update MONTHSETTLE set
    ENDDATE = GETDATE(),
    EMPLOYEECODE = @empcode,
    EMPLOYEENAME = @empname
    where NO = @old_settleno
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '修改月结转期表失败' )
    waitfor delay '0:0:1'
    raiserror('修改月结转期表失败', 16, 1)
    RETURN 3
  end

  -- 增加MONTHSETTLE：起始时间
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '增加MONTHSETTLE：起始时间' )
  waitfor delay '0:0:1'
  select @new_settleno = @old_settleno + 1
  exec NextNaNo @nano, @nano output/*2003.04.15*/
  insert into MONTHSETTLE (NO, BEGINDATE, NANO) 
  values (@new_settleno, GETDATE(), @nano)
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '增加月结转期表失败' )
    waitfor delay '0:0:1'
    raiserror('增加月结转期表失败', 16, 1)
    RETURN 3
  end

  -- 库存月报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '','SETTLEMON', 101, '库存月报' )
  waitfor delay '0:0:1'
  insert into INVMRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
    CQ, CT, FQ, FT,
    FINPRC, FRTLPRC, FDXPRC, FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST)
  select @new_settleno, V_INV.GDGID, V_INV.WRH, @store,
    V_INV.QTY, V_INV.TOTAL,V_INV.QTY, V_INV.TOTAL,
    GOODS.INPRC, GOODS.RTLPRC, GOODS.DXPRC, ISNULL(GOODS.PAYRATE,0),
    isnull(GDWRH.INVPRC, GOODS.INVPRC),  isnull(GOODS.LSTINPRC,0),
    isnull(GDWRH.INVCOST, 0)
  from V_INV, GOODS, GDWRH, #VALGOODS --2002.08.18
  where V_INV.GDGID = GOODS.GID and V_INV.STORE = @store
    and V_INV.WRH *= GDWRH.WRH and V_INV.GDGID *= GDWRH.GDGID
    and GOODS.GID = #VALGOODS.GID
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增库存月报失败' )
    waitfor delay '0:0:1'
    raiserror('新增库存月报失败', 16, 1)
    RETURN 3
  end

  /* 00-3-30 货位库存月报 */
  if (select batchflag from system) = 1 begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '','SETTLEMON', 101, '货位库存月报' )
    waitfor delay '0:0:1'
    insert into SWINVMRPT (ASETTLENO, BGDGID, BWRH, ASTORE, BSUBWRH,
      CQ, CT, CI, FQ, FT, FI)
    select @new_settleno, GDGID, WRH, @store, SUBWRH, QTY, TOTAL, isnull(COST, 0), 0, 0, 0
    from SUBWRHINV, #VALGOODS
    where SUBWRHINV.GDGID = #VALGOODS.GID
    
    /* 2000.12.6 */
    declare c cursor for
      select m.TOWRH, d.TOSUBWRH, d.GDGID, 
        isnull(sum(d.QTY), 0) QTY, isnull(sum(d.QTY * d.RTLPRC), 0) COST_R, 
        isnull(sum(d.QTY * d.INPRC), 0) COST
      from XF m inner join XFDTL d on m.NUM = d.NUM
      where m.STAT in (1, 8) and d.QTY <> 0
      group by m.TOWRH, d.TOSUBWRH, d.GDGID
      for read only
    open c
    fetch next from c into @wrh, @subwrh, @gdgid, @qty, @cost_r, @cost
    while @@fetch_status = 0
    begin
      select @cost = @cost + isnull(sum(ADJINCOST), 0)	-- 2001.12.3
      	from INPRCADJDTL
      	where STORE = @store and BILL = 'XF'
      	  and BILLCLS = '调入' and WRH = @wrh
      	  and SUBWRH = @subwrh and LACTIME is not null
      if exists(select 1 from SWINVMRPT where 
        ASETTLENO = @new_settleno and BGDGID = @gdgid and BWRH = @wrh
        and ASTORE = @store and BSUBWRH = @subwrh)
        update SWINVMRPT set CQ = CQ + @qty, CT = CT + @cost_r, CI = CI + @cost
          where ASETTLENO = @new_settleno and BGDGID = @gdgid and BWRH = @wrh
          and ASTORE = @store and BSUBWRH = @subwrh
      else
        insert into SWINVMRPT (ASETTLENO, BGDGID, BWRH, ASTORE, BSUBWRH,
          CQ, CT, CI, FQ, FT, FI) 
          values (@new_settleno, @gdgid, @wrh, @store, @subwrh,
          @qty, @cost_r, @cost, 0, 0, 0)
      fetch next from c into @wrh, @subwrh, @gdgid, @qty, @cost_r, @cost
    end
    close c
    deallocate c
    
    if @@ERROR <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增货位库存月报失败' )
      waitfor delay '0:0:1'
      raiserror('新增货位库存月报失败', 16, 1)
      RETURN 3
    end
  end

  -- 进货月报
  if not exists (select * from yearsettle where no = @new_settleno)
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '进货月报' )
    waitfor delay '0:0:1'
    insert into INMRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE,
      CQ1, CQ2, CQ3, CQ4,
      CT1, CT2, CT3, CT4,
      CI1, CI2, CI3, CI4,
      CR1, CR2, CR3, CR4)
    select @new_settleno, BGDGID, BVDRGID, BWRH, @store,
      CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4,
      CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4,
      CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4,
      CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4
    from INMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and INMRPT.BGDGID = #VALGOODS.GID
    if @@ERROR <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '','SETTLEMON', 101, '新增进货月报失败' )
      waitfor delay '0:0:1'
      raiserror('新增进货月报失败', 16, 1)
      RETURN 3
    end
  end

  -- 库存调整月报
  if not exists (select * from yearsettle where no = @new_settleno)
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '库存调整月报' )
    waitfor delay '0:0:1'
    insert into INVCHGMRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
      CQ1, CQ2, CQ4, CQ5,
      CI1, CI2, CI3, CI4, CI5,
      CR1, CR2, CR3, CR4, CR5)
    select @new_settleno, BGDGID, BWRH, @store,
      CQ1 + DQ1, CQ2 + DQ2, CQ4 + DQ4, CQ5 + DQ5,
      CI1 + DI1, CI2 + DI2, CI3 + DI3, CI4 + DI4, CI5 + DI5,
      CR1 + DR1, CR2 + DR2, CR3 + DR3, CR4 + DR4, CR5 + DR5
    from INVCHGMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and INVCHGMRPT.BGDGID = #VALGOODS.GID
    if @@ERROR <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增库存调整月报失败' )
      waitfor delay '0:0:1'
      raiserror('新增库存调整月报失败', 16, 1)
      RETURN 3
    end
  end

  -- 出货月报
  /*if not exists (select * from yearsettle where no = @new_settleno)
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,
    TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '出货月报' )
    waitfor delay '0:0:1'
    insert into OUTMRPT ( ASETTLENO, BGDGID, BWRH, BCSTGID, ASTORE,
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
    from OUTMRPT
    where ASETTLENO = @old_settleno
    and ASTORE = @store
    if @@ERROR <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增出货月报失败' )
      waitfor delay '0:0:1'
      raiserror('新增出货月报失败', 16, 1)
      RETURN 3
    end
  end*/

  -- 供应商月报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '供应商月报' )
  waitfor delay '0:0:1'
  if exists (select * from yearsettle where no = @new_settleno)
    insert into VDRMRPT ( ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE, CT8)
    select @new_settleno, BVDRGID, BWRH, BGDGID, @store,
      CT8 + DT3 - DT4 + DT6
    from VDRMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and VDRMRPT.BGDGID = #VALGOODS.GID
  else
    insert into VDRMRPT ( ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE,
     CQ1, CQ2, CQ3, CQ4, CQ5, CQ6,
     CT1, CT2, CT3, CT4, CT5, CT6, CT7, CT8, ci2)
    select @new_settleno, BVDRGID, BWRH, BGDGID, @store,
      CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3, CQ4 + DQ4, CQ5 + DQ5, CQ6 + DQ6,
      CT1 + DT1, CT2 + DT2, CT3 + DT3, CT4 + DT4, CT5 + DT5, CT6 + DT6,
      CT7 + DT7, CT8 + DT3 - DT4 + DT6, ci2 + di2
    from VDRMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and VDRMRPT.BGDGID = #VALGOODS.GID
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增供应商月报失败' )
    waitfor delay '0:0:1'
    raiserror('新增供应商月报失败', 16, 1)
    RETURN 3
  end

  -- 客户月报
  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '客户月报' )
  waitfor delay '0:0:1'
  if exists (select * from yearsettle where no = @new_settleno)
    insert into CSTMRPT ( ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE,CT4)
    select @new_settleno, BCSTGID, BWRH, BGDGID, @store,
      CT4 + DT3 - DT1
    from CSTMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and CSTMRPT.BGDGID = #VALGOODS.GID
  else
    insert into CSTMRPT ( ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE,
     CQ1, CQ2, CQ3,
     CT1, CT2, CT3, CT4 )
    select @new_settleno, BCSTGID, BWRH, BGDGID, @store,
      CQ1 + DQ1, CQ2 + DQ2, CQ3 + DQ3,
      CT1 + DT1, CT2 + DT2, CT3 + DT3,
      CT4 + DT3 - DT1
    from CSTMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and CSTMRPT.BGDGID = #VALGOODS.GID
  if @@ERROR <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '新增客户月报失败' )
    waitfor delay '0:0:1'
    raiserror('新增客户月报失败', 16, 1)
    RETURN 3
  end

  -- 加工月报
  if not exists (select * from yearsettle where no = @new_settleno)
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME,TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '加工月报' )
    waitfor delay '0:0:1'
    insert into PROCMRPT (ASETTLENO, BGDGID, BWRH, ASTORE,
      CQ1, CT1, CI1, CR1, CD1)
    select @new_settleno, BGDGID, BWRH, @store,
      CQ1 + DQ1, CT1 + DT1, CI1 + DI1, CR1 + DR1, CD1 + DD1
    from PROCMRPT, #VALGOODS
    where ASETTLENO = @old_settleno
    and ASTORE = @store and PROCMRPT.BGDGID = #VALGOODS.GID
    if @@ERROR <> 0
    begin
      insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
      values (getdate(), 'SETTLEMON', '','SETTLEMON', 101, '新增加工月报失败' )
      waitfor delay '0:0:1'
      raiserror('新增加工月报失败', 16, 1)
      RETURN 3
    end
  end

  select @cmd = 'dump transaction ' + rtrim(db_name()) + ' with no_log'
  exec (@cmd)

  insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
  values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '日结转' )
  waitfor delay '0:0:1'
  declare @old_date datetime, @new_date datetime
  select @old_date = convert(datetime, convert(char, getdate(), 102))
  select @new_date = convert(datetime, convert(char, getdate(), 102))
  execute @return_status =
    SETTLEDAY @old_settleno, @old_date, @new_settleno, @new_date
  if @return_status <> 0
  begin
    insert into LOG(TIME, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
    values (getdate(), 'SETTLEMON', '', 'SETTLEMON', 101, '日结转失败' )
    waitfor delay '0:0:1'
    raiserror('日结转失败', 16, 1)
    return(3)
  end

  return 0
end
GO
