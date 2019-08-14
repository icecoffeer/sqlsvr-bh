SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_AllocLook_QueryBills](
  @piEmpCode varchar(10),       --传入参数：操作员代码。
  @piClientCode varchar(8000),  --传入参数：配往单位代码，对应于STORE.CODE。
  @piWrhCode varchar(1000),     --传入参数：仓位代码，对应于WAREHOUSE.CODE。
  @piOcrDate datetime,          --传入参数：发生日期。
  @poErrMsg varchar(255) output --传出参数（返回值不为0时有效）：错误消息。
)
as
begin
  declare
    @SQL varchar(8000)

  set @SQL = 'select'
    + ' ''×'' 勾选,'
    + ' so.NUM 单号,'
    + ' bs.NAME 状态,'
    + ' s.CODE 配往单位代码,'
    + ' s.NAME 配往单位名称,'
    + ' w.CODE 仓位代码,'
    + ' w.NAME 仓位名称,'
    + ' e.CODE 填单人代码,'
    + ' e.NAME 填单人名称,'
    + ' so.TOTAL 含税金额,'
    + ' so.TAX 税额,'
    + ' (select isnull(sum(QTY), 0) from STKOUTDTL sod(nolock) where sod.CLS = so.CLS and sod.NUM = so.NUM) 数量,'
    + ' convert(varchar(10), getdate(), 120) 打印日期'
    + ' from STKOUT so(nolock)'
    + ' join BILLSTAT bs(nolock) on bs.NO = so.STAT'
    + ' join STORE s(nolock) on s.GID = so.CLIENT'
    + ' join WAREHOUSE w(nolock) on w.GID = so.WRH'
    + ' join EMPLOYEE e(nolock) on e.GID = so.FILLER'
    + ' where so.CLS = ''配货'''
  if @piClientCode is not null and rtrim(@piClientCode) <> ''
  begin
    set @SQL = @SQL + ' and s.CODE in (' + @piClientCode + ')'
  end
  if @piWrhCode is not null and rtrim(@piWrhCode) <> ''
  begin
    set @SQL = @SQL + ' and w.CODE in (' + @piWrhCode + ')'
  end
  if @piOcrDate is not null
  begin
    set @SQL = @SQL
      + ' and so.OCRDATE >= ''' + convert(varchar(10), @piOcrDate, 120) + ''''
      + ' and so.OCRDATE < ''' + convert(varchar(10), @piOcrDate + 1, 120) + ''''
  end

  exec(@SQL)

  return 0
end
GO
