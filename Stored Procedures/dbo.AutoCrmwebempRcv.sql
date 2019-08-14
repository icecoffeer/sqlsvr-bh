SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoCrmwebempRcv]
 @SRC int, 
 @ID int,  
 @ErrMsg varchar(200) output
as
begin  
 declare @result int  
 exec @result = PPS_CRMADDIN_WEBEMP_RCVNCRMWEBEMP @SRC,@ID,@ErrMsg
 return @result  
end 
GO
