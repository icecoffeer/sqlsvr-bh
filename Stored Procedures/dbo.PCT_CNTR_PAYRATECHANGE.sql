SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_PAYRATECHANGE]
as
begin
  declare
    @vCntrNum varchar(14),
    @vCntrVersion integer,
    @vCntrVendor integer,
    @vCntrDept varchar(10),
    @vMsg varchar(255),
    @vRateValue DECIMAL(24,4),
    @vAmtValue DECIMAL(24,4),
    @vWrh int,
    @vRet integer,
    @vSettleNo integer,
    @opt_SettleDeptLimit int,
    @opt_SettleDeptMethod int,
    @usergid int,
    @begindate datetime,
    @enddate datetime,
    @SaleTotal DECIMAL(24,4)

  EXEC OptReadInt 0, 'SettleDeptLimit', 0, @opt_SettleDeptLimit output
  EXEC OptReadInt 0, 'AutoGetSettleDeptMethod', 0, @opt_SettleDeptMethod output

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @usergid = usergid from system(nolock)
  if object_id('c_CntrRate') is not null deallocate c_CntrRate
  declare c_CntrRate cursor for
    select NUM, VERSION, VENDOR, DEPT from CTCNTR(nolock)
      where STAT = 500 and TAG = 1 and convert(datetime,convert(char(10),getdate(),102),102) BETWEEN BEGINDATE AND ENDDATE
  open c_CntrRate
  fetch next from c_CntrRate into @vCntrNum, @vCntrVersion, @vCntrVendor, @vCntrDept
  while @@fetch_status = 0
  begin
    if exists(select 1 from CTCNTRRATECONDPLAN(nolock) where (convert(datetime,convert(char(10),getdate(),102),102) BETWEEN BEGINDATE AND ENDDATE)
      and Num = @vCntrNum and Version = @vCntrVersion and EXESTAT = 0)
    begin
      select @begindate = BEGINDATE, @enddate = ENDDATE from CTCNTRRATECONDPLAN(nolock)
        where (convert(datetime,convert(char(10),getdate(),102),102) BETWEEN BEGINDATE AND ENDDATE) and Num = @vCntrNum
        and Version = @vCntrVersion and EXESTAT = 0

      if (@opt_SettleDeptLimit = 1) and (@opt_SettleDeptMethod = 3)
      begin
        select @vWrh = WRHGID from SETTLEDEPTWRH(nolock) where CODE = @vCntrDept
        select @SaleTotal = isnull(sum(DT2), 0) from VDRDRPT(nolock) where ASTORE = @usergid and ASETTLENO = @vSettleNo
          and (ADATE BETWEEN  @begindate and (getdate() - 1)) and BVDRGID = @vCntrVendor and BWRH = @vWrh
      end else if (@opt_SettleDeptLimit = 1) and (@opt_SettleDeptMethod = 2)
      begin
        select @SaleTotal = isnull(sum(DT2), 0) from VDRDRPT(nolock) where ASTORE = @usergid and ASETTLENO = @vSettleNo
          and (ADATE BETWEEN  @begindate and (getdate() - 1)) and BVDRGID = @vCntrVendor
      end else  --部分与结算组关联时需要增加商品部门条件
      begin
        select @SaleTotal = isnull(sum(a.DT2), 0)
        from VDRDRPT a(nolock),goodsh b(nolock),settledeptdept c(nolock)
        where a.ASTORE = @usergid and a.ASETTLENO = @vSettleNo
         and (a.ADATE BETWEEN  @begindate and (getdate() - 1))
         and a.BVDRGID = @vCntrVendor and a.bgdgid = b.gid
         and b.f1 = c.deptcode and c.code = @vCntrDept
      end

      if @@ERROR <> 0
      begin
        set @vMsg = '生成联销率促销单过程出错'
        RETURN 1
      end

      select @vAmtValue = isnull(max(EXPAMT), 0) from CTCNTRRATECONDPLAN(nolock)
        where Num = @vCntrNum and Version = @vCntrVersion and (convert(datetime, convert(char(10), getdate(), 102), 102)
          BETWEEN BEGINDATE AND ENDDATE) and EXESTAT = 0 and EXPAMT <= @SaleTotal
      if @vAmtValue <> 0
        select @vRateValue = isnull(ADDRATE, 0) from CTCNTRRATECONDPLAN(nolock)
          where Num = @vCntrNum and Version = @vCntrVersion and (convert(datetime, convert(char(10), getdate(), 102), 102)
          BETWEEN BEGINDATE AND ENDDATE) and EXESTAT = 0 and EXPAMT = @vAmtValue
      else
        set @vRateValue = 0

      if @SaleTotal <> 0 and @vRateValue <> 0
      begin
        begin transaction
        execute @vRet = PCT_CNTR_FILLPAYRATE @vCntrNum, @vCntrVersion, @vCntrVendor, @vCntrDept, @begindate, @enddate, @vRateValue,
          @vAmtValue, @opt_SettleDeptLimit, @opt_SettleDeptMethod, @vMsg output
        if @vRet <> 0
        begin
          rollback transaction
          set @vMsg = substring('根据合约 ' + @vCntrNum + '(' + rtrim(convert(varchar, @vCntrVersion)) + ') 联销率变更条件调整商品联销率失败。' 
            + char(10) + @vMsg, 1, 255)
          insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
          values(getdate(), @vSettleNo, '日结程序', '日结程序', 'DB SERVER', '日结程序', 304, @vMsg);
        end else
        begin
          commit transaction
          set @vMsg = '根据合约 ' + @vCntrNum + '(' + rtrim(convert(varchar, @vCntrVersion)) + ') 联销率变更条件调整商品联销率成功。' 
          insert into LOG(TIME, MONTHSETTLENO, EMPLOYEECODE, EMPLOYEENAME, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
          values(getdate(), @vSettleNo, '日结程序', '日结程序', 'DB SERVER', '日结程序', 301, @vMsg);
        end
        waitfor delay '0:0:0.010'
      end
    end

    fetch next from c_CntrRate into @vCntrNum, @vCntrVersion, @vCntrVendor, @vCntrDept
  end
  close c_CntrRate
  deallocate c_CntrRate
end
GO
