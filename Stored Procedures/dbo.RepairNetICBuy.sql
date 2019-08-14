SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RepairNetICBuy]
as
begin
	declare @zbgid int
	declare @userid varchar(20)
	declare @usergid int
	select @usergid = usergid, @zbgid = zbgid, @useRid = userid from system(nolock)
	if @usergid = @zbgid 
	begin
		raiserror('本系统即为总部，不能发送ICCARD消费数据。',16,1)
		return 
	end
	if @zbgid <> 1000000 
	begin
		raiserror('系统表中总部GID设置不正确。',16,1)
		return 
	end
	if @userid <> 'szmr'
	begin
		raiserror('系统表中USERID设置不正确。',16,1)
		return 
	end
	declare @action varchar(20),@fildate datetime
		,@store int,@cardnum varchar(20),@carrier int
	declare @id int
	declare @LstSndTime datetime

	declare cur_hst cursor for
		select action,fildate,store,cardnum,carrier from iccardhst
	open cur_hst
	fetch next from cur_hst into @action, @fildate , @store, @cardnum, @carrier
	while @@fetch_status = 0
	begin
	    set @LstSndTime = GetDate()
	    update ICCardHst set LstSndTime = @LstSndTime
	    where FilDate = @FilDate and CardNum = @CardNum and Carrier = @Carrier
	      and Action = @Action and Store = @Store
	    delete from niccardhst where FilDate = @FilDate and CardNum = @CardNum and Carrier = @Carrier
	      and Action = @Action and Store = @Store

	      execute @ID = SEQNEXTVALUE 'NICCARDHST'
	      insert into NICCardHst(ID, Action, FilDate, Store, CardNum, OldCardNum,
		OldBal, Occur, OldScore, Score, OldByDate, NewByDate, Oper, Note,
		Carrier, CardCost, CardType, LstSndTime, Sender, Src, Charge,
		NNote, Rcv, RcvTime, FrcChk, NType, NStat)
	      select @ID, Action, FilDate, Store, CardNum, OldCardNum, OldBal,
		Occur, OldScore, Score,OldByDate, NewByDate, Oper, Note,
		Carrier, CardCost, CardType, LstSndTime, 1, @usergid, Charge,
		null, @zbgid, null, 1, 0, 0 from iccardhst(nolock) 
		where FilDate = @FilDate and CardNum = @CardNum and Carrier = @Carrier
		      and Action = @Action and Store = @Store
		fetch next from cur_hst into @action, @fildate , @store, @cardnum, @carrier	
	end
	close cur_hst
	deallocate cur_hst

	declare @flowno varchar(12)
		,@posno varchar(10)
	declare cur_buy cursor for
		select flowno,posno from icbuy1
	open cur_buy
	fetch next from cur_buy into @flowno,@posno
	while @@fetch_status = 0
	begin
		delete from nicbuy1 where flowno = @flowno and posno = @posno
		delete from nicbuy11 where flowno = @flowno and posno = @posno
		delete from nicbuy2 where flowno = @flowno and posno = @posno
		exec ICBuySnd @Posno, @Flowno, @zbgid
		fetch next from cur_buy into @flowno,@posno
	end
	close cur_buy
	deallocate cur_buy
end

GO
