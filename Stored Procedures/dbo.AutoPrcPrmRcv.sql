SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------自动接收网络促销单-----------------------------------------------------------
create procedure [dbo].[AutoPrcPrmRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
	declare @result int
	exec @result = PrcPrmRcv @SRC, @ID,1
	return @result
end
GO
