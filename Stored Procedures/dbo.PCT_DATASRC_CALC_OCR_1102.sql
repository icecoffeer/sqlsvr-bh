SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_DATASRC_CALC_OCR_1102] (
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
  declare @vOp_DeptLimit integer
  declare @vOp_DeptMethod integer
  declare @vDept varchar(20)
  declare @vTotal decimal(24, 2)

  --结算组限制
  exec OPTREADINT 0, 'SettleDeptLimit', 0, @vOp_DeptLimit output
  exec OPTREADINT 0, 'AutoGetSettleDeptMethod', 0, @vOp_DeptMethod output
  if @vOp_DeptLimit = 1
  begin
    if @vOp_DeptMethod = 1
      select @vDept = isnull(d.CODE, '')
      from PAY m(nolock), PAYDTL pd(nolock), GOODS g(nolock), SETTLEDEPTDEPT d(nolock)
      where m.NUM = @piSrcNum and m.NUM = pd.NUM and pd.LINE = 1 and pd.GDGID = g.GID and g.F1 = d.DEPTCODE
    else if @vOp_DeptMethod = 2
      select @vDept = isnull(d.CODE, '') from PAY m(nolock), SETTLEDEPTVDR d(nolock)
      where m.NUM = @piSrcNum and m.BILLTO = d.VDRGID
    else if @vOp_DeptMethod = 3
      select @vDept = isnull(d.CODE, '') from PAY m(nolock), SETTLEDEPTWRH d(nolock)
      where m.NUM = @piSrcNum and m.WRH = d.WRHGID
    else
      set @vDept = ''
    if @piDept <> @vDept 
    begin
      set @poTotal = 0
      set @poPayDate = convert(varchar, getdate(), 102)
      return(0)
    end
  end

  set @poTotal = 0

  select @vTotal = isnull(sum(p.QTY * d.RTLPRC), 0)
  from PAYDTL p(nolock), STKINDTL d(nolock)
  where p.FROMNUM = d.NUM and p.FROMLINE = d.LINE
  and p.FROMCLS = '自营进' and d.CLS = '自营' and p.NUM = @piSrcNum
  set @poTotal = @poTotal + @vTotal

  select @vTotal = isnull(sum(p.QTY * d.RTLPRC), 0)
  from PAYDTL p(nolock), STKINBCKDTL d(nolock)
  where p.FROMNUM = d.NUM and p.FROMLINE = d.LINE
  and p.FROMCLS = '自营进退' and d.CLS = '自营' and p.NUM = @piSrcNum
  set @poTotal = @poTotal + @vTotal

  select @vTotal = isnull(sum(p.QTY * d.RTLPRC), 0)
  from PAYDTL p(nolock), DIRALCDTL d(nolock)
  where p.FROMNUM = d.NUM and p.FROMLINE = d.LINE
  and p.FROMCLS = '直配出' and d.CLS = '直配出' and p.NUM = @piSrcNum
  set @poTotal = @poTotal + @vTotal

  select @vTotal = isnull(sum(p.QTY * d.RTLPRC), 0)
  from PAYDTL p(nolock), DIRALCDTL d(nolock)
  where p.FROMNUM = d.NUM and p.FROMLINE = d.LINE
  and p.FROMCLS = '直配出退' and d.CLS = '直配出退' and p.NUM = @piSrcNum
  set @poTotal = @poTotal + @vTotal

  set @poPayDate = convert(varchar(10), getdate(), 102)

  return(0)
end
GO
