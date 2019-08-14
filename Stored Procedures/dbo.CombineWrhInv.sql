SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CombineWrhInv]
  @oldwrh int,
  @wrh int
as
begin
	if @oldwrh = @wrh
        	return(0)
                
	--//不允许@wrh和@wrh的到效期
	--//管理方式不同
	declare @gdgid int, @wrhchkvd int, @goodschkvd int, @validdate datetime,
		@qty money, @total money, @ordqty money, @store int

	
	if (select CHKVD from WAREHOUSE where gid = @oldwrh) <>
		(select CHKVD from WAREHOUSE where gid = @wrh)
	begin
		raiserror('原仓位和新仓位的到效期管理方式不同', 16, 1)
		return(1)
	end
	
	select @store = (select USERGID from SYSTEM)
	select @wrhchkvd = (select CHKVD from WAREHOUSE where GID = @oldwrh)
	
	declare c_inv cursor for
		select GDGID, QTY, TOTAL, ORDQTY, VALIDDATE 
		from INV
		where WRH = @oldwrh and STORE = @store
	open c_inv
	fetch next from c_inv into 
		@gdgid, @qty, @total, @ordqty, @validdate
	while @@fetch_status = 0
	begin
		select @goodschkvd = (select CHKVD from GOODS where GID = @gdgid)
		if @goodschkvd = 0 or @wrhchkvd = 0 
		begin
			if exists (select * from INV 
				where GDGID = @gdgid and WRH = @wrh and STORE = @store)
			begin
				update INV set QTY = QTY + @qty, 
						TOTAL = TOTAL + @total,
						ORDQTY = ORDQTY + @ordqty
				where GDGID = @gdgid and WRH = @wrh 
					and STORE = @store

				delete from INV
				where GDGID = @gdgid and WRH = @oldwrh
					and STORE = @store
			end
			else
				update INV set WRH = @wrh
				where GDGID = @gdgid and WRH = @oldwrh
					and STORE = @store
		end
		else
		begin
			if exists (select * from INV 
				where GDGID = @gdgid and WRH = @wrh
				and VALIDDATE = @validdate
				and STORE = @store)
			begin
				update INV set QTY = QTY + @qty, 
						TOTAL = TOTAL + @total,
						ORDQTY = ORDQTY + @ordqty
				where GDGID = @gdgid and WRH = @wrh
				and VALIDDATE = @validdate
				and STORE = @store

				delete from INV
				where GDGID = @gdgid and WRH = @oldwrh
				and VALIDDATE = @validdate
				and STORE = @store
			end
			else
				update INV set WRH = @wrh
				where GDGID = @gdgid and WRH = @oldwrh
				and VALIDDATE = @validdate
				and STORE = @store
		end
		fetch next from c_inv into
			@gdgid, @qty, @total, @ordqty, @validdate
	end
	close c_inv
	deallocate c_inv
end
GO
