SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendInvDRpt] 
	@SendedDate DateTime,
	@Receiver integer,
	@ErrMessage varchar(100) output
as
begin

declare @usergid int
	,@RowCount int

	select @usergid = usergid from system
	--added by hxs from task 1812
	if exists ( select 1 from rptsndflag where flag = 1 and subject = '库存日报')
	begin
		declare @ReSendDate datetime	
		declare cur_ReSenddate cursor for
			select distinct adate from rptsndflag where flag = 1 and subject = '库存日报'
		open cur_ReSendDate
		fetch next from cur_ReSendDate into @ReSendDate
		while @@Fetch_Status = 0 
		begin
			if @ReSendDate <> @SendedDate
			begin
				delete from NInvdrpt where Rcv = @Receiver and Adate = @ReSendDate and Type = 0
				
				INSERT INTO NINVDRPT (
				                 ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
				                 CQ, CT, FQ, FT,
				                 FINPRC, FRTLPRC, FDXPRC,
				                 FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST,
				                 NSTAT, NNOTE, SRC, RCV,
				                 SNDTIME, RCVTIME, TYPE )
				           SELECT
				                 ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
				                 CQ, CT, FQ, FT,
				                 FINPRC, FRTLPRC, FDXPRC,
				                 FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST,
				                 0, NULL, 1, @Receiver,
				                 getdate(), NULL, 0
				           FROM INVDRPT (nolock)
				       where astore = @usergid and Adate = @ReSendDate
			
				if @@error <> 0
				begin
					close cur_ReSendDate
					Deallocate cur_ReSendDate
					Select @errMessage = '重发库存日报时插入数据出错。'
					return -1
				end
				
			end
			
			update rptsndflag Set flag = 0 where subject = '库存日报' and adate = @ReSendDate
			
			fetch next from cur_ReSendDate into @ReSendDate
		end
		close cur_ReSendDate
		Deallocate cur_ReSendDate
	end	

	delete from NInvdrpt where Rcv = @Receiver and Adate = @SendedDate and Type = 0

	INSERT INTO NINVDRPT (
                     ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
                     CQ, CT, FQ, FT,
                     FINPRC, FRTLPRC, FDXPRC,
                     FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST,
                     NSTAT, NNOTE, SRC, RCV,
                     SNDTIME, RCVTIME, TYPE )
               SELECT
                     ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,
                     CQ, CT, FQ, FT,
                     FINPRC, FRTLPRC, FDXPRC,
                     FPAYRATE, FINVPRC, FLSTINPRC, FINVCOST,
                     0, NULL, 1, @Receiver,
                     getdate(), NULL, 0
               FROM INVDRPT (nolock)
	       where astore = @usergid and Adate = @SendedDate

	if @@error <> 0
	begin
		Select @errMessage = '插入库存日报出错。'
		return -1
	end
	select @RowCount= Count(*) from InvDRpt(nolock)
		where astore = @Usergid and Adate = @SendedDate
	Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)
		Values ('库存日报',@Receiver,GetDate(),@SendedDate,@RowCount)
end
GO
