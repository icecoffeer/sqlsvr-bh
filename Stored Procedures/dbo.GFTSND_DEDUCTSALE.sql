SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTSND_DEDUCTSALE]
(
  @poDeduct int output,         --是否进行了自动扣除
  @poErrMsg varchar(255) output
) as
begin
  declare @vPosNo varchar(10)
  declare @vFlowNo varchar(14)
  declare @vCurrency int
  declare @vPrmTag char(10)
  declare @vAmount money

  set @poDeduct = 0
  update TMPGFTSNDSALE set DEDUCTAMT = 0 where SPID = @@SPID;

  --对于所有受限的付款方式
  declare c_cur cursor for
    select distinct l.NAME
    from GFTPRMRULELMTDTL l, TMPGFTSNDRESULT r
    where l.RCODE = r.RCODE and r.SPID = @@SPID
      and l.LMTNO = 4 and l.VALUE = '2'
  open c_cur
  fetch next from c_cur into @vCurrency
  while @@fetch_status = 0
  begin
    set @poDeduct = 1

    exec HDDEALLOCCURSOR 'c_sale' --确保游标被释放
    declare c_sale cursor for
    select distinct POSNO, FLOWNO from TMPGFTSNDSALE where SPID = @@SPID
    open c_sale
    fetch next from c_sale into @vPosNo, @vFlowNo
    while @@fetch_status = 0
    begin
      select @vAmount = 0
      select @vAmount = isnull(sum(AMOUNT), 0) from BUY11(nolock)
      where POSNO = @vPosNo and FLOWNO = @vFlowNo and CURRENCY = @vCurrency group by CURRENCY;
      if @vAmount > 0
      begin
        exec GFTSND_DEDUCTONESALE @vPosNo, @vFlowNo, @vAmount
      end

      fetch next from c_sale into @vPosNo, @vFlowNo
    end
    close c_sale
    deallocate c_sale

    fetch next from c_cur into @vCurrency
  end
  close c_cur
  deallocate c_cur

  delete from TMPGFTSNDRULEGOODS where SPID = @@SPID; --added by jinlei 每次用完删除TMPGFTSNDRULEGOODS表的当前SPID数据，避免数据量过大
  return(0)
end
GO
