SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC_OCR_1201] (
  @piVdrGid integer,                        --供应商
  @piDept varchar(20),                      --费用结算组
  @piSrcNum varchar(20),                    --发生单据号
  @piStoreCond varchar(1000),               --门店条件
  @piGoodsCond varchar(1000),               --商品条件
  @poTotal decimal(24, 2) output,           --统计基数
  @poPayDate datetime output,               --付款日期
  @poErrMsg varchar(255) output             --出错信息
) as
begin
  select @poTotal = PAYTOTAL from CNTRPAYCASH where NUM = @piSrcNum
  select @poTotal = isnull(@poTotal, 0)
  select @poPayDate = convert(varchar(10), getdate(), 102)

  return(0)
end
GO
