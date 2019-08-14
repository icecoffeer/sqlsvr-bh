SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoCrmcardblklstRcv]
 @SRC int, 
 @ID int,  
 @ErrMsg varchar(200) output
as
begin  
 declare @result int  
 exec @result = PPS_CRMAddIn_Card_RcvNCRMCardBlkLst @SRC,@ID,@ErrMsg
 return @result  
end 
GO
