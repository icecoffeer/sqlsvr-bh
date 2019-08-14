SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Ord_GetPoolRecordsByRange](
  @piEmpCode varchar(10),
  @piDeptCode varchar(10),
  @piSortCode varchar(13),
  @piBrandCode varchar(10),
  @piVdrCode varchar(10),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vOper varchar(30),
    @vSQL nvarchar(4000),
    @vParams nvarchar(4000)

  --获取员工名称

  select @vOper = rtrim(NAME) + '[' + rtrim(CODE) + ']'
    from EMPLOYEE(nolock)
    where CODE = @piEmpCode

  --传入参数处理

  set @piDeptCode = isnull(@piDeptCode, '')
  set @piSortCode = isnull(@piSortCode, '')
  set @piBrandCode = isnull(@piBrandCode, '')
  set @piVdrCode = isnull(@piVdrCode, '')

  --获取结果集

  set @vSQL =
    'select' +
    '  g.CODE 商品代码,' +
    '  g.NAME 商品名称,' +
    '  v.CODE 供应商代码,' +
    '  v.NAME 供应商名称,' +
    '  w.CODE 仓位代码,' +
    '  w.NAME 仓位名称,' +
    '  op.QTY 数量,' +
    '  op.PRICE 单价,' +
    '  op.ORDERTYPE 数据来源,' +
    '  op.IMPTIME 上传时间,' +
    '  op.IMPORTER 上传人,' +
    '  op.NOTE 备注,' +
    '  op.STOREORDAPPLYTYPE 门店叫货申请单类型,' +
    '  op.UUID 编号' +
    '  from ORDERPOOL op(nolock)' +
    '    join GOODS g(nolock) on op.GDGID = g.GID' +
    '    join VENDOR v(nolock) on op.VDRGID = v.GID' +
    '    join WAREHOUSE w(nolock) on op.WRH = w.GID' +
    '  where IMPORTER = @vOper'
  if @piDeptCode <> ''
    set @vSQL = @vSQL +
      '    and left(isnull(g.F1, ''''), len(@piDeptCode)) = @piDeptCode'
  if @piSortCode <> ''
    set @vSQL = @vSQL +
      '    and left(isnull(g.SORT, ''''), len(@piSortCode)) = @piSortCode'
  if @piBrandCode <> ''
    set @vSQL = @vSQL +
      '    and g.BRAND = @piBrandCode'
  if @piVdrCode <> ''
    set @vSQL = @vSQL +
      '    and v.CODE = @piVdrCode'

  set @vSQL = @vSQL +
    '  order by op.ORDERTYPE, op.VDRGID, op.WRH, op.GDGID'

  set @vParams =
    '@vOper varchar(30), ' +
    '@piDeptCode varchar(10), ' +
    '@piSortCode varchar(13), ' +
    '@piBrandCode varchar(10), ' +
    '@piVdrCode varchar(10)'

  exec SP_EXECUTESQL
    @vSQL,
    @vParams,
    @vOper,
    @piDeptCode,
    @piSortCode,
    @piBrandCode,
    @piVdrCode

  return 0
end
GO
