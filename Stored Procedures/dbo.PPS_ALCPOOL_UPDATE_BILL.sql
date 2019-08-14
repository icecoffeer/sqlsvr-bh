SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PPS_ALCPOOL_UPDATE_BILL]
(
  @piOperGid int,
  @poErrMsg varchar(255) output
) as
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
  exec OptReadStr 500, '配货出货单明细排序规则', '', @vOrderBy output

  if object_id('c_genbills') is not null deallocate c_genbills
	declare c_genbills cursor for
	select BILLNAME, NUM from ALCPOOLGENBILLS where FLAG in (0, 1)
	for update
	open c_genbills
	fetch next from c_genbills into @vBillName, @vNum
	while @@fetch_status = 0
	begin
    if @vBillName = '定货单'
    begin
      select @vTotal = isnull(sum(TOTAL), 0), @vTax = isnull(sum(TAX), 0), @vRecCnt = count(1)
      from ORDDTL(nolock) where NUM = @vNum
      if @vRecCnt = 0
      begin
        delete from ORDDTL where NUM = @vNum
        delete from ORD where NUM = @vNum
      end else
      begin
        update ORDDTL set SETTLENO = @vSettleNo where NUM = @vNum
        update ORD set SETTLENO = @vSettleNo, TOTAL = @vTotal, TAX = @vTax, RECCNT = @vRecCnt where NUM = @vNum
      end
    end else if @vBillName = '配货出货单'
    begin
      select @vTotal = isnull(sum(TOTAL), 0), @vTax = isnull(sum(TAX), 0), @vRecCnt = count(1)
      from STKOUTDTL(nolock) where NUM = @vNum and CLS = '配货'
      if @vRecCnt = 0
      begin
        delete from STKOUTDTL where NUM = @vNum and CLS = '配货'
        delete from STKOUT where NUM = @vNum and CLS = '配货'
      end else
      begin
        exec @vRet = PPS_ALCPOOL_SORT_STKOUT @vNum, @vOrderBy, @poErrMsg output
        update STKOUTDTL set SETTLENO = @vSettleNo where NUM = @vNum and CLS = '配货'
        update STKOUT set SETTLENO = @vSettleNo, TOTAL = @vTotal, TAX = @vTax, RECCNT = @vRecCnt
        where NUM = @vNum and CLS = '配货'
      end
    end else if @vBillName = '批发单'
    begin
      select @vTotal = isnull(sum(TOTAL), 0), @vTax = isnull(sum(TAX), 0), @vRecCnt = count(1)
      from STKOUTDTL(nolock) where NUM = @vNum and CLS = '批发'
      if @vRecCnt = 0
      begin
        delete from STKOUTDTL where NUM = @vNum and CLS = '批发'
        delete from STKOUT where NUM = @vNum and CLS = '批发'
      end else
      begin
        update STKOUTDTL set SETTLENO = @vSettleNo where NUM = @vNum and CLS = '批发'
        update STKOUT set SETTLENO = @vSettleNo, TOTAL = @vTotal, TAX = @vTax, RECCNT = @vRecCnt
        where NUM = @vNum and CLS = '批发'
      end
    end else if @vBillName = '配货通知单'
    begin
      select @vRecCnt = count(1)
      from DISTNOTIFYDTL(nolock) where NUM = @vNum
      update DISTNOTIFYDTL set SETTLENO = @vSettleNo where NUM = @vNum
      update STKOUT set SETTLENO = @vSettleNo, RECCNT = @vRecCnt where NUM = @vNum
    end

	  update ALCPOOLGENBILLS set FLAG = 2 where current of c_genbills
    fetch next from c_genbills into @vBillName, @vNum
  end
  close c_genbills
  deallocate c_genbills

  return(0);
end
GO
