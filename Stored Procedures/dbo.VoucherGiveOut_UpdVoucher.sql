SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VoucherGiveOut_UpdVoucher]
(
  @piVcNum varchar(32), --券号
  @piAmount decimal(24,2), --券面额
  @piOper varchar(20), --用户
  @piStoreGid int, --当前门店
  @poErrMsg varchar(255) output --错误信息
) as
begin
  --将券置为已发放
  if (select state from Voucher where  Num = @piVcNum ) = 0 --增加判断如果是预制券，之前是已经发放的，不用执行发放购物券
  begin   
  UPDATE Voucher
    SET State = 1, ReceiveStore = @piStoreGid, ReceiveOperator = @piOper, ReceiveTime = GETDATE()
  WHERE Num = @piVcNum
  -- 插入日志
  EXEC VoucherWriteLog @piVcNum, 0, 1, @piOper, @piStoreGid, '发放购物券成功。'
  end 

  --将券置为已发售
  UPDATE Voucher
    SET State = 4, SellAmount = @piAmount, AMOUNT = @piAmount, SellStore = @piStoreGid, SellOperator = @piOper,
        SellTime = GETDATE()
  WHERE Num = @piVcNum
  -- 插入日志
  EXEC VoucherWriteLog @piVcNum, 1, 4, @piOper, @piStoreGid, '发售购物券成功。'

  return 0
end
GO
