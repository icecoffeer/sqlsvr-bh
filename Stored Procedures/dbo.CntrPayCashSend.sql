SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CntrPayCashSend] (
  @num  char(14),
  @Msg  varchar(255) OUTPUT
)
as
begin
  declare @return_status int
  declare @ivccode char(14)
  declare @chgtype char(20)
	
  select @return_status = 0
  declare c_sendtl cursor for
  select chgtype, ivccode from CntrPayCashDtl
    where num = @num
  open c_sendtl
  fetch next from c_sendtl into @chgtype, @ivccode
  while @@fetch_status = 0
  begin
    if @chgtype = '供应商结算单'
  	  exec @return_status = PAYSND @ivccode, @Msg OUTPUT
    else if @chgtype = '费用单'
      exec @return_status = CHKCHGBOOK_SEND @ivccode, 0, @Msg OUTPUT
    else if @chgtype = '预付款单'
      exec @return_status = PrePay_SEND @ivccode, 0, @Msg OUTPUT
    else if @chgtype = '压库金额收款单'
      exec @return_status = DepIn_SEND @ivccode, 0, @Msg OUTPUT
  	
  	fetch next from c_sendtl into @chgtype, @ivccode
  end
  close c_sendtl
  deallocate c_sendtl
	
  return @return_status
end
GO
