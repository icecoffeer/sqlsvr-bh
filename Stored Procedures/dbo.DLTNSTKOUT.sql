SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DLTNSTKOUT](
	@bill_id int,
	@src_id int
) as
begin
	declare @n_billid int, @n_modnum char(10), @n_cls char(10)
	
	set @n_billid = @bill_id
	select @n_modnum = MODNUM, @n_cls = CLS from NSTKOUT 
		where ID = @n_billid and SRC = @src_id
	while @n_billid is not null
	begin
		delete from NSTKOUT where ID = @n_billid and SRC = @src_id
		delete from NSTKOUTDTL where ID = @n_billid and SRC = @src_id
		select @n_billid = max(ID), @n_modnum = max(MODNUM) from NSTKOUT
			where SRC = @src_id and CLS = @n_cls and NUM = @n_modnum and STAT = 2
	end
end
GO
