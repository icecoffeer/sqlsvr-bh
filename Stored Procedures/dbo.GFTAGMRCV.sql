SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GFTAGMRCV](
	@p_src int,
	@p_id int,
    @p_checker int
)as
begin
	declare
		@p_rcv int,
		@p_type	int,
		@n_frcchk int,
		@n_num char(10),
		@n_vendor int,
		@l_num char(10),
		@l_oldnum char(10),
		@l_oldstat int,
		@l_filler int,
		@l_settleno int,
		@p_cnt int,
		@p_usergid int,
		@n_filler int,
		@n_checker int,
		@err int,
		@l_old_filler int,/*2003.03.18*/
		@l_old_checker int,
		@GFTWRH int
		
	select
		@p_rcv	= RCV,
		@p_id	= ID,
		@p_type	= TYPE,
		@n_vendor = VENDOR,
		@n_filler = FILLER,
		@n_checker = CHECKER
	from NGFTAGM(nolock) where SRC = @p_src and ID = @p_id
	
	if @@rowcount < 1
    begin
        raiserror('未找到指定赠品协议', 16, 1)
        return(2)
    end

    if @p_type <> 1
    begin
        raiserror('不是可接收赠品协议', 16, 1)
        return(3)
    end

	select @l_old_filler = LGID from EMPXLATE(nolock) where NGID = @n_filler/*2003.03.18*/
	if not exists(select 1 from EMPLOYEEH where GID = @l_old_filler)
	begin
        raiserror('本地未包含此赠品协议中的填单人资料', 16, 1)
        return(4)
	end
	
	select @l_old_checker = LGID from EMPXLATE(nolock) where NGID = @n_checker/*2003.03.18*/
	if not exists(select 1 from EMPLOYEEH where GID = @l_old_checker)
	begin
        raiserror('本地未包含此赠品协议中的审核人资料', 16, 1)
        return(5)
	end
	
    select @l_filler = GID from EMPLOYEEH where GID = @p_checker
    if @@rowcount <> 1
    begin
        raiserror('本地未包含审核人资料', 16, 1)
        return(6)
    end

    if exists(select 1 from NGFTAGMDTL where GDGID not in (select GID from GOODSH)
    	and SRC = @p_src and ID = @p_id)
    begin
        raiserror('本地未包含此赠品协议中的商品资料', 16, 1)
        return(7)
    end

    if exists(select 1 from NGFTAGMDTL where GFTGID not in (select GID from GOODSH)
    	and SRC = @p_src and ID = @p_id)
    begin
        raiserror('本地未包含此赠品协议中的赠品资料', 16, 1)
        return(8)
    end

	if not exists(select 1 from VENDORH(nolock) where GID = @n_VENDOR)
	begin
        raiserror('本地未包含此赠品协议中的供应商资料', 16, 1)
        return(9)
	end
	
	select @p_usergid = USERGID from SYSTEM(nolock)
	    
    if @p_src = @p_usergid
    begin
       raiserror('来源单位是本单位，不必接收',16,1)
       return(10)
    end
    
    if @p_rcv <> @p_usergid
    begin
       raiserror('该单据的接收单位不是本单位',16,1)
       return(11)
    end

	select @n_num = NUM, @n_frcchk = FRCCHK
	from NGFTAGM(nolock) where SRC = @p_src and ID = @p_id
	
	select @l_num = max(NUM) from GFTAGM(nolock)
	if @l_num is null
		set @l_num = '0000000001'
	else
		execute NEXTBN @l_num, @l_num output
	
	select @l_settleno = max(NO) from MONTHSETTLE(nolock)

	if exists(select 1 from GFTAGM(nolock) where SRC = @p_src and SRCNUM = @n_num)
	begin
		select @l_oldnum = NUM, @l_oldstat = STAT
		from GFTAGM(nolock) where SRC = @p_src and SRCNUM = @n_num

		if @l_oldstat = 0
		begin
			delete from GFTAGM where num = @l_oldnum
			delete from GFTAGMDTL where num = @l_oldnum
			delete from GFTAGMLACDTL where num = @l_oldnum
		
			insert into GFTAGMDTL(NUM, LINE, SETTLENO, START, FINISH, GDGID, INQTY,
				GFTGID, GFTQTY, GFTLINE, STAT, LSTID, GFTWRH)
			select @l_oldnum, n.LINE, @l_settleno, n.START, n.FINISH, n.GDGID, n.INQTY,
				n.GFTGID, n.GFTQTY, n.GFTLINE, n.STAT, n.LSTID, n.GFTWRH
			from NGFTAGMDTL n(nolock)
			where n.SRC = @p_src and n.ID = @p_id
	
			insert into GFTAGM(NUM, SETTLENO, VENDOR, FILDATE, FILLER, CHECKER, STAT,
				NOTE, RECCNT, SRC, SRCNUM, SNDTIME, EON)
			select @l_oldnum, @l_settleno, VENDOR, FILDATE, @l_filler/*2003.03.18*/, @p_checker,
				0, NOTE, RECCNT, SRC, NUM, SNDTIME, 1
			from NGFTAGM(nolock) where SRC = @p_src and ID = @p_id

			if @n_frcchk = 1
			begin
				execute @err = GFTAGMCHK @l_oldnum, @l_filler
				if @err <> 0 return 1
				execute @err = GFTAGMABOLISH @l_oldnum
				if @err <> 0 return 2
			end
		end else begin
			if exists(select 1 from GFTAGMDTL(nolock) where STAT = 0
				and LSTID in (select LSTID from NGFTAGMDTL where STAT = 1
				and SRC = @p_src and ID = @p_id))
			begin
				update GFTAGMDTL set STAT = 1 where LSTID in
					(select LSTID from NGFTAGMDTL where STAT = 1
					and SRC = @p_src and ID = @p_id)
				execute GFTAGMABOLISH @l_oldnum
			end
		end
	end else begin
		if not exists(select 1 from hdoption where optioncaption = 'USESTOREGFTWRH' and moduleno = 448 and optionvalue = '1')
		  insert into GFTAGMDTL(NUM, LINE, SETTLENO, START, FINISH, GDGID, INQTY,
			  GFTGID, GFTQTY, GFTLINE, STAT, LSTID, GFTWRH)
		  select @l_num, n.LINE, @l_settleno, n.START, n.FINISH, n.GDGID, n.INQTY,
			  n.GFTGID, n.GFTQTY, n.GFTLINE, n.STAT, n.LSTID, n.GFTWRH
		  from NGFTAGMDTL n(nolock)
		  where n.SRC = @p_src and n.ID = @p_id
		else
		begin
		  select @GFTWRH = a.gid from warehouse a(nolock), hdoption b(nolock) where a.code = b.optionvalue 
		    and b.optioncaption = 'DEFGFTWRH' and b.moduleno = 448
		  insert into GFTAGMDTL(NUM, LINE, SETTLENO, START, FINISH, GDGID, INQTY,
			  GFTGID, GFTQTY, GFTLINE, STAT, LSTID, GFTWRH)
		  select @l_num, n.LINE, @l_settleno, n.START, n.FINISH, n.GDGID, n.INQTY,
			  n.GFTGID, n.GFTQTY, n.GFTLINE, n.STAT, n.LSTID, @GFTWRH
		  from NGFTAGMDTL n(nolock)
		  where n.SRC = @p_src and n.ID = @p_id
		end
	
		insert into GFTAGM(NUM, SETTLENO, VENDOR, FILDATE, FILLER, CHECKER, STAT,
			NOTE, RECCNT, SRC, SRCNUM, SNDTIME, EON)
		select @l_num, @l_settleno, VENDOR, FILDATE, @l_filler, @p_checker,
			0, NOTE, RECCNT, SRC, NUM, SNDTIME, 1
		from NGFTAGM(nolock) where SRC = @p_src and ID = @p_id
		
		if @n_frcchk = 1
		begin
			execute @err = GFTAGMCHK @l_num, @l_filler
			if @err <> 0 return 1
			execute @err = GFTAGMABOLISH @l_num
			if @err <> 0 return 2
		end
	end
	
	delete from NGFTAGMDTL where SRC = @p_src and ID = @p_id
	delete from NGFTAGM where SRC = @p_src and ID = @p_id

	return (0)
end
GO
