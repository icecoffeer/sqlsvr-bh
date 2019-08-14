SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Sort_Ord](
  @piNum varchar(14),
  @piOrderBy varchar(255),
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vSQLStr varchar(1024)
  if @piOrderBy is not null and @piOrderBy <> ''
  begin
    if object_id('tempdb..#OrderPoolOrderByTemp') is not null drop table #OrderPoolOrderByTemp
    set @vSQLStr = '
      select identity(int, 10001, 1) as ID, ORDDTL.LINE into #OrderPoolOrderByTemp
      from ORDDTL(nolock), GOODS(nolock)
      where ORDDTL.GDGID = GOODS.GID
        and ORDDTL.NUM = ''' + @piNum + ''''
      + ' order by '+ @piOrderBy
      + ' update ORDDTL set LINE = #OrderPoolOrderByTemp.ID - 10000
      from ORDDTL, #OrderPoolOrderByTemp where ORDDTL.LINE = #OrderPoolOrderByTemp.LINE and ORDDTL.NUM = ''' + @piNum + ''''
    exec(@vSQLStr)
  end
  return(0);
end
GO
