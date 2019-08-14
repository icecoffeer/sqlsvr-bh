SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[ORDDELNETBILL](
	@src_gid int,
	@id int
) as
begin
	declare
		@src_stat smallint,
		@src_modnum char(10),
		@temp_id int

	select
		@src_stat = STAT,
		@src_modnum = MODNUM
	from NORDER where ID = @id and SRC = @src_gid

	delete from NORDERDTL where ID = @id and SRC = @src_gid
	delete from NORDER where ID = @id and SRC = @src_gid
	if @src_stat = 1		
		while exists (select * from NORDER
			where SRC = @src_gid and NUM = @src_modnum and STAT = 2)
		begin
			select @temp_id = (select max(ID) from NORDER
				where SRC = @src_gid and NUM = @src_modnum and STAT = 2)

			select @src_modnum = MODNUM, @temp_id = ID from NORDER
				where ID = @temp_id and SRC = @src_gid
 				--SRC = @src_gid and NUM = @src_modnum and STAT = 2

			delete from NORDERDTL where ID = @temp_id and SRC = @src_gid
			delete from NORDER where ID = @temp_id and SRC = @src_gid
		end
end

GO
