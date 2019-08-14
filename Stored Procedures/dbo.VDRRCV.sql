SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRRCV](
    @p_src int,
    @p_id int,
    @p_frcupd smallint
) with encryption as
begin
    declare
    @ret_status int,
    @n_gid int,
    @n_code char(10),
    @n_frcupd smallint,
    @n_type smallint,
    @l_gid int

    select @ret_status = 0
    select
        @n_gid = Gid, @n_code = Code, @n_frcupd = FrcUpd,
        @n_type = Type
        from NVENDOR
        where Src = @p_src and Id = @p_id

    if @n_type <> 1
    begin
        raiserror('不是可接收供应商', 16, 1)
        return(1)
    end

    
    if not exists (select 1 from VENDOR, NVENDOR where VENDOR.GID = NVENDOR.MVDR and NVENDOR.GID = @n_gid) 
    begin
	raiserror('本地不存在预接收的主供应商，接收失败', 16, 1)
        return(1)              --2002-08-08 Jianweicheng
    end  
    
    select
        @l_gid = LGid
        from VDRXLATE
        where NGid = @n_gid
    if @@RowCount > 0
    begin
        if @p_frcupd = 1 or @n_frcupd = 1
            execute @ret_status = VDRRCVUPD @p_src, @p_id, @l_gid
        delete from NVENDOR
            where Src = @p_src and Id = @p_Id
        return(@ret_status)
    end
    if exists (select * from VENDORH where Gid = @n_gid)
    begin
        if not exists (select * from VENDOR where Gid = @n_gid)
        begin
            if exists (select * from VENDOR where Code = @n_code)
            begin
                raiserror('本地找到相同供应商，但与本地其它供应商代码重复。', 16, 1)
                select @ret_status = 1
            end else
            begin
                execute @ret_status = VDRRCVAPD @p_src, @p_id
                delete from NVENDOR
                    where Src = @p_src and Id = @p_Id
            end
        end
        else begin
            if @p_frcupd = 1 or @n_frcupd = 1
                execute @ret_status = VDRRCVUPD @p_src, @p_id, @n_gid
            delete from NVENDOR
                where Src = @p_src and Id = @p_Id
        end
    end
    else begin
        if exists (select * from VENDOR where Code = @n_code)
        begin
            raiserror('新供应商，与本地供应商代码重复。', 16, 1)
            select @ret_status = 1
        end else
        begin
            execute @ret_status = VDRRCVAPD @p_src, @p_id
            delete from NVENDOR
                where Src = @p_src and Id = @p_Id
        end
    end
    return(@ret_status)
end
GO
