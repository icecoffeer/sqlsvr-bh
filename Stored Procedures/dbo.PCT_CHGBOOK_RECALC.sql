SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_RECALC] (
  @piNum varchar(14),                 --费用单单号
  @poBaseTotal decimal(24, 2) output, --统计基数
  @poTotal decimal(24, 2) output,     --费用金额
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vRet integer
  declare @vBeginDate datetime
  declare @vEndDate datetime
  declare @vCntrNum varchar(14)
  declare @vCntrVersion integer
  declare @vCntrLine integer
  declare @vChgCode varchar(20)
  declare @vStat integer
  declare @vTotal decimal(24, 2)
  declare @vBaseTotal decimal(24, 2)
  declare @vDataSrc varchar(20)
  declare @vChgCls varchar(20)
  declare @vCalcRate decimal(24, 2)

  --合法性检查
  select
    @vStat = STAT,
    @vBeginDate = CALCBEGIN,
    @vEndDate = CALCEND,
    @vCntrNum = CNTRNUM,
    @vChgCode = CHGCODE
  from CHGBOOK where NUM = @piNum
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到费用单 ' + @piNum
    return(1)
  end
  if @vStat <> 0
  begin
    set @poErrMsg = '费用单 ' + @piNum + ' 不是未审核单据，不能重算'
    return(1)
  end

  --预读数据
  select
    @vCntrVersion = d.VERSION,
    @vCntrLine = d.LINE
  from CTCNTR m, CTCNTRDTL d
  where m.NUM = d.NUM and m.VERSION = d.VERSION
    and m.TAG = 1 and m.NUM = @vCntrNum and d.CHGCODE = @vChgCode
  if @@rowcount = 0
  begin
    set @poErrMsg = '找不到合约 ' + @vCntrNum + ' 的帐款项目 ' + @vChgCode
    return(1)
  end

  select @vChgCls = CHGCLS from CTCHGDEF where CODE = @vChgCode
  if @vChgCls <> '提成'
  begin
    set @poErrMsg = @vChgCode + ' 不是提成类帐款项目，无法重算'
    return(1)
  end

  --计算统计基数
  set @vBaseTotal = 0
  if object_id('c_DataSrc') is not null deallocate c_DataSrc
  
  if exists (select 1 from CTCNTRDTLDATASRC(nolock) where num = @vCntrNum and VERSION = @vCntrVersion and LINE = @vCntrLine) 
    declare c_DataSrc cursor for
      select DSCODE from CTCNTRDTLDATASRC(nolock) where num = @vCntrNum and VERSION = @vCntrVersion and LINE = @vCntrLine
  else 
    declare c_DataSrc cursor for
      select DSCODE from CTCHGDATASRC(nolock) where CODE = @vChgCode
      
  open c_DataSrc
  fetch next from c_DataSrc into @vDataSrc
  while @@fetch_status = 0
  begin
    exec @vRet = PCT_CHGBOOK_CALC_BASETOTAL @vCntrNum, @vCntrVersion, @vCntrLine, @vDataSrc,
      @vBeginDate, @vEndDate, @vTotal output, @poErrMsg output
    if @vRet <> 0 break
    set @vBaseTotal = @vBaseTotal + @vTotal

    fetch next from c_DataSrc into @vDataSrc
  end
  close c_DataSrc
  deallocate c_DataSrc
  if @vRet <> 0 return(@vRet)

  --计算提成金额
  set @poBaseTotal = @vBaseTotal
  exec @vRet = PCT_CHGBOOK_CALC_RATETOTAL @vCntrNum, @vCntrVersion, @vCntrLine, @vBeginDate, @vEndDate, @vBaseTotal,
    @poTotal output, @vCalcRate output, @poErrMsg output
  if @vRet <> 0 return(@vRet)

  return(0)
end
GO
