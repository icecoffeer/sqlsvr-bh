SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[OrderPool_Update_Bill]
(
  @piOperGid int,
  @poErrMsg varchar(255) output
)
as
begin
  declare @vSettleNo int
  declare @vBillName varchar(20)
  declare @vNum varchar(14)
  declare @vTotal money
  declare @vTax money
  declare @vRecCnt int
  declare @vRet int
  declare @vOrderBy varchar(255)

  select @vSettleNo = max(NO) from MONTHSETTLE(nolock)
  exec OptReadStr 8183, 'SortingSQL', '', @vOrderBy output

  if object_id('C_OrderPoolGenBills') is not null deallocate C_OrderPoolGenBills
  declare C_OrderPoolGenBills cursor for
    select BILLNAME, NUM from ORDERPOOLGENBILLS where FLAG in (0, 1)
    for update
  open C_OrderPoolGenBills
  fetch next from C_OrderPoolGenBills into @vBillName, @vNum
  while @@fetch_status = 0
  begin
    if @vBillName = '定货单'
    begin
      select @vTotal = IsNull(sum(TOTAL), 0), @vTax = IsNull(sum(TAX), 0), @vRecCnt = count(1)
      from ORDDTL(nolock) where NUM = @vNum
      if @vRecCnt = 0
      begin
        delete from ORDDTL where NUM = @vNum
        delete from ORD where NUM = @vNum
        delete from ORDERPOOLGENBILLS where current of C_OrderPoolGenBills
        fetch next from C_OrderPoolGenBills into @vBillName, @vNum
        continue
      end
      else begin
        exec OrderPool_Sort_Ord @vNum, @vOrderBy, @poErrMsg output
        update ORDDTL set SETTLENO = @vSettleNo where NUM = @vNum
        update ORD set SETTLENO = @vSettleNo, TOTAL = @vTotal, TAX = @vTax, RECCNT = @vRecCnt where NUM = @vNum
      end
    end

    update ORDERPOOLGENBILLS set FLAG = 2 where current of C_OrderPoolGenBills
    fetch next from C_OrderPoolGenBills into @vBillName, @vNum
  end
  close C_OrderPoolGenBills
  deallocate C_OrderPoolGenBills

  return(0);
end
GO
