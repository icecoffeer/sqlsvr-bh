SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[DSPREGINSLOCBILL](
	@src_gid int,
	@id int,
	@new_emp int,
	@neg_num char(10) output
)as
begin
	declare
		@max_num char(10),
		@src_filler int,
		@src_acpemp int,
                @src_oper int,
		@new_filler int,
		@new_acpemp int,
                @new_oper int,
		@cur_settleno int,
		@src_num char(10),
                @src_dspnum char(10),

		@line smallint,
		@dspline int,
		@gdgid int,
		@new_gdgid int,
		@avaqty int,
		@qty money,
		@note varchar(100),
                @alldspqty money,
                @allsaleqty money
	select
		@src_filler = FILLER,
		@src_acpemp = acpemp,
                @src_oper = OPER,
		@src_num = NUM,
                @src_dspnum = DSPNUM
	from NDSPREG where ID = @id and SRC = @src_gid

	select @cur_settleno = max(NO) from MONTHSETTLE

	select @max_num = (select max(NUM) from DSPREG)
	if @max_num is null
		select @neg_num = '0000000001'
	else
		execute NEXTBN @max_num, @neg_num output

	select @new_filler = (select LGID from EMPXLATE where NGID = @src_filler)
	select @new_acpemp = (select LGID from EMPXLATE where NGID = @src_acpemp)
        select @new_oper = (select LGID from EMPXLATE where NGID = @src_oper)

	if (@new_filler is null) or (@new_acpemp is null) or (@new_oper is null)
	begin
		raiserror('本单位没有此单据中的员工资料', 16, 1)
		return(1)
	end

	insert into DSPREG(NUM, SETTLENO, FILDATE, FILLER, WRH, INVNUM,
			ACPTIME, ACPEMP, OPER, RECCNT, DSPNUM, NOTE,
                        SRC, SRCNUM, SNDTIME)
        select @neg_num, @cur_settleno, FILDATE, @new_filler, 1, INVNUM,
        	ACPTIME, @new_acpemp, @new_oper, RECCNT, DSPNUM, NOTE,
        	@src_gid, NUM, SNDTIME
        from NDSPREG
	where ID = @id and SRC = @src_gid


	declare c cursor for
		select LINE, DSPLINE, GDGID, AVAQTY, QTY, NOTE
		from NDSPREGDTL
                where ID = @id and SRC = @src_gid
	open c
	fetch next from c into
		@line, @dspline, @gdgid, @avaqty, @qty, @note
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

		insert into DSPREGDTL(NUM, LINE, SETTLENO, DSPLINE, GDGID,
				AVAQTY, QTY, SUBWRH, NOTE, INVQTY, SUBQTY)
		values(@neg_num, @line, @cur_settleno, @dspline, @new_gdgid,
                		@avaqty, @qty, null, @note, 0, 0)

		update DSPDTL set DSPQTY = DSPQTY + @qty,
                		DSPTOTAL = DSPTOTAL + SALEPRICE * @qty
                from DSP
                where DSP.NUM = DSPDTL.NUM
                and DSP.SRCNUM = @src_dspnum and SRC = @src_gid and LINE = @dspline

		fetch next from c into
			@line, @dspline, @gdgid, @avaqty, @qty, @note
	end
	close c
	deallocate c

        delete from NDSPREGDTL
        where ID = @id and SRC = @src_gid

	delete from NDSPREG
	where ID = @id and SRC = @src_gid

        select @allsaleqty = sum(a.SALEQTY), @alldspqty = sum(a.DSPQTY)
	from DSPDTL a, DSP b
	where a.NUM = b.NUM
        and b.SRCNUM = @src_dspnum and b.SRC = @src_gid

        if @alldspqty > 0
	begin
		if @allsaleqty > @alldspqty
			update DSP set STAT = 1
			where SRCNUM = @src_dspnum and SRC = @src_gid
		else if @allsaleqty = @alldspqty
			update DSP set STAT = 2
			where SRCNUM = @src_dspnum and SRC = @src_gid
	end

	return(0)
end
GO
