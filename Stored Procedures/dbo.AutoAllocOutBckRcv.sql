SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoAllocOutBckRcv]  
@SRC int,  
@ID int,  
@ErrMsg varchar(200) output  
as  
begin  
 declare @result int  
 exec @result = ReceiveStkinBck @ID,@SRC, 1  
 return @result  
end  
GO
