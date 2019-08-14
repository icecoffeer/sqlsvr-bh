SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoSendVdrDRpt]   
 @SendedDate DateTime,  
 @Receiver integer,  
 @ErrMessage varchar(100) output  
as  
begin  
  
declare @usergid int  
 ,@RowCount int  
  
 select @usergid = usergid from system  
  
 delete from NVdrdrpt where Rcv = @Receiver and Adate = @SendedDate and Type = 0  
  
 INSERT INTO NVDRDRPT (  
                     ASTORE,ASETTLENO,ADATE,BVDRGID,BWRH,  
                     BGDGID,DQ1,DQ2,DQ3,DQ4,DQ5,DQ6,DT1,  
                     DT2,DT3,dT4,DT5,DT6,DT7,DI2,   
                     NSTAT, NNOTE, SRC, RCV,  
                     SNDTIME, RCVTIME, TYPE )  
               SELECT  
                     ASTORE,ASETTLENO,ADATE,BVDRGID,BWRH,  
                     BGDGID,DQ1,DQ2,DQ3,DQ4,DQ5,DQ6,DT1,  
                     DT2,DT3,dT4,DT5,DT6,DT7,DI2,   
                     0, NULL, 1, @Receiver,  
                     getdate(), NULL, 0  
                FROM VDRDRPT(nolock)  
  where astore = @usergid and Adate = @SendedDate  
  
 if @@error <> 0  
 begin  
  Select @errMessage = '插入供应商帐款日报出错。'  
  return -1  
 end  
 select @RowCount= Count(*) from VdrDRpt(nolock)  
  where astore = @Usergid and Adate = @SendedDate  
 Insert into AutoSendLog(Subject,Receiver,OcrTime,SendDate,SendRows)  
  Values ('供应商帐款日报',@Receiver,GetDate(),@SendedDate,@RowCount)  
end  
GO
