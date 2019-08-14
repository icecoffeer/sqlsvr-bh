SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GetGoodsOutIsLtd](
	@storegid	int,
	@gdgid	int,
	@isltd	int	output
)
as
begin
	declare @usergid int
	declare @isltd2 int

	select @isltd = isnull(isltd, 0) from goods(nolock)
	where gid = @gdgid
	select @usergid = usergid from system(nolock)
	if @usergid <> @storegid
	begin
		select @isltd2 = isnull(isltd, 0)
		from gdstore(nolock)
		where storegid = @storegid
			and gdgid = @gdgid
	end
	select @isltd2 = isnull(@isltd2, 0)
	select @isltd = @isltd | @isltd2

	return 0
end
GO
