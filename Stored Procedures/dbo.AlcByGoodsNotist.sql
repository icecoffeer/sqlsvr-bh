SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcByGoodsNotist](
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

	if not exists(select 1 from ALCBYGOODS where NUM = @num)
	begin
		raiserror('不存在要通知门店的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYGOODSDTL where NUM = @num)
	begin
		raiserror('不存在要通知门店的单据', 16, 1)
		return(1)
	end

	declare C_AlcByGoods cursor for
	select STOREGID from ALCBYGOODSDTL where NUM = @num
	open C_AlcByGoods
	fetch next from C_AlcByGoods into @storegid
	while @@fetch_status = 0
	begin
		select @MaxNum = max(Num) from AlcByStore
		if @MaxNum IS NULL
      SELECT @newnum = '0000000001'
    else
		execute NEXTBN @ABN = @MaxNum, @NEWBN = @newnum output

		insert into AlcByStore(NUM, SETTLENO, STAT, FILLER, FILDATE, CHECKER, DMDDATE, TOTAL,
      TAX, QTY, NOTE, CLS, DESRCTYPE, SRCNUM, DESRCNUM )
    select @newnum, a.SETTLENO, a.STAT, a.FILLER, a.FILDATE, a.CHECKER, a.DMDDATE, b.TOTAL,
      b.TAX, b.QTY, a.NOTE, '采购配货', '按商品', null, @num
    from AlcByGoods a(NOLOCK), AlcByGoodsDtl b(NOLOCK)
    where a.NUM = @num and b.NUM = @num and b.storegid = @storegid

		insert into AlcByStoreDtl(NUM, LINE, GDGID, CASES, QTY, INVQTY, TOTAL, TAX, ASNQTY )
		select @newnum, 1, a.GDGID, b.CASES, b.QTY, a.INVQTY, b.TOTAL, b.TAX, b.ASNQTY
		from AlcByGoods a(NOLOCK), AlcByGoodsDtl b(NOLOCK)
		where a.NUM = @num and b.NUM = @num and b.storegid = @storegid

		insert into AlcByStoreDtl2(NUM, STOREGID)
		values (@newnum, @storegid)

		update AlcByStore set stat = 17 where NUM = @newnum
  	exec @RET = AlcByStoreSnd @newnum, null, 0, 0,@msg output
  	if @RET <> 0
  	begin
  	  raiserror(@msg, 16, 1)
  	  return(1)
  	end

		fetch next from C_AlcByGoods into @storegid
	end
	close C_AlcByGoods
	deallocate C_AlcByGoods

	UPDATE ALCBYGOODS set STAT = 18 where NUM = @num

	return 0
end
GO
