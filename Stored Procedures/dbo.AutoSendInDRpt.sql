SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendInDRpt]   
 @SendedDate DateTime,  
 @Receiver integer,  
 @ErrMessage varchar(100) output  
as  
begin  
  
declare @usergid int  
 ,@RowCount int  
 select @usergid = usergid from system  
  
 delete from nindrpt where Rcv = @Receiver and Adate = @SendedDate and Type = 0  
  
 INSERT INTO NINDRPT (ASTORE, ASETTLENO, ADATE,  
                     BGDGID, BVDRGID, BWRH,  
                     DQ1, DQ2, DQ3, DQ4,  
                     DT1, DT2, DT3, DT4,  
                     DI1, DI2, DI3, DI4,  
                     DR1, DR2, DR3, DR4,  
                     NSTAT, NNOTE, SRC, RCV,  
                     SNDTIME, RCVTIME, TYPE )  
  SELECT  ASTORE, ASETTLENO, ADATE,  
                     BGDGID, BVDRGID, BWRH,  
                     DQ1, DQ2, DQ3, DQ4,  
                     DT1, DT2, DT3, DT4,  
                     DI1, DI2, DI3, DI4,  
                     DR1, DR2, DR3, DR4,  
                     0, NULL, 1, @receiver,   
                     getdate(), NULL, 0  
                FROM INDRPT (Nolock)  
  where astore = @usergid and Adate = @SendedDate  
  
 if @@error <> 0  
 begin  
  Select @errMessage = '插入进货日报出错。'  
  return -1  
 end  
 select @RowCount= Count(*) from InDRpt(nolock)  
  where astore = @Usergid and Adate = @SendedDate  
 Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)  
  Values ('进货日报',@Receiver,GetDate(),@SendedDate,@RowCount)  
  
end  
GO
