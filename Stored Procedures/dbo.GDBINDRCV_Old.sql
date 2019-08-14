SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GDBINDRCV_Old](
    @p_src int,
    @p_id int,
    @p_frcupd smallint
) with encryption as
begin
    declare
    @ret_status int,
    @n_bindgid int,
    @n_egid int,
    @n_frcupd smallint,
    @n_type smallint,
    @l_bindgid int,
    @l_egid int

    select @ret_status = 0
    select
        @n_bindgid = BindGid, @n_egid = EGid, @n_frcupd = FrcUpd,
        @n_type = Type
        from NGDBIND
        where Src = @p_src and Id = @p_id
    if @n_type <> 1
    begin
        raiserror('不是可接收捆绑关系', 16, 1)
        return(1)
    end

    select @l_bindgid = LGid
        from GDXLATE
        where NGid = @n_bindgid
    if @@RowCount < 1
    begin               --捆绑后商品本地不存在
        raiserror('捆绑后商品本地不存在。', 16, 1)
        return(1)
    end
    if (select IsBIND from GOODS where Gid = @l_bindgid) <> 1
    begin               --本地商品不是捆绑后商品
        raiserror('本地商品不是捆绑后商品。', 16, 1)
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
        from GDBIND
        where BindGid = @l_bindgid and eGid = @l_egid
    if @@RowCount > 0
    begin               --覆盖本地记录
        if @n_frcupd = 1 or @p_frcupd = 1
            update GDBIND
                set Qty = N.Qty
                from GDBIND C, NGDBIND N
                where C.BindGid = @l_bindgid and C.eGid = @l_egid and
                    N.Src = @p_src and
                    N.Id = @p_id
    end
    else                --插入本地记录
        insert into GDBIND(
            BindGid, EGid, Qty)
            select BindGid, EGid, Qty
            from NGDBIND
            where Src = @p_src and Id = @p_id
    delete from NGDBIND
        where Src = @p_src and Id = @p_id
    return(@ret_status)
end
GO
