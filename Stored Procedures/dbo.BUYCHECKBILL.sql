SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BUYCHECKBILL](
	@src_gid int,
	@id int 
) as 
begin
	declare
		@cashier1 int,
		@assistant1 int,
		@dealer1 int,
		@wrh1     int, 
		@new_cashier1 int,
		@new_assistant1 int,
		@new_dealer1 int,
		@assistant2 int,
		@dealer2 int,
		@wrh2     int,
		@gid	int,
		@itemno int,
		@qty money,
		@inprc money,
		@price money,
		@realamt money,
		@local_gid int  
	select
		@cashier1 = CASHIER,
		@assistant1 = ASSISTANT,
		@dealer1 = dealer,
		@wrh1 = WRH
	from NBUY1 where ID = @id and SRC = @src_gid 

	if (select 1 from WAREHOUSE where GID = @wrh1) is null
	begin
		raiserror('本单位没有此单据中的仓位资料', 16, 1);
		return(1)
	end	
	select @new_cashier1 = (select LGID from EMPXLATE where NGID = @cashier1)
	select @new_assistant1 = (select LGID from EMPXLATE where NGID = @assistant1)	
	if (@new_cashier1 is null) or (@new_assistant1 is null)
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1);
		return(2)
	end
	if @dealer1 is not null
	begin
		select @new_dealer1 = (select LGID from EMPXLATE where NGID = @dealer1)
		if @new_dealer1 is null
		begin
			raiserror('本单位没有此单据中的员工资料', 16, 1);
			return(2)
		end
	end

	declare c_goods cursor for
		select ITEMNO, GID, QTY, INPRC, PRICE, REALAMT, WRH, ASSISTANT, DEALER
		from NBUY2 where ID = @id and SRC = @src_gid 
	open c_goods
	fetch next from c_goods into
		@itemno, @gid, @qty, @inprc, @price, @realamt, @wrh2, @assistant2, @dealer2
	while @@fetch_status = 0
	begin	
		select @local_gid = (select LGID from GDXLATE where NGID = @gid)
		if @local_gid is null
		begin
			close c_goods
			deallocate c_goods
			raiserror('本单位没有门店零售单（商品明细）单据中的商品资料', 16, 1);
			return(3)
		end	
	fetch next from c_goods into
		@itemno, @gid, @qty, @inprc, @price, @realamt, @wrh2, @assistant2, @dealer2
	end
	close c_goods
	deallocate c_goods
	return(0) 
end
GO
