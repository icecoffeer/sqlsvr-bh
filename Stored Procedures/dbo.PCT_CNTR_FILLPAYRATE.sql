SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CNTR_FILLPAYRATE] (
  @piCntrNum varchar(14),           --合约号,更新联销率条件用
  @piCntrVersion integer,           --合约版本号,更新联销率条件用
  @piVdrGid integer,                --供应商GID
  @piDept varchar(10),              --结算组
  @piBeginDate datetime,            --联销率促销开始日期
  @piEndDate datetime,              --联销率促销结束日期
  @piAddRate decimal(24, 4),        --递增联销率
  @piAmtValue decimal(24, 4),       --销售指标额
  @opt_Settledeptlimit int,         --费用结算单限制选项
  @opt_SettledeptMethod int,        --费用结算组关联取值选项
  @poErrMsg varchar(255) output     --出错信息
) as
begin
  declare
    @vRet integer,
    @vOper varchar(50),
    @vSysDate datetime,
    @vSettleNo integer,
    @newRateNum varchar(14)

  DECLARE
    @FILLERCODE VARCHAR(20),
    @FILLER INT,
    @FILLERNAME VARCHAR(50)
  SET @FILLERCODE = RTRIM(SUBSTRING(SUSER_SNAME(), CHARINDEX('_', SUSER_SNAME()) + 1, 20))
  SELECT @FILLER = GID, @FILLERNAME = NAME
    FROM EMPLOYEE(NOLOCK)
  WHERE CODE LIKE @FILLERCODE
  if @FILLERNAME is null
  begin
    set @FILLERCODE = '-'
    set @FILLERNAME = '未知'
  end
  set @vOper = convert(varchar(30),'['+rtrim(isnull(@FILLERCODE,''))+']' +
    rtrim(isnull(@FILLERNAME,'')))

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  set @vSysDate = convert(varchar, getdate(), 102)

  exec @vRet = GENNEXTBILLNUMEX '', 'PAYRATEPRM', @newRateNum output
  INSERT INTO PAYRATEPRM(NUM, SETTLENO, FILDATE, FILLER, CHECKER, CHKDATE, STAT, NOTE,
    RECCNT, LAUNCH, EON, SRC, SNDTIME, PRNTIME, LASTMODIFIER, LSTUPDTIME)
  VALUES(@newRateNum, @vSettleNo, getdate(), @vOper, null, null, 0, '日结自动生成',
    1, null, 1, 1, null, null, @vOper, getdate())
  if @@ERROR <> 0
  begin
    set @poErrMsg = '生成联销率促销单过程出错'
    RETURN 1
  end

  --生成联销率促销单明细
  declare
    @vDept char(14),
    @vWrh int,
    @strSql varchar(1024)

  delete from TMPGENPAYRATEPRM
  set @strSql = ' insert into TMPGENPAYRATEPRM(GID, QPCQPC, QPCQPCSTR, PAYRATE) '
    + ' select GID, QPCQPC, QPCQPCSTR, PAYRATE from V_QPCGOODS(nolock)'
    + ' where SALE = 3 and QPCQPCSTR = ''1*1'' and BILLTO = ' + str(@piVdrGid)
  if @opt_Settledeptlimit = 1
  begin
    if @opt_SettledeptMethod = 3
    begin
      select @vWrh = WRHGID from SETTLEDEPTWRH(nolock) where CODE = @piDept
      set @strSql = @strSql + ' and WRH = ' + str(@vWrh)
    end
    else if @opt_SettledeptMethod = 2
    begin
      set @strSql = @strSql
    end
    else
    begin
      select @vDept = DEPTCODE from SETTLEDEPTDEPT(nolock) where CODE = @piDept
      set @strSql = @strSql + ' and F1 = ''' + rtrim(@vDept) + ''''
    end
  end
  exec (@strSql)
  if @@ERROR <> 0
  begin
    set @poErrMsg = '生成联销率促销单过程出错'
    RETURN 1
  end

  declare
    @Line int,
    @GdGid int,
    @QPC DECIMAL(24,4),
    @QPCSTR VARCHAR(20),
    @PAYRATE INT
  set @Line = 0
  declare c_RateDtl cursor for
    select GID, QPCQPC, QPCQPCSTR, PAYRATE
      from TMPGENPAYRATEPRM(nolock)
  open c_RateDtl
  fetch next from c_RateDtl into @GdGid, @QPC, @QPCSTR, @PAYRATE
  while @@fetch_status = 0
  begin
    if not exists(select 1 from goods(nolock) where Gid = @GdGid And isltd & 8 = 8)
    begin
      set @Line = @Line + 1

      insert into PAYRATEPRMDTL(NUM, LINE, GDGID, SETTLENO, QPC, QPCSTR, PAYRATE, ASTART, AFINISH)
      values(@newRateNum, @Line, @GdGid, @vSettleNo, @QPC, @QPCSTR, @PAYRATE + @piAddRate, @piBeginDate, @piEndDate)
      if @@ERROR <> 0
      begin
        set @poErrMsg = '写入联销率促销单明细出错'
        close c_RateDtl
        deallocate c_RateDtl
        RETURN 1
      end
    end

    fetch next from c_RateDtl into @GdGid, @QPC, @QPCSTR, @PAYRATE
  end
  close c_RateDtl
  deallocate c_RateDtl
  --更新汇总的明细记录数
  update PAYRATEPRM set RECCNT = @Line where NUM = @newRateNum
  --记录日志
  INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
   VALUES(@newRateNum, @vOper, getdate(), '新增')

  --审核生效
  exec @vRet = PAYRATEPRMCHK @newRateNum, @vOper, @poErrMsg output
  if @vRet <> 0 return @vRet
  --更新联销率变更条件中的执行状态
  update CTCNTRRATECONDPLAN set EXEBILLINFO = @newRateNum, EXESTAT = 1, NOTE = '''' + rtrim(convert(varchar, GETDATE(), 102))
    + '''' + '日结时执行成功.'
    where NUM = @piCntrNum and VERSION = @piCntrVersion and ADDRATE = @piAddRate
  --当存在跳跃式执行变更联销率时(如跳过10万直接达到了20万),更新对应变更条件的信息
  if exists(select 1 from CTCNTRRATECONDPLAN(nolock) where NUM = @piCntrNum and VERSION = @piCntrVersion and EXPAMT < @piAmtValue
    and EXESTAT = 0)
    update CTCNTRRATECONDPLAN set EXESTAT = 1, note = '销售计划超额完成直接执行一下计划'
       where Num = @piCntrNum and Version = @piCntrVersion and EXPAMT < @piAmtValue and EXESTAT = 0

  return(0)
end
GO
