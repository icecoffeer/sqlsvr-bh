SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERBCKSTGRCV_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @Msg varchar(255) output
) as
begin
  declare
    @Stat int,
    @ret int,
    @vouchernum varchar(32),
    @vouchertype varchar(64),
    @amount decimal(24,2),
    @storegid int
  select @Stat = STAT from VOUCHERBCKSTGRCV(nolock) where NUM = @Num
  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end
  select @ret = 0
  update VOUCHERBCKSTGRCV
    set STAT = 100,  CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
    where NUM = @num;
  select @storegid = usergid from fasystem(nolock)
  declare c_voucher cursor for
    select vouchernum, vouchertype, amount from voucherbckstgrcvdtl2(nolock)
    where num = @num
  open c_voucher
  fetch next from c_voucher into @vouchernum, @vouchertype, @amount
  while @@fetch_status = 0
  begin
    insert into vouchercashspan(num, astart, afinish)
      select @vouchernum, astart, afinish
      from vouchercashspantemp(nolock)
      where spid = @@spid
    exec @ret = VoucherCreateSingle @vouchernum, @vouchertype, @amount, @oper, @storegid, @msg output
    if @ret <> 0 break
    exec @ret = VoucherReceiveSingle @vouchernum, @storegid, @oper, @msg output
    if @ret <> 0 break
    exec @ret = VoucherSellSingle @vouchernum, @vouchertype, @amount, 0, @storegid, @oper, @msg output
    if @ret <> 0 break
    fetch next from c_voucher into @vouchernum, @vouchertype, @amount
  end
  Close c_voucher
  deallocate c_voucher
  if @ret <> 0 return(@ret)
  exec VOUCHERBCKSTGRCV_ADD_LOG @Num, 100, '审核', @Oper;
  return(0)
end
GO
