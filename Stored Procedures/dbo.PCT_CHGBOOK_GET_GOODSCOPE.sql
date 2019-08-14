SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_GET_GOODSCOPE] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @poGoodsScopeSql varchar(1000) output,  --商品条件
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vGdScope varchar(1000)
  declare @vGdScopeSql varchar(1000)

  select
    @vGdScope = GDSCOPE,
    @vGdScopeSql = GDSCOPESQL
  from CTCNTRRATEDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  --当@vGdScope <> '全部'并且没有指定商品范围条件时处理@vGdScopeSql否则生成费用单时报错
  if @vGdScopeSql is null or @vGdScopeSql = '' select @vGdScopeSql = '1 = 1'

  if @vGdScope <> '全部'
    set @poGoodsScopeSql = 'select GID from GOODS where ' + @vGdScopeSql
      + ' and GID not in (select GDGID from CTCNTRRATEGOODS '
      + ' where NUM = ''' + @piCntrNum + ''' '
      + '  and VERSION = ' + convert(varchar, @piCntrVersion)
      + '  and LINE = ' + rtrim(convert(varchar, @piCntrLine))
      + ')'
  else
    set @poGoodsScopeSql = 'select GID from GOODS where GID not in (select GDGID from CTCNTRRATEGOODS '    --CTCNTRRATEGOODS合约提成不包含商品
      + ' where NUM = ''' + @piCntrNum + ''' '
      + '  and VERSION = ' + convert(varchar, @piCntrVersion)
      + '  and LINE = ' + rtrim(convert(varchar, @piCntrLine))
      + ')'

  return(0)
end

GO
