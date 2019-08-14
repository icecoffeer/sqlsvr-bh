SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[xfchk_deliver]
	@num char(10)
as
begin
	declare
		@ret int,
		@fromwrh int, @gdgid int, @qty money, @fromsubwrh int
	select	@FROMWRH=FROMWRH
	from XF
	where NUM=@num
	declare c_xf cursor for
		select	GDGID, QTY, FROMSUBWRH
		from XFDTL
		where NUM = @num
		for update
	open c_xf
	fetch next from c_xf into @gdgid, @qty, @fromsubwrh
	while @@fetch_status=0
	begin
		execute @ret=decdspqty @fromwrh, @gdgid, @qty, @fromsubwrh
		if @ret<>0 break
		fetch next from c_xf into @gdgid, @qty, @fromsubwrh
	end
	close c_xf
	deallocate c_xf
	return(@ret)
end
GO
