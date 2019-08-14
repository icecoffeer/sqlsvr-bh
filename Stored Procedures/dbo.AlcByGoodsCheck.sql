SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[AlcByGoodsCheck](
	@num varchar(10),
	@checker int
) as
begin
	declare 
	@stat int,
	@gdgid int,
	@storegid int,
	@line int,
	@qty money,
	@dmddate datetime
		
	if not exists(select 1 from ALCBYGOODS where NUM = @num)
	begin		
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end
	if not exists(select 1 from ALCBYGOODSDTL where NUM = @num)
	begin		
		raiserror('不存在要审核的单据', 16, 1)
		return(1)
	end
	
	select @stat = STAT, @gdgid = GDGID, @dmddate = dmddate from ALCBYGOODS where NUM = @num
	
	if not exists(select 1 from GOODS where GID = @gdgid)
	begin		
		raiserror('单据中的商品不存在', 16, 1)
		return(1)
	end	
	declare I_AlcByGoods cursor for
	select STOREGID, QTY, LINE from ALCBYGOODSDTL where NUM = @num
	open I_AlcByGoods
	fetch next from I_AlcByGoods into @storegid, @qty, @line
	while @@fetch_status = 0
	begin
		if not exists(select 1 from STORE where GID = @storegid)
		begin
			raiserror('单据中的店表不存在', 16, 1)
			return(1)	
		end
		exec PsrAlcUpdAlcPool @storegid, @gdgid, @qty, @dmddate, '采配按商品', @num, @line
		fetch next from I_AlcByGoods into @storegid, @qty, @line
	end
	close I_AlcByGoods
	deallocate I_AlcByGoods
	
	UPDATE ALCBYGOODS set STAT = 1, CHECKER = @checker, FILDATE = getdate() where NUM = @num 
	
	return 0
end
GO
