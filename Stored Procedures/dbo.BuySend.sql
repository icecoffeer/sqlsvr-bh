SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BuySend](
    @flowno char(12),
    @posno  char(10)
)as
begin
	declare @max_id int,
		@src_gid int,
		@rcv_gid int
	
	execute  GETNETBILLID @max_id OUTPUT
	if @max_id is null
		select @max_id = 1
	
	select @src_gid = USERGID from SYSTEM		
	select @rcv_gid = ZBGID from SYSTEM 
	
	Insert into NBuy1(ID, FLOWNO, POSNO, SETTLENO, FILDATE, CASHIER, WRH, ASSISTANT, TOTAL,
		REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO, SCORE, CARDCODE, NSTAT,
		NNOTE, SRC, RCV, SNDTIME, RCVTIME, TYPE, DEALER)
	Select @max_id, Flowno, Posno, settleno, Fildate, Cashier, Wrh, Assistant, Total,
		RealAmt, PrevAmt, Guest, Reccnt, Memo, Tag, Invno, Score, CardCode, 0,
		Null, @src_gid, @rcv_gid, GetDate(), Null, 0, DEALER
	from Buy1
	Where Flowno = @flowno and Posno = @posno 

	Insert into NBuy11(ID, FLOWNO, POSNO, SETTLENO, ITEMNO,  TAG,  CARDCODE, CURRENCY, SRC, AMOUNT)
	Select @max_id, Flowno, Posno, settleno, Itemno, Tag, CardCode, Currency, @src_gid, Amount
	from Buy11
	Where Flowno = @flowno and Posno = @posno 
	
	Insert into NBuy2(ID, FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE, FAVAMT,
		REALAMT, TAG, QPCGID, PRMTAG, INVNO, ASSISTANT, WRH, COST, SRC, DEALER)
	Select @max_id, Flowno, Posno, Itemno, settleno, Gid, Qty, Inprc, Price, FavAmt,
		RealAmt, Tag, QpcGid, PrmTag, Invno, Assistant, Wrh, Cost, @src_gid, DEALER
	from Buy2
	Where Flowno = @flowno and Posno = @posno 
	
	Insert into NBuy21(SRC, ID, FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT, TAG)
	Select @src_gid, @max_id, Flowno, Posno, Itemno, FavType, Settleno, FavAmt, Tag
	From Buy21
	Where Flowno = @flowno and Posno = @posno 
	
	return(0)
end
GO
