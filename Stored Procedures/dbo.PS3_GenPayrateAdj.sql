SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE PROCEDURE [dbo].[PS3_GenPayrateAdj] (
  @piVdrGid Int,       --供应商
  @piDept VarChar(20), --结算组
  @piOper Int,         --操作员
  @piNewRate Int,      --新联销率
  @poErrMsg Varchar(255) OutPut  --错误信息
) As
BEGIN
  declare
    @vRet integer,
    @vSettleNo integer,
    @newRateNum varchar(10),
    @vUserGid Int,
    @opt_SettleDeptLimit int,
    @opt_SettleDeptMethod int,
    @opt_DeptLmt int,
    @vOper VarChar(30)

  EXEC OptReadInt 0, 'SettleDeptLimit', 0, @opt_SettleDeptLimit output
  EXEC OptReadInt 0, 'AutoGetSettleDeptMethod', 0, @opt_SettleDeptMethod output
  EXEC OptReadInt 86, 'PS3_DeptLmt', 0, @opt_DeptLmt output

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  select @vUserGid = USERGID from SYSTEM(nolock)
  Select @vOper = RTrim(NAME) + '[' + RTrim(Code) + ']'
    From Employee Where Gid = @piOper

  select @newRateNum = IsNull(Max(NUM), Replicate('0', 10))
    from PRCADJ(nolock) where CLS = '联销率'
  exec NEXTBN @newRateNum, @newRateNum output

  insert into PRCADJ(CLS, NUM, SETTLENO, FILDATE, FILLER, ADJAMT,
    STAT, NOTE, RECCNT, LAUNCH, EON, SRC)
  Values('联销率', @newRateNum, @vSettleNo, Getdate(), @piOper, 0,
    0, '合约自动生成', 1, Null, 1, @vUserGid)
  if @@ERROR <> 0
  begin
    set @poErrMsg = '生成联销率调整单过程出错'
    RETURN 1
  end

  --生成联销率调整单明细
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
    set @poErrMsg = '生成联销率调整单过程出错'
    RETURN 1
  end

  declare
    @Line int,
    @GdGid int,
    @QPC DECIMAL(24, 4),
    @QPCSTR VARCHAR(20),
    @PAYRATE INT,
    @vAdjAmt DECIMAL(24, 4),
    @Qty DECIMAL(24, 2),
    @vOldRtlPrc DECIMAL(24, 4)
  set @Line = 0
  Set @vAdjAmt = 0
  IF OBJECT_ID('c_RateDtl') IS NOT NULL
    DEALLOCATE c_RateDtl
  declare c_RateDtl cursor for
    select GID, QPCQPC, QPCQPCSTR, PAYRATE
      from TMPGENPAYRATEPRM(nolock)
  open c_RateDtl
  fetch next from c_RateDtl into @GdGid, @QPC, @QPCSTR, @PAYRATE
  while @@Fetch_Status = 0
  begin
    if not exists(select 1 from goods(nolock) where Gid = @GdGid And isltd & 8 = 8)
    begin
      set @Line = @Line + 1

      select @Qty = IsNull(Sum(QTY), 0)
      from INV(nolock)
        where GDGID = @GdGid
      Select @vOldRtlPrc = RtlPrc From Goods(Nolock)
        Where Gid = @GdGid
      insert into PRCADJDTL(CLS, NUM, LINE, SETTLENO, GDGID, OLDPRC, NEWPRC, QTY, QPC, QPCSTR)
      Values('联销率', @newRateNum, @Line, @vSettleNo, @GdGid, @PAYRATE, @piNewRate, @Qty, @QPC, @QPCSTR)
      if @@ERROR <> 0
      begin
        set @poErrMsg = '写入联销率调整单明细出错'
        close c_RateDtl
        deallocate c_RateDtl
        RETURN 1
      end
      Set @vAdjAmt = @vAdjAmt + @Qty * (@piNewRate - @PAYRATE) * @vOldRtlPrc / 100
    end

    fetch next from c_RateDtl into @GdGid, @QPC, @QPCSTR, @PAYRATE
  end
  close c_RateDtl
  deallocate c_RateDtl
  --写生效门店表
  insert into PRCADJLACDTL(CLS, NUM, STOREGID)
  Values('联销率', @newRateNum, @vUserGid)

  --更新汇总的明细记录数
  update PRCADJ set
    RECCNT = @Line, AdjAmt = @vAdjAmt
  where NUM = @newRateNum
  --记录日志
  INSERT INTO PrcAdjLOG (CLS, NUM, MODIFIER, TIME, ACT)
  VALUES ('联销率', @newRateNum, @vOper, GETDATE(), '新增')

  --审核生效
  exec @vRet = PRCADJCHK '联销率', @newRateNum
  if @vRet <> 0 return @vRet

  return(0)
END
GO
