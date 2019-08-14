SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------自动接收网络客户--------------------------------------------------------------
create procedure [dbo].[AutoClnRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
	declare @result int
	exec @result = ClnRcv @SRC, @ID,1	
	return @result
end
GO
