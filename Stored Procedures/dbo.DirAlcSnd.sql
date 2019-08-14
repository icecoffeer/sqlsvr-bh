SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
Create procedure [dbo].[DirAlcSnd](
	@cls char(10),
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

   	select @stat = STAT, @src = SRC from DIRALC 
	where CLS = @cls and NUM = @num

   	if @stat <> 1 and @stat <> 4  and @stat <> 6
	begin
         	raiserror('发送的单据不是已审核、已复核或冲单(负单)', 16, 1)
         	return(1)
   	end

   	if (select max(USERGID) from SYSTEM ) <> @src
	begin
         	raiserror('发送的不是本单位产生的单据', 16, 1)
         	return(1)
   	end

	select @CurNum = @num

	while @CurNum is not null and @CurNum <> ''
	begin
		execute GETNETBILLID @id output
   		
		insert into NDIRALC (ID, CLS, NUM, VENDOR, SENDER, RECEIVER, OCRDATE, PSR,
			TOTAL, TAX, ALCTOTAL, STAT, RECCNT, CHECKER, MODNUM, VENDORNUM,
			FILDATE, NSTAT, NOTE, NNOTE, SRC, RCV, SNDTIME, RCVTIME, FRCCHK, TYPE, ORDNUM, OUTTAX, PAYDATE, FROMNUM, FROMCLS, VERIFIER, TAXRATELMT, DEPT)  --2002-06-07 Ysp 2002060663069, 2005.12.2,ShenMin,Q5344
          	select @id, CLS, NUM, VENDOR, SENDER, RECEIVER, OCRDATE, PSR, 
			TOTAL, TAX, ALCTOTAL, STAT, RECCNT, CHECKER, MODNUM, VENDORNUM,
                 	FILDATE, 0, NOTE, null, @src, @rcvgid, getdate(), NULL, @frcchk, 0, ORDNUM, OUTTAX, PAYDATE, FROMNUM, FROMCLS, VERIFIER, TAXRATELMT, DEPT
          	from DIRALC 
		where CLS = @cls and NUM = @CurNum
   
   		if @@error <> 0 return(@@error)
   
   		insert into NDIRALCDTL (SRC, ID, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, 
				ALCPRC, ALCAMT, VALIDDATE, WRH, BNUM, OUTTAX,COST)
          		select  @src, @id, LINE, GDGID, CASES, QTY, PRICE, TOTAL, TAX, 
				ALCPRC, ALCAMT, VALIDDATE, 1, BNUM, OUTTAX, COST
          		from DIRALCDTL 	where CLS = @cls and NUM = @CurNum
   
                IF @CLS <> '直配出退'
    	 		insert into  NDIRALCDTL2(SRC, ID, LINE, GDGID, SUBWRH, SUBWRHCODE, WRH, QTY, COST)
   				select @src, @id, LINE, DIRALCDTL2.GDGID, SUBWRH, SUBWRH.CODE, DIRALCDTL2.WRH, QTY, COST
   				from DIRALCDTL2, SUBWRH where CLS = @cls and NUM = @CurNum 
   					 and DIRALCDTL2.SUBWRH *= SUBWRH.GID
   		
   		if @@error <> 0 return(@@error)
   
   		update DIRALC 
		set SNDTIME = getdate() 
		where CLS = @cls and NUM = @CurNum
		
	--2005.11.2, Edited by ShenMin, Q5336, 直配单发送时应同步发送单据附件
	        insert into NBILLAPDX(SRC, BILL, ID, FILDATE, DSPMODE, DSPDATE, OUTCTR,
				      OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
				      INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, TYPE, 
				      HDBILLNUM, INUNIT, NOTE2, SRCNUM, CLS, RCV)
	        select @src, 'DIRALC', @id, FILDATE, DSPMODE, DSPDATE, OUTCTR,
			              OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			              INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, 0,
			              HDBILLNUM, INUNIT, NOTE2, NUM, @cls, @rcvgid
                from BILLAPDX
                where BILL = 'DIRALC'
                and CLS = @cls
                and NUM = @CurNum		

		select @CurNum = MODNUM from DIRALC where CLS = @cls and NUM = @CurNum
		if @@RowCount <= 0 break
	end
	return(0)
end
GO
