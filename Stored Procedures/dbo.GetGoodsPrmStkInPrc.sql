SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsPrmStkInPrc](
	@vdrgid	int,
	@storegid	int,
	@gdgid	int,
	@prminprc	money	output
)
with encryption as
begin
	select @prminprc = 0

	select @prminprc = price
	from inprice(nolock)
	where vdrgid = @vdrgid
		and storegid = @storegid
		and gdgid = @gdgid
		and astart < getdate()
		and afinish > getdate()

	if @@rowcount = 0
	begin
		select @prminprc = price
		from inprice(nolock)
		where vdrgid = 0
			and storegid = @storegid
			and gdgid = @gdgid
			and astart < getdate()
			and afinish > getdate()
	end

	return (0)
end
GO
