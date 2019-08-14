SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_GenBillRollback](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @vNum char(10),
    @vBillName varchar(20),
    @vScopeFlag smallint,
    @vMsg varchar(255)

  set @vScopeFlag = 2

  if object_id('c_OrderPoolGenBills') is not null deallocate c_OrderPoolGenBills
  declare c_OrderPoolGenBills cursor for
    select BILLNAME, NUM
      from ORDERPOOLGENBILLS where FLAG <= @vScopeFlag
  open c_OrderPoolGenBills
  fetch next from c_OrderPoolGenBills into @vBillName, @vNum
  while @@fetch_status = 0
  begin
    if @vBillName = '定货单'
    begin
      delete from ORDDTL where NUM = @vNum
      delete from ORD where NUM = @vNum
      set @vMsg = '定货单, NUM: ' + @vNum
      exec OrderPool_WriteLog 2, 'SP:OrderPool_GenBillRollback', @vMsg
    end

    fetch next from c_OrderPoolGenBills into @vBillName, @vNum
  end
  close c_OrderPoolGenBills
  deallocate c_OrderPoolGenBills

  delete from ORDERPOOLGENBILLS where FLAG <= @vScopeFlag
    and @vBillName in ('定货单')

  return (0)
end
GO
