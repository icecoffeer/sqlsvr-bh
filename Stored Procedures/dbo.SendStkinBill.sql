SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

Create procedure [dbo].[SendStkinBill](
	@Cls char(8),
	@num char(10),
	@rcvgid int,
	@frcchk smallint
) with encryption as
begin
  	declare
   		@src int,
   		@stat smallint,
   		@id int,
		@CurNum char(10)

   	select @stat = STAT, @src = SRC
   	from STKIN where CLS = @cls and NUM = @num

   	if @stat <> 1 and @stat <> 4  and @stat <> 6
	begin
         	raiserror('发送的单据不是已审核、已复核或冲单(负单)', 16, 1)
         	return(1)
   	end

   	if (@cls <> '自营') and ((select max(USERGID) from SYSTEM ) <> @src)
	begin
         	raiserror('发送的不是本单位产生的单据', 16, 1)
         	return(1)
   	end

	select @CurNum = @num

	while @CurNum is not null and @CurNum <> ''
	begin
		execute GETNETBILLID @id output

		insert into NSTKIN (ID, CLS, NUM, VENDOR, VENDORNUM, BILLTO, OCRDATE, TOTAL,
          		TAX, FILDATE, CHECKER, STAT, MODNUM, RECCNT, NSTAT, NNOTE, NOTE, SRC,
          		RCV, SNDTIME, RCVTIME, FRCCHK, TYPE, ORDNUM, PAYDATE)
          	select @id, @cls, NUM, VENDOR, VENDORNUM, BILLTO, OCRDATE, TOTAL, TAX,
                 	FILDATE, CHECKER, STAT, MODNUM, RECCNT, 0, NULL, NOTE, @src,
                 	@rcvgid, getdate(), NULL, @frcchk, 0, ORDNUM, PAYDATE
          	from STKIN
		where CLS = @cls and NUM = @CurNum

   		if @@error <> 0 return(@@error)

   		insert into NSTKINDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH, NOTE/*2002-01-22*/)
          	select @src, @id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, 1, NOTE
          	from STKINDTL
		where CLS = @cls and NUM = @CurNum
		
		--Added by wang xin 2003.02.013
		insert into NSTKINDTL2(SRC,ID, LINE, SUBWRH, WRH, GDGID, QTY, COST)
		select @src, @id, LINE, SUBWRH,WRH, GDGID, QTY,COST	
		from STKINDTL2
		where CLS = @cls and NUM = @curNum
		 
   		if @@error <> 0 return(@@error)

   		update STKIN
		set SNDTIME = getdate()
		where CLS = @cls and NUM = @CurNum

		select @CurNum = MODNUM from STKIN where CLS = @cls and NUM = @CurNum
		if @@RowCount <= 0 break
	end
	return(0)
end
GO
