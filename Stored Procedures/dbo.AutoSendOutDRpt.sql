SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendOutDRpt]   
 @SendedDate DateTime,  
 @Receiver integer,  
 @ErrMessage varchar(100) output  
as  
begin  
  
declare @usergid int  
 ,@RowCount int  
  
 select @usergid = usergid from system  
  
 delete from nOutdrpt where Rcv = @Receiver and Adate = @SendedDate and Type = 0  
  
        INSERT INTO NOUTDRPT (  
                     ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,  
                     BCSTGID,  
                     DQ1, DQ2, DQ3, DQ4, DQ5,DQ6, DQ7,  
                     DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,  
                     DI1, DI2, DI3, DI4, DI5, DI6, DI7,  
                     DR1, DR2, DR3, DR4, DR5, DR6, DR7,  
                     NSTAT, NNOTE, SRC, RCV,  
                     SNDTIME, RCVTIME, TYPE )  
               SELECT  
                     ASTORE, ASETTLENO, ADATE, BGDGID, BWRH,  
                     BCSTGID,  
                     DQ1, DQ2, DQ3, DQ4, DQ5, DQ6, DQ7,  
                     DT1, DT2, DT3, DT4, DT5, DT6, DT7, DT91, DT92,  
                     DI1, DI2, DI3, DI4, DI5, DI6, DI7,  
                     DR1, DR2, DR3, DR4, DR5, DR6, DR7,  
                     0, NULL, 1, @Receiver,   
                     getdate(), NULL, 0  
               FROM OUTDRPT (Nolock)  
        where astore = @usergid and ADate = @SendedDate  
  
 if @@error <> 0  
 begin  
  Select @errMessage = '插入出货日报出错。'  
  return -1  
 end  
 select @RowCount= Count(*) from OutDRpt(nolock)  
  where astore = @Usergid and Adate = @SendedDate  
 Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)  
  Values ('出货日报',@Receiver,GetDate(),@SendedDate,@RowCount)  
end  
GO
