SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------自动接收网络供应商------------------------------------------------------------
create procedure [dbo].[AutoVdrRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
	declare @result int
	exec @result = VdrRcv @SRC, @ID,1	
	return @result
end
GO
