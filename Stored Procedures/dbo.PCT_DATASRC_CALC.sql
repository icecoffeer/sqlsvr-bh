SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC] (
  @piDataSrc varchar(20),                   --数据来源
  @piVdrGid integer,                        --供应商
  @piDept varchar(20),                      --费用结算组
  @piBeginDate datetime,                    --统计开始日期
  @piEndDate datetime,                      --统计结束日期
  @piStoreCond varchar(1000),               --门店条件
  @piGoodsCond varchar(1000),               --商品条件
  @poTotal decimal(24, 2) output,           --统计基数
  @poErrMsg varchar(255) output             --出错信息
) as
begin
  declare @vRet integer
  declare @vSql nvarchar(512)

  set @vSql = 'exec @vRet = PCT_DATASRC_CALC_' + rtrim(@piDataSrc)
    + '  @piVdrGid, @piDept, @piBeginDate, @piEndDate, @piStoreCond, @piGoodsCond, @poTotal output, @poErrMsg output'
  exec sp_executesql @vSql,
    N'@vRet integer out, @piVdrGid integer, @piDept varchar(20), @piBeginDate datetime, @piEndDate datetime, @piStoreCond varchar(1000), @piGoodsCond varchar(1000), @poTotal decimal(24, 2) out, @poErrMsg varchar(255) out',
    @vRet out, @piVdrGid, @piDept, @piBeginDate, @piEndDate, @piStoreCond, @piGoodsCond, @poTotal out, @poErrMsg out

  return(@vRet)
end
GO
