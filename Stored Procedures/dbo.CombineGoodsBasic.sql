SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  增加商品 @gdgid 在 VDRGD 中 @oldgdgid 的 相应记录
*/
create procedure [dbo].[CombineGoodsBasic]
  @oldgdgid int,
  @gdgid int
with encryption as
begin
	if @oldgdgid = @gdgid
        	return(0)

	declare @vdrgid int, @wrh int
        --select @wrh = WRH from GOODS where GID = @gdgid

	declare c_vdrgd cursor for
		select VDRGID, WRH
		from VDRGD
		where gdgid = @oldgdgid
	open c_vdrgd
	fetch next from c_vdrgd into
		@vdrgid, @wrh
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD
			where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
		fetch next from c_vdrgd into
			@vdrgid, @wrh
	end
	close c_vdrgd
	deallocate c_vdrgd
        
	--delete from GOODS where GID = @oldgdgid
end
GO
