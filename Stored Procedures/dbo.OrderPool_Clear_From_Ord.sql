SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Clear_From_Ord](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare @vOrderDateFromDiff varchar(10)
  declare @vOrderDateToDiff varchar(10)
  declare @vSendDateFromDiff varchar(10)
  declare @vSendDateToDiff varchar(10)
  declare @vOrderDateFrom varchar(10)
  declare @vOrderDateTo varchar(10)
  declare @vSendDateFrom varchar(10)
  declare @vSendDateTo varchar(10)
  declare @vUserGid int
  declare @vNum varchar(14)
  declare @vSQLStr varchar(1024)
  declare @vSpanSQLStr varchar(1024)

  exec OptReadStr 8183, 'OrderDateFromDiff', '', @vOrderDateFromDiff output
  exec OptReadStr 8183, 'OrderDateToDiff', '', @vOrderDateToDiff output
  exec OptReadStr 8183, 'SendDateFromDiff', '', @vSendDateFromDiff output
  exec OptReadStr 8183, 'SendDateToDiff', '', @vSendDateToDiff output

  set @vSpanSQLStr = ''
  if @vOrderDateFromDiff <> ''
  begin
    set @vOrderDateFrom = convert(varchar(10), dateadd(day, convert(int, @vOrderDateFromDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.ORDERDATE >= ''' + @vOrderDateFrom + ''''
  end
  if @vOrderDateToDiff <> ''
  begin
    set @vOrderDateTo = convert(varchar(10), dateadd(day, convert(int, @vOrderDateToDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.ORDERDATE - 1 < ''' + @vOrderDateTo + ''''
  end
  if @vSendDateFromDiff <> ''
  begin
    set @vSendDateFrom = convert(varchar(10), dateadd(day, convert(int, @vSendDateFromDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.SENDDATE >= ''' + @vSendDateFrom + ''''
  end
  if @vSendDateToDiff <> ''
  begin
    set @vSendDateTo = convert(varchar(10), dateadd(day, convert(int, @vSendDateToDiff), getdate()), 102)
    set @vSpanSQLStr = @vSpanSQLStr + ' and ORDERPOOL.SENDDATE - 1 < ''' + @vSendDateTo + ''''
  end

  select @vUserGid = USERGID from SYSTEM(nolock)

  --处理定单
  if object_id('C_OrderPoolGenBills') is not null deallocate C_OrderPoolGenBills
  declare C_OrderPoolGenBills cursor for
    select NUM from ORDERPOOLGENBILLS where FLAG = 2 and BILLNAME = '定货单'
    for update
  open C_OrderPoolGenBills
  fetch next from C_OrderPoolGenBills into @vNum
  while @@fetch_status = 0
  begin
    set @vSQLStr = 'delete from ORDERPOOL'
      + ' where ORDERTYPE not like ''RF叫货申请'''
      + '   and exists(select 1 from ORDERPOOLHTEMP t(nolock) where ORDERPOOL.UUID=t.UUID)'
      + '   and ('
      + '     GDGID in (select GDGID from ORDDTL(nolock)'
      + '       where FLAG = 0 and NUM = ''' + @vNum + ''')'
      + '   )'

    if @vSpanSQLStr <> ''
      set @vSQLStr = @vSQLStr + @vSpanSQLStr

    exec(@vSQLStr)

    update ORDERPOOLGENBILLS set FLAG = 3 where current of C_OrderPoolGenBills

    fetch next from C_OrderPoolGenBills into @vNum
  end
  close C_OrderPoolGenBills
  deallocate C_OrderPoolGenBills

  return(0);
end
GO
