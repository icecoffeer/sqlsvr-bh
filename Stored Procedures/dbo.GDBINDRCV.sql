SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GDBINDRCV](
	@p_teamid	int,
	@p_n_bindgid int
) with encryption as
begin
    declare
    @egid int,
    @qty money,
    @n_frcupd smallint,
    @n_type smallint,
    @l_bindgid int,
    @l_egid int

    select
        @n_frcupd = FrcUpd
    from NGDBIND
    where TEAMID = @p_teamid
    
    select @l_bindgid = LGid
        from GDXLATE
    where NGid = @p_n_bindgid
    
    if @n_frcupd is null/*2003.04.22*/
    begin
    	delete from GDBIND where BINDGID = @l_bindgid
    	return 0
    end

    if @l_bindgid is null
    begin
        raiserror('捆绑后商品本地不存在。', 16, 1)
        return(1)
    end
    
    if (select IsBIND from GOODS where Gid = @l_bindgid) <> 1
    begin
        raiserror('本地商品不是捆绑后商品。', 16, 1)
        return(1)
    end
    
	delete from GDBIND where BINDGID = @l_bindgid

	declare c_gdbind cursor for
	select egid, qty from NGDBIND
		where TEAMID = @p_teamid
		order by ID 
	for read only
	open c_gdbind
	fetch next from c_gdbind into @egid, @qty
	while @@fetch_status = 0
	begin
		select @l_egid = LGID from GDXLATE where NGID = @egid
		if @@rowcount = 0
		begin
			close c_gdbind
			deallocate c_gdbind
			raiserror('捆绑后商品本地不存在。', 16, 1)
			return 1
		end
		
		insert into GDBIND(bindgid, egid, qty)
		values(@l_bindgid, @l_egid, @qty)
		
		fetch next from c_gdbind into @egid, @qty
	end
	close c_gdbind
	deallocate c_gdbind
	
    return 0
end
GO
