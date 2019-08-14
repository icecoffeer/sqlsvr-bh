SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PCT_CHGBOOK_GET_STORESCOPE] (
  @piCntrNum varchar(14),                 --合约号
  @piCntrVersion integer,                 --合约版本号
  @piCntrLine integer,                    --合约行号
  @poStoreScopeSql varchar(1000) output,  --门店条件
  @poErrMsg varchar(255) output           --出错信息
) as
begin
  declare @vStoreScope varchar(255)

  select @vStoreScope = STORESCOPE
  from CTCNTRRATEDTL
  where NUM = @piCntrNum and VERSION = @piCntrVersion and LINE = @piCntrLine
  if @vStoreScope <> '全部'
    set @poStoreScopeSql = 'select STOREGID from CTCNTRRATESTORE '
      + ' where NUM = ''' + @piCntrNum + ''' '
      + '  and VERSION = ' + convert(varchar, @piCntrVersion)
      + '  and LINE = ' + rtrim(convert(varchar, @piCntrLine))
  else
    set @poStoreScopeSql = null

  return(0)
end
GO
