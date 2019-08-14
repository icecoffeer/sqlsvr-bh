SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VOUCHERSELL_CHKTO100]
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
    @VoucherNum varchar(32),
    @VoucherType varchar(64),
    @Amount decimal(24, 4),
    @SellAmount decimal(24, 4)

  select @Stat = STAT, @StoreGid = FROMSTORE, @VoucherType = VoucherType  from VOUCHERSELL(nolock) where NUM = @Num

  if @Stat <> 0
  begin
    set @Msg = '不是未审核的单据，不能进行审核操作.'
    return(1)
  end
  
  delete from VOUCHERCASHAUTHORTEMP where ID = @@SPID;
  insert into VOUCHERCASHAUTHORTEMP(ID, Line, Code, Flag)
    select @@SPID, Line, ScopeCode, ScopeFlag from VoucherSellDtl2 (noLock) where num = @Num; 
  declare cur_VoucherNum cursor for
    select VOUCHERNUM, Amount, SellAmount from VOUCHERSELLDTL where NUM = @num;
  open cur_VoucherNum;
  fetch next from cur_VoucherNum into @VoucherNum, @Amount, @SellAmount
  while @@fetch_status = 0
  begin
  	exec @vRet = VoucherSellSingle @VoucherNum, @VoucherType, @Amount, @SellAmount, @storeGid, @Oper, @Msg output
    if @vRet <> 0
    begin
    	close cur_VoucherNum;
    	deallocate cur_VoucherNum;
    	return(@vRet);
    end;
    fetch next from cur_VoucherNum into @VoucherNum, @Amount, @SellAmount;
  end;
  close cur_VoucherNum;
  deallocate cur_VoucherNum;
  update VOUCHERSELL
  set STAT = @ToStat,  CHKDATE = GETDATE(), CHECKER = @Oper, LSTUPDTIME = getdate(), LSTUPDOPER = @oper
  where NUM = @num;

  exec VOUCHERSELL_ADD_LOG @Num, @ToStat, '审核', @Oper;
end
GO
