SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoBCKNOTIFYRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(255) output
as
begin
	declare @result int
	exec @ErrMsg  = RECEIVEBCKNOTIFY @ID,@SRC, '1',@ErrMsg output
	return @result
	
end
GO
