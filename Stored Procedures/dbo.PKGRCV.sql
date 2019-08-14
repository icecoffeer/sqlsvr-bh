SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PKGRCV](
	@p_teamid	int,
	@p_n_pgid int
) with encryption as
begin
    declare
    @egid int,
	@qty	money,
    @n_frcupd smallint,
    @n_type smallint,
    @l_pgid int,
    @l_egid int

    select
        @n_frcupd = FrcUpd
    from NPKG
    where TEAMID = @p_teamid

    select @l_pgid = LGid
        from GDXLATE
    where NGid = @p_n_pgid
   
    if @n_frcupd is null	--NPKG中无此大包装商品，则删除本地大小包装关系2003.04.22
    begin
		delete from PKG where PGID = @l_pgid
		return 0
	end

    if @l_pgid is null	--大包装商品本地不存在
    begin               
        raiserror('大包装商品本地不存在。', 16, 1)
        return(1)
    end
    if (select IsPkg from GOODS where Gid = @l_pgid) <> 1
    begin               --本地商品不是大包装商品
        raiserror('本地商品不是大包装商品。', 16, 1)
        return(1)
    end


 	delete from PKG where PGID = @l_pgid

	declare c_pkg cursor for
	select egid, qty from NPKG
		where TEAMID = @p_teamid
		order by ID 
	for read only
	open c_pkg
	fetch next from c_pkg into @egid, @qty
	while @@fetch_status = 0
	begin
		select @l_egid = LGID from GDXLATE where NGID = @egid
		if @@rowcount = 0
		begin
			close c_pkg
			deallocate c_pkg
			raiserror('大包装基本商品本地不存在。', 16, 1)
			return 1
		end
		
		insert into PKG(PGID, EGID, QTY)
		values(@l_pgid, @l_egid, @qty)
		
		fetch next from c_pkg into @egid, @qty
	end
	close c_pkg
	deallocate c_pkg
	
	return 0
end
GO
