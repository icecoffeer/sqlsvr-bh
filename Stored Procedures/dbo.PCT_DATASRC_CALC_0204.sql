SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC_0204] (
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
  declare @vSql nvarchar(2000)
  declare @vOp_DeptLimit integer
  declare @vOp_DeptMethod integer

  set @vSql = N'select @poTotal = -isnull(sum(d.TOTAL), 0)'
    + ' from DIRALC m(nolock), DIRALCDTL d(nolock)'
    + ' where m.CLS = ''直配出退'' and m.FILDATE >= @piBeginDate and m.FILDATE < @piEndDate + 1'
    + '  and m.VENDOR = @piVdrGid and m.NUM = d.NUM and m.CLS = d.CLS'
    + '  and m.STAT in (1, 6)'
  if isnull(@piGoodsCond, '') <> ''
    set @vSql = @vSql + ' and d.GDGID in (' + @piGoodsCond + ')'

  --结算组限制
  exec OPTREADINT 0, 'SettleDeptLimit', 0, @vOp_DeptLimit output
  exec OPTREADINT 0, 'AutoGetSettleDeptMethod', 0, @vOp_DeptMethod output
  if @vOp_DeptLimit = 1
  begin
    if @vOp_DeptMethod = 1
      set @vSql = @vSql + ' and d.GDGID in (select g.GID from GOODS g(nolock), SETTLEDEPTDEPT t(nolock) '
        + ' where g.F1 = t.DEPTCODE and t.CODE = ''' + @piDept + '''' + ')'
    else if @vOp_DeptMethod = 2
      set @vSql = @vSql + ' and d.GDGID in (select g.GID from GOODS g(nolock), SETTLEDEPTVDR t(nolock) '
        + ' where g.BILLTO = t.VDRGID and t.CODE = ''' + @piDept + '''' + ')'
  end

  exec sp_executesql @vSql, 
    N'@poTotal decimal(24, 2) out, @piBeginDate datetime, @piEndDate datetime, @piVdrGid integer',
    @poTotal out, @piBeginDate, @piEndDate, @piVdrGid

  return(0)
end
GO
