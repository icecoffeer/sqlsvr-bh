SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[SendStkinBckBill](
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
		@CurNum char(10),
		@UseInvChgRelQty int
	declare @tempid int
	exec optreadint 0,'UseInvChgRelQty',0,@UseInvChgRelQty output
   	select @stat = STAT, @src = SRC
   	from STKINBCK where CLS = @cls and NUM = @num

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

   		insert into NSTKINBCK (ID, CLS, NUM, VENDOR, VENDORNUM, BILLTO, OCRDATE, TOTAL,
          		TAX, FILDATE, CHECKER, STAT, MODNUM, PSR, RECCNT, NSTAT, NNOTE, NOTE,
          		SRC, RCV, SNDTIME, RCVTIME, FRCCHK, TYPE, GENCLS, GENNUM)
       	  	select @id, @cls, NUM, VENDOR, VENDORNUM, BILLTO, OCRDATE, TOTAL, 
			TAX, FILDATE, CHECKER, STAT, MODNUM, PSR, RECCNT, 0, NULL, NOTE, 
			@src, @rcvgid, getdate(), NULL, @frcchk, 0, GENCLS, GENNUM
          	from STKINBCK 
		where CLS = @cls and NUM = @CurNum

   		if @@error <> 0 return(@@error)

		/* 2000.12.6 */
		if (select BATCHFLAG from SYSTEM) = 1
		begin
			--为　定制 Fanduoyi
     			--小->大
     			if @UseInvChgRelQty = 1 
			begin
	   			insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,
	   				SUBWRH,NOTE, COST)
	          		select @src, @id, LINE, isnull(i.GDGID,d.gdgid) gdgid, CASES, 
	          			isnull(d.QTY/i.relqty, d.Qty) qty, isnull(d.total/(d.qty/i.relqty),price) PRICE, 
	          			TOTAL, TAX, VALIDDATE, 1, SUBWRH,NOTE,COST  --Modified by wang xin 2003.02.13
	          		from STKINBCKDTL d, invchg i 
				where CLS = @cls and NUM = @CurNum and i.gdgid2 =* d.gdgid
				
				select @tempid from NSTKINBCK(nolock) where num = @CurNum and CLS = @cls
				
				update nstkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = nstkinbckdtl.gdgid and nstkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and id = @tempid
				
				/*update stkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = stkinbckdtl.gdgid and stkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and stkinbckdtl.num = @curnum and stkinbckdtl.cls = @cls
				*/
				
			end
			else
	   			insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,
	   				SUBWRH,NOTE, COST)
	          		select @src, @id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, 1,
	          		SUBWRH,NOTE,COST  --Modified by wang xin 2003.02.13
	          		from STKINBCKDTL 
				where CLS = @cls and NUM = @CurNum
		end			 
		else
		if (select BATCHFLAG from system ) = 2 
		begin
			--为慈客隆定制 Fanduoyi
     			--小->大
     			if @UseInvChgRelQty = 1 
			begin
	   			insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,
	   				SUBWRH,NOTE, COST)
	          		select @src, @id, LINE, isnull(i.GDGID,d.gdgid) gdgid, CASES, 
	          			isnull(d.QTY/i.relqty, d.Qty) qty, isnull(d.total/(d.qty/i.relqty),price) PRICE, 
	          			TOTAL, TAX, VALIDDATE, 1, SUBWRH,NOTE,COST  --Modified by wang xin 2003.02.13
	          		from STKINBCKDTL d, invchg i 
				where CLS = @cls and NUM = @CurNum and i.gdgid2 =* d.gdgid
				
				select @tempid from NSTKINBCK(nolock) where num = @CurNum and CLS = @cls
				
				update nstkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = nstkinbckdtl.gdgid and nstkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and id = @tempid
				
				/*update stkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = stkinbckdtl.gdgid and stkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and stkinbckdtl.num = @curnum and stkinbckdtl.cls = @cls
				*/

				--added by wang xin 2003.02.13
				insert into NSTKINBCKDTL2(SRC, ID, LINE, SUBWRH, WRH, GDGID, QTY, COST)
				select @src, @id, LINE, SUBWRH, WRH, i.GDGID, d.QTY/i.relqty qty, COST
				from STKINBCKDTL2 d, invchg i 
				where CLS = @cls and NUM = @CurNum and i.gdgid2 = d.gdgid
			
			end
			else
			begin
				insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,
	   				SUBWRH,NOTE,COST)
	          		select @src, @id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, 1,
	          		SUBWRH,NOTE,COST
	          		from STKINBCKDTL 
				where CLS = @cls and NUM = @CurNum
				
				--added by wang xin 2003.02.13
				insert into NSTKINBCKDTL2(SRC, ID, LINE, SUBWRH, WRH, GDGID, QTY, COST)
				select @src, @id, LINE, SUBWRH, WRH, GDGID, QTY, COST
				from STKINBCKDTL2 
				where CLS = @cls and NUM = @CurNum
			end
		end
		else
		begin
			--为慈客隆定制 
     			--小->大
     			if @UseInvChgRelQty = 1 
			begin
	   			insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,NOTE)
	          		select @src, @id, LINE, isnull(i.GDGID,d.gdgid) gdgid, CASES, 
	          			isnull(d.QTY/i.relqty, d.Qty) qty, isnull(d.total/(d.qty/i.relqty),price) PRICE, 
	          			TOTAL, TAX, VALIDDATE, 1,NOTE  --Modified by wang xin 2003.02.13
	          		from STKINBCKDTL d, invchg i 
				where CLS = @cls and NUM = @CurNum and i.gdgid2 =* d.gdgid

				select @tempid from NSTKINBCK(nolock) where num = @CurNum and CLS = @cls
				
				update nstkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = nstkinbckdtl.gdgid and nstkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and id = @tempid
				
				/*update stkinbckdtl set cases = qty / g.qpc
				from goods g(nolock) 
				where g.gid = stkinbckdtl.gdgid and stkinbckdtl.gdgid in (select gdgid2 from invchg(nolock))
				and stkinbckdtl.num = @curnum and stkinbckdtl.cls = @cls
				*/
			end
			else
	   			insert into NSTKINBCKDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, WRH,NOTE)
	          		select @src, @id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, VALIDDATE, 1,NOTE
	          		from STKINBCKDTL 
				where CLS = @cls and NUM = @CurNum						
		end
   		if @@error <> 0 return(@@error)

   		update STKINBCK 
		set SNDTIME = getdate() 
		where CLS = @cls and NUM = @CurNum

		select @CurNum = MODNUM from STKINBCK where CLS = @cls and NUM = @CurNum
		if @@RowCount <= 0 break
	end
	return(0)
end
GO
