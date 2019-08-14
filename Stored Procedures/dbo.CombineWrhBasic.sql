SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  增加商品 @gdgid 在 VDRGD 中 @oldgdgid 的 相应记录
*/
create procedure [dbo].[CombineWrhBasic]
  @oldwrh int,
  @wrh int
as
begin
	if @oldwrh = @wrh
        	return (0)

        declare @gdgid int, @vdrgid int

	update GOODS set WRH = @wrh where WRH = @oldwrh
	--delete from VENDOR where GID = @oldvdrgid

	declare c_vdrgd cursor for
		select GDGID, VDRGID
		from VDRGD
		where wrh = @oldwrh
	open c_vdrgd
	fetch next from c_vdrgd into
		@gdgid, @vdrgid
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD
			where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
		fetch next from c_vdrgd into
			@gdgid, @vdrgid
	end
	close c_vdrgd
	deallocate c_vdrgd
        if (not exists (select * from V_VDRYRPT where BWRH = @oldwrh)) and
        (not exists (select * from V_CSTYRPT where BWRH = @oldwrh))
        	delete from WAREHOUSE where GID = @oldwrh        
end
GO
