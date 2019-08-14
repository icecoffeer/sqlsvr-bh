SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BuyRecv](
    @id int,
    @src  int 
)as
begin
	declare @return_status int,
		@flowno char(12),
		@posno  char(10) 
	
	Select @flowno = flowno,
	       @posno  = posno
	From NBuy1 Where ID = @id And  SRC = @src	
	if @@RowCount <> 1
	begin
		raiserror('网络零售单已被接收或删除', 16, 1)
		return(1)		
 	end 	
 	
	if exists(select * from SYSTEM where USERGID = @src)
	begin
		raiserror('不能接收本单位生成的单据', 16, 1)
		return(1)
	end 	
	execute @return_status = BUYCHECKBILL @src, @id 	
	if (select 1 from StoreBuy1 where flowno= @flowno and posno = @posno and storegid = @src) is null
	begin
		Insert into StoreBuy1(STOREGID, FLOWNO, POSNO, SETTLENO, FILDATE, CASHIER, WRH, ASSISTANT, TOTAL,
			REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO, SCORE, CARDCODE, DEALER)
		Select SRC, FLOWNO, POSNO, SETTLENO, FILDATE, CASHIER, WRH, ASSISTANT, TOTAL,
			REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO, SCORE, CARDCODE, DEALER
		From NBUY1 where ID = @id and SRC = @src		
		Delete From  NBUY1 where ID = @id and SRC = @src
		
		Delete From StoreBuy11 where flowno = @flowno and posno = @posno and storegid = @src
		Insert into StoreBuy11(STOREGID, FLOWNO, POSNO, ITEMNO, SETTLENO, CURRENCY, AMOUNT, TAG, CARDCODE)
		Select SRC, FLOWNO, POSNO, ITEMNO, SETTLENO, CURRENCY, AMOUNT, TAG, CARDCODE
		From NBuy11 where ID = @id and SRC = @src
		Delete From NBuy11 where ID = @id and SRC = @src
		
		Delete From StoreBuy2 where flowno = @flowno and posno = @posno and storegid = @src
		Insert into StoreBuy2(STOREGID, FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE, FAVAMT,
			REALAMT, TAG, QPCGID, PRMTAG, INVNO, ASSISTANT, WRH, COST, DEALER)
		Select SRC, FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE, FAVAMT,
			REALAMT, TAG, QPCGID, PRMTAG, INVNO, ASSISTANT, WRH, COST, DEALER
		From NBuy2 where ID = @id and SRC = @src
		Delete From NBuy2 where ID = @id and SRC = @src
		
		Delete From StoreBuy21 where flowno = @flowno and posno = @posno and storegid = @src
		Insert into StoreBuy21(STOREGID, FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT, TAG)
		Select SRC, FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT, TAG
		From NBuy21 where ID = @id and SRC = @src
		Delete From NBuy21 where ID = @id and SRC = @src		
	end
	else
	begin
		Delete From  NBUY1 where ID = @id and SRC = @src
		Delete From  NBUY11 where ID = @id and SRC = @src
		Delete From  NBUY2 where ID = @id and SRC = @src
		Delete From  NBUY21 where ID = @id and SRC = @src
	end	
	return(0)
end
GO
