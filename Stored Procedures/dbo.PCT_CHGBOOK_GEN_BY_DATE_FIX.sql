SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_GEN_BY_DATE_FIX] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piGenType integer,                     --生成方式
  @piGenDate datetime,                    --生成日期
  @piOperGid integer,                     --操作人
  @poErrMsg varchar(255) output,          --出错信息
  @piBegDate datetime = null,             --统计开始日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
  @piEndDate datetime = null              --统计截止日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
) as
begin
  declare @vRet integer
  declare @vFixMethod varchar(20)
  declare @vTotal decimal(24, 2)
  declare @vBeginDate datetime
  declare @vEndDate datetime
  declare @vLstEndDate datetime
  declare @vBaseTotal decimal(24, 2)
  declare @vRateTotal decimal(24, 2)
  declare @vChgBookNum varchar(14)
  declare @vChgCode varchar(20)
  declare @vChgCls varchar(20)
  declare @vItemNo integer
  declare @vDate datetime
  declare @vDataSrc varchar(20)
  declare @vGenDate datetime
  declare @vRealEndDate datetime
  declare @vMessage varchar(255)
  declare @vNote varchar(255)
  declare @vFeeToStore integer
  declare @vStoreScope varchar(255)
  declare @vCmd varchar(255)
  declare @vSqlCond varchar(255)
  declare @vStoreGid integer
  declare @vDefCycle integer
  declare @vCountDays Integer
  declare @vDept VarChar(20) --结算组
  declare @vPayRate Int --联销率
  declare @vVdrGid Int --供应商

  set @vMessage = convert(varchar(10), @piGenDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Gen_By_Date_Fix', @vMessage

  select @vDate = convert(varchar, getdate(), 102)
  select @vChgCode = CHGCODE from CTCNTRDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  select @vRealEndDate = REALENDDATE, @vDept = RTrim(Dept), @vVdrGid = VENDOR
  from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion;

  select @vDefCycle = DESIGNCYCLE from CTCHGDEF(nolock) where CODE = @vChgCode

  --取得固定类算法
  set @vRet = 0
  select
    @vFixMethod = FIXMETHOD,
    @vFeeToStore = FEETOSTORE
  from CTCHGDEFFIX where CODE = @vChgCode
  if @vFixMethod = '周期性'
  begin
    --对于固定类项目，超过实际截止日期则不生成费用
    if @piGenDate > @vRealEndDate return(0)

    if @vDefCycle = 0 --自动生成
    begin
      --取得统计日期
      exec @vRet = PCT_CHGBOOK_NEXT_CYCLE @piCntrNum, @piCntrVersion, @piCntrLine,
        @vBeginDate output, @vEndDate output, @poErrMsg output
      if @vRet <> 0 return(@vRet)
      if @vBeginDate is null set @vBeginDate = @piGenDate
      if @vEndDate is null set @vEndDate = @piGenDate
      --如"按周期生成"的"生成周期单位"为月,则在"统计周期"为日时,需计算本次生成日期到上次生成日期的天数
      --用天数与固定金额之积作为生成的固定费用金额;如"统计周期"为天,则使用固定金额(原有逻辑)
      --如果Genubit='月'并且统计周期(CountUnit)='日',根据生成周期计算统计周期的天数
      Exec @vRet = PCT_CNTRFIX_COUNTDAYS @piCntrNum, @piCntrVersion, @piCntrLine,
        @piGenDate, @vCountDays OutPut, @poErrMsg OutPut
      if @vRet <> 0 return @vRet
    end else begin
      set @vBeginDate = @piBegDate
      set @vEndDate = @piEndDate
      if @vBeginDate is null
        set @vBeginDate = '1900.12.31'
      if @vEndDate is null
        set @vEndDate = '2099.12.31'
    end
    --限制在合约的有效日期范围内
    if @vEndDate > @vRealEndDate
      set @vEndDate = @vRealEndDate

    set @vMessage = '固定类-周期性项目, 统计周期: ' + convert(varchar(10), @vBeginDate, 102) + ' - ' + convert(varchar(10), @vEndDate, 102)
    exec PCT_CHGBOOK_LOGDEBUG 'Gen_By_Date', @vMessage

    --创建费用单
    if @vFeeToStore = 1
    begin
      if object_id('c_FixStore') is not null deallocate c_FixStore
      declare c_FixStore cursor for
        select STORESCOPE, TOTAL, NOTE
        from CTCNTRFIXSTORE where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        order by ITEMNO
      open c_FixStore
      fetch next from c_FixStore into @vStoreScope, @vTotal, @vNote
      while @@fetch_status = 0
      begin
        if object_id('c_Store') is not null deallocate c_Store
        select @vSqlCond = SQLCOND from CTSCOPE(nolock) where CATEGORY = '门店' and CODE = @vStoreScope
        set @vCmd = 'declare c_Store cursor for select GID from STORE where ' + @vSqlCond
        exec(@vCmd)
        open c_Store
        fetch next from c_Store into @vStoreGid
        while @@fetch_status = 0
        begin
          exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK @vStoreGid, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vBeginDate, @vEndDate,
            @vTotal, @vTotal, 100, null, @piGenDate, @vDate, @vNote, @vChgBookNum output, @piOperGid, @poErrMsg output
          if @vRet <> 0 break

          fetch next from c_Store into @vStoreGid
        end
        close c_Store
        deallocate c_Store

        if @vRet <> 0 break
        fetch next from c_FixStore into @vStoreScope, @vTotal, @vNote
      end
      close c_FixStore
      deallocate c_FixStore
      if @vRet <> 0 return(@vRet)
    end else
    begin
      select @vTotal = AMOUNT
      from CTCNTRFIXDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
      --生成周期为月且统计周期为"日"时,用天数作为乘积计算
      If @vCountDays > 1
        Select @vTotal = @vTotal * @vCountDays
      exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK null, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vBeginDate, @vEndDate,
        @vTotal, @vTotal, 100, null, @piGenDate, @vDate, null, @vChgBookNum output, @piOperGid, @poErrMsg output
      if @vRet <> 0 return(@vRet)
    end

    --更新下次统计日期
    exec @vRet = PCT_CHGBOOK_UPDATE_NEXT_CYCLE @piCntrNum, @piCntrVersion, @piCntrLine, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end else if @vFixMethod = '按日期'
  begin
    --对每一个日期
    declare c_FixDate cursor for
      select GENDATE, ITEMNO, TOTAL, NOTE, PAYRATE from CTCNTRFIXDATE
      where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
        and isnull(CHGBOOKNUM, '') = '' and GENDATE <= @piGenDate
    open c_FixDate
    fetch next from c_FixDate into @vGenDate, @vItemNo, @vTotal, @vNote, @vPayRate
    while @@fetch_status = 0
    begin
      if @vGenDate > @vRealEndDate break

      set @vMessage = '固定类-按日期项目, 日期: ' + convert(varchar(10), @vGenDate, 102)
      exec PCT_CHGBOOK_LOGDEBUG 'Gen_By_Date', @vMessage

      --创建费用单
      exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK null, @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @piGenDate, @vGenDate, @vGenDate,
        @vTotal, @vTotal, 100, null, @vGenDate, @vDate, @vNote, @vChgBookNum output, @piOperGid, @poErrMsg output
      if @vRet <> 0
      Begin
        close c_FixDate
        deallocate c_FixDate
        return(@vRet)
      End

      --回写合约
      update CTCNTRFIXDATE set
        CHGBOOKNUM = @vChgBookNum
      where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine and ITEMNO = @vItemNo

      --如果联销率不为空,生成联销率调整单及联销贸易协议
      If @vPayRate > 0
      Begin
	      Exec @vRet = PS3_GenPayrateAdj @vVdrGid, @vDept, @piOperGid, @vPayRate, @poErrMsg OutPut
	      if @vRet <> 0
	      Begin
	        close c_FixDate
	        deallocate c_FixDate
	        return(@vRet)
	      End
        --联销贸易协议
        Exec @vRet = PS3_GenVdrLessee @piCntrNum, @piCntrVersion, @piCntrLine, @vVdrGid, @piOperGid, @vPayRate, @poErrMsg OutPut
	      if @vRet <> 0
	      Begin
	        close c_FixDate
	        deallocate c_FixDate
	        return(@vRet)
	      End
      End

      fetch next from c_FixDate into @vGenDate, @vItemNo, @vTotal, @vNote, @vPayRate
    end
    close c_FixDate
    deallocate c_FixDate
  end else
  begin
    set @poErrMsg = '无法识别的固定类算法: ' + @vFixMethod
    return(1)
  end

  return(0)
end
GO
