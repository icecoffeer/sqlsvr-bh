SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

create procedure [dbo].[AutoGoodsRcv]
	@SRC int,
	@ID int,
	@ErrMsg varchar(200) output
as
begin
	declare @result int
	declare @hd_option int
	select @hd_option=optionvalue from hdoption(nolock) where optioncaption='RcvGdInputType' and moduleno=10 
	exec @result = GoodsRcv @SRC, @ID,1,@hd_option	
	return @result
end
GO
