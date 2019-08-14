SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CombineGoodsInv]
  @oldgdgid int,
  @gdgid int
as
begin
	if @oldgdgid = @gdgid
        	return(0)
                
	--//不允许@oldgdgid和@gdgid的到效期
	--//管理方式不同
	declare @goodschkvd int, @wrh int, @wrhchkvd int, @validdate datetime, 
		@qty money, @total money, @ordqty money, @store int

	if (select SALE from GOODS where GID = @oldgdgid) <> 
		(select SALE from GOODS where GID = @gdgid)	
	begin
		raiserror('原商品和新商品的营销方式不同', 16, 1)
		return(1)
	end
	
	if (select CHKVD from GOODS where gid = @oldgdgid) <>
		(select CHKVD from GOODS where gid = @gdgid)
	begin
		raiserror('原商品和新商品的到效期管理方式不同', 16, 1)
		return(1)
	end
	
	select @store = (select USERGID from SYSTEM)
	select @goodschkvd = (select CHKVD from GOODS where GID = @oldgdgid)
	
	declare c_inv cursor for
		select WRH, QTY, TOTAL, ORDQTY, VALIDDATE 
		from INV
		where GDGID = @oldgdgid and STORE = @store
	open c_inv
	fetch next from c_inv into 
		@wrh, @qty, @total, @ordqty, @validdate
	while @@fetch_status = 0
	begin
		select @wrhchkvd = (select CHKVD from WAREHOUSE where GID = @wrh)
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
				where GDGID = @oldgdgid and WRH = @wrh
					and STORE = @store
			end
			else
				update INV set GDGID = @gdgid
				where GDGID = @oldgdgid and WRH = @wrh
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
				where GDGID = @oldgdgid and WRH = @wrh
				and VALIDDATE = @validdate
				and STORE = @store
			end
			else
				update INV set GDGID = @gdgid
				where GDGID = @oldgdgid and WRH = @wrh
				and VALIDDATE = @validdate
				and STORE = @store
		end
		fetch next from c_inv into 
			@wrh, @qty, @total, @ordqty, @validdate
	end
	close c_inv
	deallocate c_inv
end
GO
