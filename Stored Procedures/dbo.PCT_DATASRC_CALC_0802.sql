SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC_0802](  
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
  
  set @vSql = N'select @poTotal = isnull(round(sum((c.amount * b.realamt / a.realamt) * (case when c.currency = 2 then 0.01 when c.currency = 12 then 0.04 else 0 end)),0), 0)'  
    + ' from buy1 a (nolock),buy2 b (nolock),buy11 c(nolock),goodsh g(nolock)'
    + ' where a.posno = b.posno and a.flowno = b.flowno ' 
    + ' and a.posno = c.posno and a.flowno = c.flowno '  
    + ' and a.fildate >= @piBeginDate and a.fildate < @piEndDate + 1 ' 
    + ' and b.GID = g.GID and g.BILLTO = @piVdrGid '
    + ' and c.currency in (2,12) and a.realamt <> 0 '
  if isnull(@piGoodsCond, '') <> ''  
    set @vSql = @vSql + ' and g.GID in (' + @piGoodsCond + ')'  
  --if isnull(@piStoreCond, '') <> ''  
    --set @vSql = @vSql + ' and r.ASTORE in (' + @piStoreCond + ')'  
  
  --结算组限制  
  exec OPTREADINT 0, 'SettleDeptLimit', 0, @vOp_DeptLimit output  
  exec OPTREADINT 0, 'AutoGetSettleDeptMethod', 0, @vOp_DeptMethod output  
  if @vOp_DeptLimit = 1  
  begin  
    if @vOp_DeptMethod = 1  
      set @vSql = @vSql + ' and g.F1 in (select DEPTCODE from SETTLEDEPTDEPT(nolock)'  
        + ' where CODE = ''' + @piDept + '''' + ')'  
    else if @vOp_DeptMethod = 2  
      set @vSql = @vSql + ' and g.BILLTO in (select VDRGID from SETTLEDEPTVDR(nolock)'  
        + ' where CODE = ''' + @piDept + '''' + ')'  
  end  
  
  exec sp_executesql @vSql,   
    N'@poTotal decimal(24, 2) out, @piBeginDate datetime, @piEndDate datetime, @piVdrGid integer',  
    @poTotal out, @piBeginDate, @piEndDate, @piVdrGid  
    
  return(0)  
end  

GO
