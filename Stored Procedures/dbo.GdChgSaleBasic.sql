SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GdChgSaleBasic](
	@gid int,
	@oldsale int,
	@newsale int,
	@dxprc money,
	@payrate money
) as
begin
	if @oldsale = @newsale 
		return 0
	
	update goods set sale = @newsale where gid = @gid

	if @newsale = 2 
		update goods set dxprc = @dxprc where gid = @gid
	else if @newsale = 3
		update goods set payrate = @payrate where gid = @gid
	return 0
end
GO
