SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Clear_From_OrdApply](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vUserGid int,
    @vNum varchar(20),
    @vSQLStr varchar(4000)

  select @vUserGid = USERGID from SYSTEM(nolock)

  --处理定单
  if object_id('C_OrderPoolGenBills') is not null deallocate C_OrderPoolGenBills
  declare C_OrderPoolGenBills cursor for
    select NUM from ORDERPOOLGENBILLS where FLAG = 2 and BILLNAME = '叫货申请单'
    for update
  open C_OrderPoolGenBills
  fetch next from C_OrderPoolGenBills into @vNum
  while @@fetch_status = 0
  begin
    set @vSQLStr = 'delete from ORDERPOOL'
      + ' where ORDERTYPE like ''RF叫货申请'' and (GDGID in (select GDGID from storeordapplydtl(nolock)'
      + '                   where NUM = ''' + @vNum + ''') or gdgid in (select distinct p.pgid from ORDDTL(nolock),pkg p(nolock)'
      + '                   where FLAG = 0 and gdgid=p.egid and NUM = ''' + @vNum + '''))'
      + ' and exists(select 1 from orderpoolhtemp t(nolock) where orderpool.uuid=t.uuid)'
    exec(@vSQLStr)

    update ORDERPOOLGENBILLS set FLAG = 3 where current of C_OrderPoolGenBills

    fetch next from C_OrderPoolGenBills into @vNum
  end
  close C_OrderPoolGenBills
  deallocate C_OrderPoolGenBills

  return(0);
end
GO
