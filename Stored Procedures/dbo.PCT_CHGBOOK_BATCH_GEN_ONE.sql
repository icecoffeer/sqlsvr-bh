SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_BATCH_GEN_ONE] (
  @piCntrNum varchar(14),             --合约号
  @piCntrVersion integer,             --合约版本
  @piCntrLine integer,                --合约行号
  @piGenType integer,                 --产生方式
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output,      --出错信息
  @piBegDate datetime = null,         --统计开始日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
  @piEndDate datetime = null          --统计截止日期，如果为null，对于手工指定统计时间段的帐款项目表示没有限制, 对于非手工指定统计时间段表示根据生成周期
  
) as
begin
  declare @vRet integer
  declare @vGenDate datetime
  declare @vLstGenDate datetime
  declare @vGenMethod integer
  declare @vChgCode varchar(20)
  declare @vChgCls varchar(20)
  declare @vDate datetime
  declare @vMessage varchar(255)
  declare @vDefCycle int

  select @vDate = convert(varchar, getdate(), 102)
  select
    @vChgCode = d.CHGCODE,
    @vDefCycle = f.DESIGNCYCLE,
    @vChgCls = f.CHGCLS,
    @vGenMethod = f.GENMETHOD
  from CTCNTRDTL d, CTCHGDEF f
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE

  set @vMessage = '合约=' + @piCntrNum + '(' + convert(varchar, @piCntrVersion) + '), 帐款项目=' + @vChgCode
  exec PCT_CHGBOOK_LOGDEBUG 'Batch_Gen_One', @vMessage

  if @vGenMethod = 0  --'固定周期'
  begin
    set @vLstGenDate = null
    while 1 = 1
    begin
      if @vDefCycle = 0 
      begin
        --获得下次生成日期
        exec @vRet = PCT_CHGBOOK_NEXT_GENDATE @piCntrNum, @piCntrVersion, @piCntrLine, @vGenDate output, @poErrMsg output
        if @vRet <> 0 return(@vRet)
        if @vGenDate is null or @vGenDate > getdate()  --如果没有下次生成日期，则结束并记录
          return(0)
        if @vGenDate = @vLstGenDate
        begin
          set @poErrMsg = '合约 ' + @piCntrNum + ' 无法计算下次生成日期'
          return(1)
        end
        set @vLstGenDate = @vGenDate
      end else begin
        if @piBegDate is null set @vGenDate = '1900.12.31'
        else set @vGenDate = @piBegDate
      end

      --生成费用单
      exec @vRet = PCT_CHGBOOK_GEN_BY_DATE @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @vGenDate, @piOperGid, @poErrMsg output, @piBegDate, @piEndDate
      if @vRet <> 0 return(@vRet)

      if @vDefCycle = 0 
      begin
        --更新下次生成日期
        exec @vRet = PCT_CHGBOOK_UPDATE_NEXT_GENDATE @piCntrNum, @piCntrVersion, @piCntrLine, @poErrMsg output
        if @vRet <> 0 return(@vRet)
      end else return 0
    end
  end else if @vGenMethod = 1 -- '固定日'
  begin
    if @vChgCls = '固定'
    begin
      --生成费用单
      exec @vRet = PCT_CHGBOOK_GEN_BY_DATE @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType, @vDate, @piOperGid, @poErrMsg output
      if @vRet <> 0 return(@vRet)

      --更新下次生成日期
      exec @vRet = PCT_CHGBOOK_UPDATE_NEXT_GENDATE @piCntrNum, @piCntrVersion, @piCntrLine, @poErrMsg output
      if @vRet <> 0 return(@vRet)
    end else
    begin
      set @poErrMsg = '只有固定类帐款项目才能采用固定日生成周期算法'
      return(1)
    end
  end else
  begin
    set @poErrMsg = '不能识别的生成周期算法：' + rtrim(convert(varchar, @vGenMethod))
    return(1)
  end

  return(0)
end
GO
