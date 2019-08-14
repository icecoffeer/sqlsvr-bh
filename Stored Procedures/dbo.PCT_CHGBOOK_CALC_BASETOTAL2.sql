SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_CALC_BASETOTAL2] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @piStoreGid integer,                    --门店
  @piGdScopeSql varchar(255),             --商品条件
  @piDataSrc varchar(10),                 --数据来源
  @piBeginDate datetime,                  --统计开始日期
  @piEndDate datetime,                    --统计结束日期
  @poTotal decimal(24, 2) output,         --统计基数
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

  --计算统计基数
  set @vStoreScopeSql = convert(varchar, @piStoreGid)
  if isnull(@piGdScopeSql, '') <> ''
    set @vGdScopeSql = 'select GID from GOODS where ' + @piGdScopeSql
  else
    set @vGdScopeSql = null

  select 
    @vVdrGid = VENDOR,
    @vDept = rtrim(DEPT)
  from CTCNTR where NUM = @piCntrNum and VERSION = @piCntrVersion;
  exec @vRet = PCT_DATASRC_CALC @piDataSrc, @vVdrGid, @vDept, @piBeginDate, @piEndDate, 
    @vStoreScopeSql, @vGdScopeSql, @poTotal output, @poErrMsg output
  set @poTotal = isnull(@poTotal, 0)

  select @vMessage = @piDataSrc + '=' + convert(varchar, @poTotal)
  exec PCT_CHGBOOK_LOGDEBUG 'Calc_BaseTotal2', @vMessage

  return(@vRet)
end
GO
