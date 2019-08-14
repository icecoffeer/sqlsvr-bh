SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_SORT_STKOUT]
(
  @piNum varchar(14),
  @piOrderBy varchar(255),
  @poErrMsg varchar(255) output
) as
begin
  declare @vSQLStr varchar(1024)
  if @piOrderBy is not null and @piOrderBy <> ''
  begin
    if object_id('tempdb..#temp') is not null drop table #temp
    set @vSQLStr = '
      select identity(int, 10001, 1) as ID, STKOUTDTL.LINE into #temp
      from stkoutdtl(nolock), goods(nolock)
      where stkoutdtl.cls = ''配货''
        and stkoutdtl.gdgid = goods.gid
        and stkoutdtl.num =''' + @piNum + ''''
      + ' order by '+ @piOrderBy
      + ' update stkoutdtl set line = #temp.id -10000
      from stkoutdtl, #temp where stkoutdtl.line = #temp.line and stkoutdtl.num = '''+@piNum+''''+' and stkoutdtl.cls = ''配货'''
    exec(@vSQLStr)
  end
  return(0);
end
GO
