SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERRECYCLE_CHKTO100]
(
  @Num varchar(14),
  @Oper varchar(20),
  @ToStat int,
  @Msg varchar(255) output
) as
begin

  declare
    @vRet int,
    @Stat int,
    @StoreGid int,
    @VoucherNum varchar(32)

  select @Stat = STAT, @StoreGid = FROMSTORE from VOUCHERRECYCLE(nolock) where NUM = @Num

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end

  declare cur_VoucherNum cursor for
    select VOUCHERNUM from VOUCHERRECYCLEDTL where NUM = @num;
  open cur_VoucherNum;
  fetch next from cur_VoucherNum into @VoucherNum
  while @@fetch_status = 0
  begin
  	exec @vRet = VoucherRecycleSingle @VoucherNum, @storeGid, @Oper, @Msg output
    if @vRet <> 0
    begin
    	close cur_VoucherNum;
    	deallocate cur_VoucherNum;
    	return(@vRet);
    end;
    fetch next from cur_VoucherNum into @VoucherNum;
  end;
  close cur_VoucherNum;
  deallocate cur_VoucherNum;
  update VOUCHERRECYCLE
  set STAT = @ToStat,  CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num;

  exec VOUCHERRECYCLE_ADD_LOG @Num, @ToStat, '审核', @Oper;
end
GO
