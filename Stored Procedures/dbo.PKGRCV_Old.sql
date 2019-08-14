SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PKGRCV_Old](
    @p_src int,
    @p_id int,
    @p_frcupd smallint
) with encryption as
begin
    declare
    @ret_status int,
    @n_pgid int,
    @n_egid int,
    @n_frcupd smallint,
    @n_type smallint,
    @l_pgid int,
    @l_egid int

    select @ret_status = 0
    select
        @n_pgid = PGid, @n_egid = EGid, @n_frcupd = FrcUpd,
        @n_type = Type
        from NPKG
        where Src = @p_src and Id = @p_id
    if @n_type <> 1
    begin
        raiserror('不是可接收包装规格', 16, 1)
        return(1)
    end

    select @l_pgid = LGid
        from GDXLATE
        where NGid = @n_pgid
    if @@RowCount < 1
    begin               --大包装商品本地不存在
        raiserror('大包装商品本地不存在。', 16, 1)
        return(1)
    end
    if (select IsPkg from GOODS where Gid = @l_pgid) <> 1
    begin               --本地商品不是大包装商品
        raiserror('本地商品不是大包装商品。', 16, 1)
        return(1)
    end
    select @l_egid = LGid
        from GDXLATE
        where NGid = @n_egid
    if @@RowCount < 1
    begin               --基本商品本地不存在
        raiserror('基本商品本地不存在。', 16, 1)
        return(1)
    end

    select EGid
        from PKG
        where PGid = @l_pgid
    if @@RowCount > 0
    begin               --覆盖本地记录
        if @n_frcupd = 1 or @p_frcupd = 1
            update PKG
                set EGid = N.EGid, Qty = N.Qty
                from PKG C, NPKG N
                where C.PGid = @l_pgid and
                    N.Src = @p_src and
                    N.Id = @p_id
    end
    else                --插入本地记录
        insert into PKG(
            PGid, EGid, Qty)
            select PGid, EGid, Qty
            from NPKG
            where Src = @p_src and Id = @p_id
    delete from NPKG
        where Src = @p_src and Id = @p_id
    return(@ret_status)
end
GO
