SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO


create procedure [dbo].[CLRINVCHK](
	@num char(10)
) as 
begin
	declare @gdgid int, @wrh int, 
	@validdate datetime, @store int
	if not exists(select * from CLRINV where num = @num) 
	begin
		raiserror('%s 号单据不存在', 16, 1, @num)
		return(1)
	end
	select @store = USERGID from SYSTEM
	select @validdate = null
	declare c_clrinv cursor for
		select GDGID, WRH, VALIDDATE
		from CLRINVDTL
		where CLRINVDTL.NUM = @num
	open c_clrinv
	fetch next from c_clrinv into 
		@gdgid, @wrh, @validdate
	while @@fetch_status = 0 
	begin
		if @validdate is null 
			delete from INV  
			where GDGID = @gdgid
				and WRH = @wrh
				and STORE = @store
		else
			delete from INV  
			where GDGID = @gdgid
				and WRH = @wrh
				and VALIDDATE = @validdate
				and STORE = @store
		fetch next from c_clrinv into 
			@gdgid, @wrh, @validdate
	end	
	close c_clrinv
	deallocate c_clrinv
end	

GO
