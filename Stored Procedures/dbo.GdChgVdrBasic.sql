SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
  更改商品 @gdgid 在 @wrh 的供应商为 @vdrgid
  如果 @oldvdrgid=商品的默认供应商,则修改商品的默认供应商
*/
create procedure [dbo].[GdChgVdrBasic]
  @gdgid int,
  @oldvdrgid int,
  @vdrgid int
as
begin
	if @oldvdrgid = @vdrgid
        	return (0)

        declare @wrh int
	
	--check can upd
	if exists(select 1 from goods(nolock) where (UpCtrl = 1 or HQControl = 1) and GID = @gdgid)  --2005.08.17 Fanduoyi
	begin
	  raiserror('商品是统一控制商品不能更改供应商', 16, 1)
	  return(1)
	end
	--if (select BILLTO from GOODS where GID = @gdgid) = @oldvdrgid
	
	
	update GOODS set BILLTO = @vdrgid, LSTUPDTIME = GETDATE() where GID = @gdgid  --2002-09-09 杨善平
	
	--if not exists(select * from VDRGD
	---	where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
	--	insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
	--else
	--	delete from VDRGD where VDRGID = @oldvdrgid and GDGID = @gdgid and WRH = @wrh

        declare c_vdrgd cursor for
		select WRH
		from VDRGD
		where GDGID = @gdgid and vdrgid = @oldvdrgid
	open c_vdrgd
	fetch next from c_vdrgd into
		@wrh
	while @@fetch_status = 0
	begin
		if not exists(select * from VDRGD
			where VDRGID = @vdrgid and GDGID = @gdgid and WRH = @wrh)
			insert into VDRGD(VDRGID, GDGID, WRH) values(@vdrgid, @gdgid, @wrh)
		fetch next from c_vdrgd into
			@wrh
	end
	close c_vdrgd
	deallocate c_vdrgd
end
GO
