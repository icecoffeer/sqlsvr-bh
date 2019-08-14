SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoCrmwebaddrRcv]
 @SRC int, 
 @ID int,  
 @ErrMsg varchar(200) output
as
begin  
 declare @result int  
 exec @result = PPS_CRMADDIN_WEBSERVERADDR_RCVNCRMWEBSERVERADDR @SRC,@ID,@ErrMsg
 return @result  
end 
GO
