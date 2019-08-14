SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CALC_RATETOTAL] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piBeginDate datetime,                  --统计开始日期
  @piEndDate datetime,                    --统计结束日期
  @piBaseTotal decimal(24, 2),            --统计基数
  @poTotal decimal(24, 2) output,         --提成额
  @poCalcRate decimal(24, 2) output,      --提成率
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vItemNo integer
  declare @vRateMode varchar(20)
  declare @vCalcMode varchar(20)
  declare @vGuardTotal decimal(24, 2)
  declare @vRoundType varchar(20)
  declare @vFeePrec decimal(24, 2)
  declare @vRate decimal(24, 2)
  declare @vLowAmt decimal(24, 2)
  declare @vQBase decimal(24, 2)
  declare @vChgCode varchar(10)
  declare @vMessage varchar(255)
  declare @vSign int
  declare @vRet int

  if @piBaseTotal < 0
  begin
    set @piBaseTotal = -@piBaseTotal
    set @vSign = -1
  end else
    set @vSign = 1

  select
    @vRateMode = RATEMODE, 
    @vCalcMode = CALCMODE, 
    @vRoundType = ROUNDTYPE, 
    @vFeePrec = FEEPREC
  from CTCNTRRATEDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

  select @vItemNo = min(ITEMNO)
  from CTCNTRRATEDISC where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine and HIGHAMT > @piBaseTotal
  if @vItemNo is null
  begin
    select @vItemNo = max(ITEMNO)
    from CTCNTRRATEDISC where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
    if @vItemNo is null
    begin
      select @vChgCode = CHGCODE 
      from CTCNTRDTL where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
      set @poErrMsg = '合约 ' + @piCntrNum + ' 的帐款项目 ' + @vChgCode + ' 没有定义提成率'
      return(1)
    end
  end
  select 
    @vRate = RATE, 
    @vLowAmt = LOWAMT, 
    @vQBase = QBASE
  from CTCNTRRATEDISC where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine and ITEMNO = @vItemNo
  if @piBaseTotal < @vLowAmt
    set @vRate = 0
  if @vRateMode = '数值分段'
    set @poTotal = @piBaseTotal * @vRate / 100
  else if @vRateMode = '数值分段累计'
    set @poTotal = (@piBaseTotal - @vLowAmt) * @vRate / 100 + @vQBase
  else
  begin
    set @poErrMsg = '不能识别的提成方式: ' + @vRateMode
    return(1)
  end
  set @poCalcRate = @vRate
  
  --根据提成和保底金额计算实际提成金额
  exec @vRet = PCT_CHGBOOK_CALC_GUARDTOTAL @piCntrNum, @piCntrVersion, @piCntrLine, @piBeginDate, @piEndDate, @vGuardTotal output, @poErrMsg output
  if @vRet <> 0 return(@vRet)
  if @vCalcMode = '合计'
    set @poTotal = @poTotal + @vGuardTotal
  else if @vCalcMode = '取高值'
  begin
    if @poTotal <= @vGuardTotal
      set @poTotal = @vGuardTotal
  end else if @vCalcMode = '多退少补'
  begin
    set @poTotal = @poTotal - @vGuardTotal
  end else if @vCalcMode = '多不退少补'
  begin
    if @poTotal < @vGuardTotal
      set @poTotal = @vGuardTotal - @poTotal
  end else
  begin
    set @poErrMsg = '不能识别的计算方式: ' + @vCalcMode
    return(1)
  end

  --精度处理
  if @vRoundType = '四舍五入'
    set @poTotal = floor((@poTotal / @vFeePrec) + 0.5) * @vFeePrec
  else if @vRoundType = '进一'
    set @poTotal = ceiling(@poTotal / @vFeePrec) * @vFeePrec
  else if @vRoundType = '去尾'
    set @poTotal = floor(@poTotal / @vFeePrec) * @vFeePrec

  set @poTotal = @vSign * @poTotal

  select @vMessage = convert(varchar, @poTotal)
  exec PCT_CHGBOOK_LOGDEBUG 'Calc_RateTotal', @vMessage

  return(0)
end
GO
