SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  更改商品 @gdgid @vdrgid 的WRH为 @wrh
  如果 @oldwrh=商品的默认仓位,则修改商品的默认仓位
*/
create procedure [dbo].[GdChgWrhBasic]
  @gdgid int,
  @oldwrh int,
  @wrh int
as
begin
	if @oldwrh = @wrh
        	return (0)

        declare @vdrgid int

	--if (select WRH from GOODS where GID = @gdgid) = @oldwrh

	update GOODS set WRH = @wrh where GID = @gdgid

	--if not exists(select * from VDRGD
	--	where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
	--	insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
	--update VDRGD set WRH = @wrh
	--where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @oldwrh

        declare c_vdrgd cursor for
		select VDRGID
		from VDRGD
		where GDGID = @gdgid and wrh = @oldwrh
	open c_vdrgd
	fetch next from c_vdrgd into
		@vdrgid
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD
			where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
		fetch next from c_vdrgd into
			@vdrgid
	end
	close c_vdrgd
	deallocate c_vdrgd
end
GO
