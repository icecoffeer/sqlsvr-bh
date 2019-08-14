SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[CSTMIZESND]
@NUM char(10),
@RCV int
as
begin
	declare @Stat smallint, @Id int, @CurNum char(10), @BatchFlag smallint
	declare @UserGID int, @CurrentTime datetime, @CfmBySelf smallint, @finished smallint

	select @UserGID = USERGID, @CfmBySelf = CFMBYSELF, @BatchFlag = BATCHFLAG from SYSTEM
	select @CurrentTime = getdate()

	select @Stat = STAT, @finished = FINISHED from CSTMIZE where NUM = @NUM

        if @CfmBySelf = 0 
	begin
           if  @stat <> 10 and @Finished <> 0
           begin
		raiserror('该单据不是待批准单据, 不能发送', 16, 1)
		return(1)
           end
	end
        else if @CfmBySelf = 1
	begin
           if  @stat <> 11 and @Stat <> 4 and (not (@stat = 10 and @finished = 1))
           begin
		raiserror('该单据不是已批准、已作废单据或冲单(负单), 不能发送', 16, 1)
		return(1)
           end 
 	end      

	if @CfmBySelf = 0 and (select SRC from CSTMIZE where NUM = @NUM) <> @UserGID
	begin
		raiserror('该单据不是本单位生成的单据,不能发送', 16, 1)
		return(1)
	end

	if @CfmBySelf = 1 and (select SRC from CSTMIZE where NUM = @NUM) = @UserGID
	begin
		raiserror('该单据是本单位生成的单据,不能发送', 16, 1)
		return(1)
	end

	select @CurNum = @NUM

	while @CurNum is not null and @CurNum <> ''
	begin
		execute GETNETBILLID @Id = @Id output

		insert into NCSTMIZE (ID, SETTLENO, NUM, VENDOR, CLIENT, BILLTO, RECEIVER, TOTAL, TAX, GTOTAL, PREPAY,
                        FILDATE, CHKDATE, CFMDATE, FILLER, CHECKER, CONFIRMER, SLR, STAT, MODNUM, RECCNT, FINISHED,
                        NSTAT, NOTE, NNOTE, SRC, SRCNUM, RCV, SNDTIME, RCVTIME,	TYPE)
		select @Id, SETTLENO, NUM, VENDOR, CLIENT, BILLTO, RECEIVER, TOTAL, TAX, GTOTAL, PREPAY,
                        FILDATE, CHKDATE, CFMDATE, FILLER, CHECKER, CONFIRMER, SLR, STAT, MODNUM, RECCNT, FINISHED,
			0, NOTE, null, @UserGID, SRCNUM, @RCV, @CurrentTime, null, 0
		from CSTMIZE
		where NUM = @CurNum

		insert into NCSTMIZEDTL (SRC, ID, NUM, SETTLENO, LINE, GDGID, GQTY, QTY, PRICE, GTOTAL, TOTAL, TAX,
			WRH, SUBWRH, INPRC, RTLPRC, NOTE)
		select @UserGID, @Id, NUM, SETTLENO, LINE, GDGID, GQTY, QTY, PRICE, GTOTAL, TOTAL, TAX,
			1, (CASE WHEN @BATCHFLAG = 1 THEN SUBWRH ELSE NULL END), INPRC, RTLPRC, NOTE
		from CSTMIZEDTL
		where NUM = @CurNum

		update CSTMIZE
		set SNDTIME = @CurrentTime
		where NUM = @CurNum

                if @CfmBySelf =0
                begin
                     insert into NBILLAPDX(SRC, BILL, ID, FILDATE, DSPMODE, DSPDATE, OUTCTR,
	    		    OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			    INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, TYPE, RCV)
	             select @UserGID, 'NCSTMIZE', @Id, FILDATE, DSPMODE, DSPDATE, OUTCTR,
			    OUTCTRPHONE, OUTADDR, OUTNEARBY, INCTR, INCTRPHONE,
			    INADDR, INNEARBY, INSTDATE, DBGDATE, FILLER, NOTE, 0, @RCV
                     from BILLAPDX
                     where BILL = 'CSTMIZE'
                     and NUM = @CurNum
                end 

                IF @STAT = 10 BREAK

		select @CurNum = MODNUM from CSTMIZE where NUM = @CurNum
	end
end

GO
