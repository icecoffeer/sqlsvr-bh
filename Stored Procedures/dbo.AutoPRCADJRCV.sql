SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
------------------------自动接收网络价格调整单---------------------------------------------------
create procedure [dbo].[AutoPRCADJRCV]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
	declare @result int
	exec @result = PRCADJRCV @SRC, @ID,1
	return @result
end
GO
