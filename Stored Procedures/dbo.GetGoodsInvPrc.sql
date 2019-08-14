SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsInvPrc](
	@gdgid	int,
	@wrh	int,
	@invprc	money	output
)
with encryption as
begin
	declare
		@value	int

	select @invprc = invprc from gdwrh(nolock)
	where gdgid = @gdgid and wrh = @wrh
	if @@rowcount = 0
	begin
		exec OptReadInt 0, 'InitInvPrc', 1, @value output
		if @value = 1
			select @invprc = cntinprc from goods where gid = @gdgid
		else
			select @invprc = 0
	end

	return (0)
end
GO
