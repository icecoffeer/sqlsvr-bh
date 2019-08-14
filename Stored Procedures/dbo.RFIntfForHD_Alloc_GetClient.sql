SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RFIntfForHD_Alloc_GetClient](
  @poErrMsg varchar(255) output --传出参数：错误消息。返回值不为0时有效。
)
as
begin
  declare
    @Opt_UseOutAge int,
    @SQL varchar(8000)

  --读取选项的值
  exec OPTREADINT 0, 'opt_useOutAge', 0, @Opt_UseOutAge output

  --获取候选数据集。
  set @SQL = 'select rtrim(CODE) 配往单位代码, rtrim(NAME) 配往单位名称'
    + ' from STORE(nolock)'
    + ' where 1 = 1'
  ----被限制配货的门店记录不用返回。
  set @SQL = @SQL + ' and ISLTD = 0'
  ----本店记录不用返回。
  set @SQL = @SQL + ' and not exists('
    + ' select 1 from SYSTEM(nolock)'
    + ' where SYSTEM.USERCODE = STORE.CODE'
    + ' )'
  ----已停用的门店记录不用返回。
  if @Opt_UseOutAge = 1
    set @SQL = @SQL + ' and OUTAGE = 0'
  ----按照代码排序。
  set @SQL = @SQL + ' order by CODE'
  ----执行查询语句。
  exec(@SQL)

  return 0
end
GO
