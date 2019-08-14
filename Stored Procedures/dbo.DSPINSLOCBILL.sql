SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS OFF
GO

create procedure [dbo].[DSPINSLOCBILL](
	@src_gid int,
	@id int,
	@new_oper int,
	@neg_num char(10) output
)as
begin
	declare
		@max_num char(10),
		@src_filler int,
		@src_opener int,
		@new_filler int,
		@new_opener int,
		@cur_settleno int,
		@src_fildate datetime,
		@src_num char(10),
		@src_cls char(10),
                @src_posnocls char(10),
                @src_flowno char(12),

		@line int,
		@gdgid int,
		@local_gdgid int,
		@qty money,
		@price money,
		@total money,
		@tax money,
		@saleline int,
		@new_gdgid int,
		@saleprice money,
		@saleqty money,
		@saletotal money, 
		@note varchar(100)               
	select
		@src_fildate = FILDATE,
		@src_filler = FILLER,
		@src_opener = OPENER,
		@src_num = NUM,
                @src_cls = CLS,
                @src_posnocls = POSNOCLS,
                @src_flowno = FLOWNO
	from NDSP where ID = @id and SRC = @src_gid

	select @cur_settleno = max(NO) from MONTHSETTLE

	select @max_num = (select max(NUM) from DSP)
	if @max_num is null
		select @neg_num = '0000000001'
	else
		execute NEXTBN @max_num, @neg_num output

	select @new_filler = (select LGID from EMPXLATE where NGID = @src_filler)
	select @new_opener = (select LGID from EMPXLATE where NGID = @src_opener)

	if (@new_filler is null) or (@new_opener is null)
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1)
		return(1)
	end

	insert into DSP(NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER,
        		OPENER, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO, STAT,
                        SRC, SRCNUM, SNDTIME)
        select @neg_num, 1, INVNUM, CREATETIME, TOTAL, RECCNT, @new_filler,
        	@new_oper, CLS, POSNOCLS, FLOWNO, NOTE, @cur_settleno, STAT,
                @src_gid, NUM, SNDTIME
        from NDSP
	where ID = @id and SRC = @src_gid


	declare c cursor for
		select LINE, SALELINE, GDGID, SALEPRICE, SALEQTY, SALETOTAL, NOTE
		from NDSPDTL
                where ID = @id and SRC = @src_gid
	open c
	fetch next from c into
		@line, @saleline, @gdgid, @saleprice, @saleqty, @saletotal, @note
        while @@fetch_status = 0
	begin
		select @new_gdgid = (select LGID from GDXLATE where NGID = @gdgid)
		if @new_gdgid is null
		begin
			close c
			deallocate c
			raiserror('本单位没有此单据中的商品资料', 16, 1)
			return(2)
		end

		insert into DSPDTL(NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY, SALETOTAL, NOTE)
		values(@neg_num, @line, @saleline, @new_gdgid, @saleprice, @saleqty, @saletotal, @note)

		fetch next from c into
			@line, @saleline, @gdgid, @saleprice, @saleqty, @saletotal, @note
	end
	close c
	deallocate c

 	delete from NDSPDTL
        where ID = @id and SRC = @src_gid

        delete from NDSP
	where ID = @id and SRC = @src_gid	

	return(0)
end

GO
