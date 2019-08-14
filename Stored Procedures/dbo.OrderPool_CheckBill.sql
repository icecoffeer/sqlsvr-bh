SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_CheckBill](
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare
    @return_status int,
    @vOrderBillStat varchar(10),
    @vBillName varchar(10),
    @vNum char(10),
    @vUserGid int,
    @vDtlCnt int

  exec OrderPool_WriteLog 0, 'SP:OrderPool_CheckBill', '审核单据'

  exec OptReadStr 8183, 'OrderBillStat', '', @vOrderBillStat output
  select @vUserGid = USERGID from SYSTEM(nolock)
  declare c_OrderPoolGenBills cursor for
    select BILLNAME, NUM from ORDERPOOLGENBILLS
      where FLAG in (3) and BILLNAME in ('定货单')
    for update
  open c_OrderPoolGenBills
  fetch next from c_OrderPoolGenBills into @vBillName, @vNum
  while @@fetch_status = 0
  begin
    if @vBillName = '定货单'
    begin
      if @vOrderBillStat = '已预审'
      begin
        update ORD set STAT = 7 where NUM = @vNum
      end
      else if @vOrderBillStat = '已审核'
      begin
        exec OrdChk @vNum
      end
      select @vDtlCnt = count(*) from ORDDTL(nolock)
        where NUM = @vNum
    end

    update ORDERPOOLGENBILLS set FLAG = 4, DTLCNT = @vDtlCnt where current of c_OrderPoolGenBills
    fetch next from c_OrderPoolGenBills into @vBillName, @vNum
  end
  close c_OrderPoolGenBills
  deallocate c_OrderPoolGenBills

  return (0)
end
GO
