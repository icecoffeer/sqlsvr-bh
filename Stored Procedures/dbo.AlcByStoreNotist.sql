SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcByStoreNotist](
	@num varchar(10),
	@noper int
) as
begin
	declare
	@newnum varchar(10),
	@MaxNum varchar(10),
	@storegid int,
	@MSG VARCHAR(255),
	@RET INT

	if not exists(select 1 from ALCBYSTORE where NUM = @num)
	begin
		raiserror('不存在要通知门店的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYSTOREDTL where NUM = @num)
	begin
		raiserror('不存在要通知门店的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYSTOREDTL2 where NUM = @num)
	begin
		raiserror('不存在要通知门店的单据', 16, 1)
		return(1)
	end

	declare C_AlcByStore cursor for
	select STOREGID from ALCBYSTOREDTL2 where NUM = @num
	open C_AlcByStore
	fetch next from C_AlcByStore into @storegid
	while @@fetch_status = 0
	begin
		select @MaxNum = max(Num) from AlcByStore
		execute NEXTBN @ABN = @MaxNum, @NEWBN = @newnum output

		insert into AlcByStore(NUM, SETTLENO, STAT, FILLER, FILDATE, CHECKER, DMDDATE, TOTAL,
      TAX, QTY, NOTE, CLS, DESRCTYPE, SRCNUM, DESRCNUM )
    select @newnum, SETTLENO, STAT, FILLER, FILDATE, CHECKER, DMDDATE, TOTAL,
      TAX, QTY, NOTE, CLS, '按门店', SRCNUM, @num
    from AlcByStore(NOLOCK)
    where NUM = @num

		insert into AlcByStoreDtl(NUM, LINE, GDGID, CASES, QTY, INVQTY, TOTAL, TAX, ASNQTY )
		select @newnum, LINE, GDGID, CASES, QTY, INVQTY, TOTAL, TAX, ASNQTY
		from AlcByStoreDtl(NOLOCK)
		where NUM = @num

		insert into AlcByStoreDtl2(NUM, STOREGID)
		values (@newnum, @storegid)

		update AlcByStore set stat = 17 where NUM = @newnum
  	exec @RET = AlcByStoreSnd @newnum, null, 0, 0, @msg output
  	if @RET <> 0
  	begin
  	  raiserror(@msg, 16, 1)
  	  return(1)
  	end

		fetch next from C_AlcByStore into @storegid
	end
	close C_AlcByStore
	deallocate C_AlcByStore

	UPDATE ALCBYSTORE set STAT = 18 where NUM = @num

	return 0
end
GO
