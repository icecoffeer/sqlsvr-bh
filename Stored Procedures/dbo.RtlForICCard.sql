SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlForICCard]
  @posno varchar(10),
  @flowno char(12)
as
begin
	declare @cardcode varchar(20)
	declare @ACTION	VarCHAR(10),
		@FILDATE DATEtime,
		@STORE	int,
		@OCCUR	MONEY,
		@Score	MONEY,
		@OPER	VarCHAR(10),	/*零售处理*/
		@NOTE	varchar(100),	
		@CARRIER	int
	declare @zbgid int
	declare @return_value int
	declare @memo varchar(255)

	select @zbgid = zbgid, @store = usergid  from system(nolock)
	select @carrier = Guest, @CardCode = CardCode, @Score = Score, @FilDate = FilDate, @Memo = Memo
		from Buy1(nolock) where posno = @posno and Flowno = @Flowno

	if isnull(@CardCode,'') = '' return 0
	if isnull(@Memo,'') <> '' return 0
/*
	select @Action = '消费'
	select @Occur = isnull(sum(amount),0) from buy11 where posno = @posno and Flowno = @flowno and cardcode = @cardcode
	select @Oper = '零售处理'
	select @Note = '收银机号:'+ rtrim(@Posno) +' 流水号:'+ rtrim(@Flowno)
*/
	insert into ICBuy1(Store,Flowno,Posno,settleno,fildate,cashier,wrh,assistant,total,realamt,prevamt,
		guest,reccnt,memo,invno,score,cardcode)
	select @store,Flowno,Posno,settleno,fildate,cashier,wrh,assistant,total,realamt,prevamt,
		guest,reccnt,memo,invno,score,cardcode
		from buy1(nolock)
		where posno = @posno and Flowno = @Flowno
/*
	insert into iccardhst(action,fildate,store,cardnum,occur,score,oper,note,carrier,SRC)
		values (@action, @fildate, @store, @cardCode, @occur, @score, @oper, @note, @carrier, @STore)
	if @@error <> 0 return -1
*/
	insert into ICBuy11(store,Flowno,posno,itemno,settleno,currency,amount,cardcode)
	select @store,Flowno,posno,itemno,settleno,currency,amount,cardcode 
		from buy11 (nolock)
		where posno = @posno and flowno = @flowno
	insert into ICBuy2(store,Flowno,posno,itemno,settleno,gid,qty,inprc,price,realamt,favamt,PrmTag,
		assistant,wrh,invno)
	select @store,Flowno,posno,itemno,settleno,gid,qty,inprc,price,realamt,favamt,PrmTag,
		assistant,wrh,invno
		from buy2 (nolock)
		where  posno = @posno and flowno = @flowno
	if @@error <> 0 return -1
/*2002.07.20	
	if isnull(@ZBGID,0) = 0 return 0
	exec @return_value = ICBuySnd @Posno, @Flowno, @zbgid
	return @return_value
*/
end
GO
