SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_GEN_BY_DATE] (
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
  declare @vChgCode varchar(20)
  declare @vChgCls varchar(20)

  select @vChgCode = CHGCODE from CTCNTRDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  select @vChgCls = CHGCLS from CTCHGDEF where CODE = @vChgCode

  set @vRet = 0
  if @vChgCls = '固定'
  begin
    exec @vRet = PCT_CHGBOOK_GEN_BY_DATE_FIX @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType,
      @piGenDate, @piOperGid, @poErrMsg output, @piBegDate, @piEndDate 
    if @vRet <> 0 return(@vRet)
  end else if @vChgCls = '提成'
  begin
    exec @vRet = PCT_CHGBOOK_GEN_BY_DATE_RATE @piCntrNum, @piCntrVersion, @piCntrLine, @piGenType,
      @piGenDate, @piOperGid, @poErrMsg output, @piBegDate, @piEndDate 
    if @vRet <> 0 return(@vRet)
  end else
  begin
    set @poErrMsg = '无法识别的帐款项目类型：' + @vChgCls
    return(1)
  end

  return(0)
end
GO
