SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_OCCUR_GEN_ONE] (
  @piCntrNum varchar(14),             --合约号
  @piCntrVersion integer,             --合约版本
  @piCntrLine integer,                --合约行号
  @piDataSrc varchar(20),             --数据来源
  @piSrcNum varchar(20),              --来源单据号
  @piOperGid integer,                 --操作人
  @poErrMsg varchar(255) output       --出错信息
) as
begin
  declare @vRet integer
  declare @vRateTotal decimal(24, 2)
  declare @vBaseTotal decimal(24, 2)
  declare @vCalcRate decimal(24, 2)
  declare @vChgBookNum varchar(14)
  declare @vToPayMethod integer
  declare @vPayDate datetime
  declare @vChgModal varchar(10)
  declare @vAheadDays integer
  declare @vDiscountRate integer
  declare @vMessage varchar(255)
  declare @vDate datetime

  set @vMessage = '数据来源=' + @piDataSrc + ',单号=' + @piSrcNum
  exec PCT_CHGBOOK_LOGDEBUG 'Occur_Gen_One', @vMessage

  --计算发生信息
  exec @vRet = PCT_CHGBOOK_CALC_OCRINFO @piCntrNum, @piCntrVersion, @piCntrLine, @piDataSrc, @piSrcNum, 
    @vBaseTotal output, @vPayDate output, @poErrMsg output
  if @vRet <> 0 return(@vRet)
  select @vToPayMethod = c.TOPAYMETHOD 
  from CTCHGDEF c, CTCNTRDTL d
  where c.CODE = d.CHGCODE and d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine
  if (@vPayDate is null) or (@vToPayMethod = 0)
    set @vPayDate = convert(varchar, getdate(), 102)
  else
    set @vPayDate = convert(varchar, @vPayDate, 102)
  set @vDate = convert(varchar, getdate(), 102)
    
  --计算提成金额
  select 
    @vChgModal = f.MODALTYPE
  from CTCHGDEF f, CTCNTRDTL d
  where d.NUM = @piCntrNum and d.VERSION = @piCntrVersion and d.LINE = @piCntrLine and d.CHGCODE = f.CODE
  if @vChgModal = '01' --提前付款模型特殊处理
  begin
    select
      @vDiscountRate = DISCOUNTRATE,
      @vAheadDays = AHEADDAYS
    from CTCNTRRATEDTL
    where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine

    if getdate() + @vAheadDays < @vPayDate
      set @vRateTotal = @vBaseTotal * ( 100 - @vDiscountRate) / 100
    else
      set @vRateTotal = 0
    set @vCalcRate = 100 - @vDiscountRate
  end else
  begin
    exec @vRet = PCT_CHGBOOK_CALC_RATETOTAL @piCntrNum, @piCntrVersion, @piCntrLine, @vDate, @vDate, @vBaseTotal, 
      @vRateTotal output, @vCalcRate output, @poErrMsg output
    if @vRet <> 0 return(@vRet)
  end

  --创建费用单
  exec @vRet = PCT_CHGBOOK_CREATE_CHGBOOK null, @piCntrNum, @piCntrVersion, @piCntrLine, 3, @vDate, @vDate, @vDate, 
    @vBaseTotal, @vRateTotal, @vCalcRate, @piSrcNum, @vDate, @vPayDate, null, @vChgBookNum output, @piOperGid, @poErrMsg output
  if @vRet <> 0 return(@vRet)

  return(0)
end
GO
