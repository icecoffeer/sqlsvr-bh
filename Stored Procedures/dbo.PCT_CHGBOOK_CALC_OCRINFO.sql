SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CALC_OCRINFO] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piDataSrc varchar(10),                 --数据来源
  @piSrcNum varchar(20),                  --发生单据号
  @poTotal decimal(24, 2) output,         --发生基数
  @poPayDate datetime output,             --费用付款日期
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vRet integer
  declare @vSql varchar(2000)
  declare @vStoreScopeSql varchar(1000)
  declare @vGdScopeSql varchar(1000)
  declare @vDept varchar(20)
  declare @vVdrGid integer
  declare @vMessage varchar(255)

  select @vVdrGid = VENDOR 
  from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion
  exec @vRet = PCT_CHGBOOK_GET_STORESCOPE @piCntrNum, @piCntrVersion, @piCntrLine, @vStoreScopeSql output, @poErrMsg output
  if @vRet <> 0 return(@vRet)
  exec @vRet = PCT_CHGBOOK_GET_GOODSCOPE @piCntrNum, @piCntrVersion, @piCntrLine, @vGdScopeSql output, @poErrMsg output
  if @vRet <> 0 return(@vRet)
  
  select @vDept = rtrim(DEPT) from CTCNTR
  where NUM = @piCntrNum and VERSION = @piCntrVersion;
  exec @vRet = PCT_DATASRC_CALC_OCR @piDataSrc, @vVdrGid, @vDept, @piSrcNum, @vStoreScopeSql, @vGdScopeSql, 
    @poTotal output, @poPayDate output, @poErrMsg output
  set @poTotal = isnull(@poTotal, 0)

  select @vMessage = '发生基数=' + convert(varchar, @poTotal) + ', 付款日期=' + convert(varchar(10), @poPayDate, 102)
  exec PCT_CHGBOOK_LOGDEBUG 'Calc_OcrInfo', @vMessage

  return(@vRet)
end
GO
