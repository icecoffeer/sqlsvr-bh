SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC_OCR] (
  @piDataSrc varchar(20),                   --数据来源
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
  declare @vRet integer
  declare @vSql nvarchar(512)

  set @vSql = 'exec @vRet = PCT_DATASRC_CALC_OCR_' + rtrim(@piDataSrc)
    + '  @piVdrGid, @piDept, @piSrcNum, @piStoreCond, @piGoodsCond, @poTotal output, @poPayDate output, @poErrMsg output'
  exec sp_executesql @vSql,
    N'@vRet integer out, @piVdrGid integer, @piDept varchar(20), @piSrcNum varchar(20), @piStoreCond varchar(1000), @piGoodsCond varchar(1000), @poTotal decimal(24, 2) out, @poPayDate datetime out, @poErrMsg varchar(255) out',
    @vRet out, @piVdrGid, @piDept, @piSrcNum, @piStoreCond, @piGoodsCond, @poTotal out, @poPayDate out, @poErrMsg out
  return(@vRet)
end
GO
