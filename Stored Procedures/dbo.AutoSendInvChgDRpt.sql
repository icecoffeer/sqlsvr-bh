SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendInvChgDRpt]   
 @SendedDate DateTime,  
 @Receiver integer,  
 @ErrMessage varchar(100) output  
as  
begin  
  
declare @usergid int  
 ,@RowCount int  
  
 select @usergid = usergid from system  
  
 delete from NInvChgdrpt where Rcv = @Receiver and Adate = @SendedDate and Type = 0  
  
 INSERT INTO NINVCHGDRPT (  
                     ASTORE,ASETTLENO,ADATE,BWRH,  
                     BGDGID,DQ1,DQ2,DQ4,DQ5,DI1,   
                     DI2,DI3,DI4,DI5,DR1,DR2,DR3,DR4,DR5,   
                     NSTAT, NNOTE, SRC, RCV,  
                     SNDTIME, RCVTIME, TYPE )  
               SELECT  
                     ASTORE,ASETTLENO,ADATE,BWRH,  
                     BGDGID,DQ1,DQ2,DQ4,DQ5,DI1,   
                     DI2,DI3,DI4,DI5,DR1,DR2,DR3,DR4,DR5,   
                     0, NULL, 1,@Receiver,  
                     getdate(), NULL, 0  
                FROM INVCHGDRPT (nolock)  
  where astore = @usergid  and ADate = @SendedDate  
  
 if @@error <> 0  
 begin  
  Select @errMessage = '插入库存调整日报出错。'  
  return -1  
 end  
 select @RowCount= Count(*) from InvChgDRpt(nolock)  
  where astore = @Usergid and Adate = @SendedDate  
 Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)  
  Values ('库存调整日报',@Receiver,GetDate(),@SendedDate,@RowCount)  
end  
GO
