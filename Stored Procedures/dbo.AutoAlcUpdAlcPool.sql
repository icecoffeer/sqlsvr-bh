SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AutoAlcUpdAlcPool](
	@storegid int,
	@gdgid int,
	@qty money,
	@dmddate	datetime
)
as
begin
	declare @maxline int
	delete from alcpool
	where storegid = @storegid
		and gdgid = @gdgid
		and srcgrp = 3
	select @maxline = max(line)
	from alcpool(nolock)
	where storegid = @storegid
		and gdgid = @gdgid
	if @maxline is null
		set @maxline = 1
	else
		set @maxline = @maxline + 1
	insert into alcpool(storegid, gdgid, line, qty, dmddate, srcgrp, srcbill, ordtime)
	values(@storegid, @gdgid, @maxline, @qty, @dmddate, 3, '自动配货', getdate())
end
GO
