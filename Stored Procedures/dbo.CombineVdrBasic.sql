SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

/*
  增加商品 @gdgid 在 VDRGD 中 @oldgdgid 的 相应记录
*/
create procedure [dbo].[CombineVdrBasic]
  @oldvdrgid int,
  @vdrgid int
as
begin
	if @oldvdrgid = @vdrgid
        	return (0)

        declare @gdgid int, @wrh int

	update GOODS set BILLTO = @vdrgid where BILLTO = @oldvdrgid
	--delete from VENDOR where GID = @oldvdrgid

        declare c_vdrgd cursor for
		select GDGID, WRH
		from VDRGD
		where vdrgid = @oldvdrgid
	open c_vdrgd
	fetch next from c_vdrgd into
		@gdgid, @wrh
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD
			where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
		fetch next from c_vdrgd into
			@gdgid, @wrh
	end        
	close c_vdrgd
	deallocate c_vdrgd
        if (not exists(select * from V_VDRYRPT where BVDRGID = @oldvdrgid))
        	delete from VENDOR where GID = @oldvdrgid
end

GO
