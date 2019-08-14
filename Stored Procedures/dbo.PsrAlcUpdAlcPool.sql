SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PsrAlcUpdAlcPool](
	@storegid int,
	@gdgid int,
	@qty money,
	@dmddate datetime,
	@srcbill varchar(30),
	@srcnum varchar(10),
	@srcline int
)
as
begin
	declare @maxline int
	declare @cls char(10)
	select @maxline = max(line) from alcpool(nolock)
	where storegid = @storegid and gdgid = @gdgid
	if @maxline is null
		set @maxline = 1
	else
		set @maxline = @maxline + 1
	if @srcBill = '采配按门店'
	begin
	 	select @cls = cls from alcByStore(nolock) where num = @srcNum
     		if @Cls = '临时要货'
			insert into alcpool(storegid, gdgid, line, qty, dmddate,
				srcgrp, srcbill, srccls, srcnum, srcline, ordtime)
			values(@storegid, @gdgid, @maxline, @qty, @dmddate,
				2, @srcbill, @Cls, @srcnum, @srcline, getdate())
		else
			insert into alcpool(storegid, gdgid, line, qty, dmddate,
				srcgrp, srcbill, srccls, srcnum, srcline, ordtime)
			values(@storegid, @gdgid, @maxline, @qty, @dmddate,
				1, @srcbill, @Cls, @srcnum, @srcline, getdate())
	end
        else
		insert into alcpool(storegid, gdgid, line, qty, dmddate,
			srcgrp, srcbill, srccls, srcnum, srcline, ordtime)
		values(@storegid, @gdgid, @maxline, @qty, @dmddate,
			1, @srcbill, null, @srcnum, @srcline, getdate())
end
GO
