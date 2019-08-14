SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[CLNRCV](
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
    @l_gid int,
    @n_LstUpdTime datetime,
    @l_LstUpdTime datetime


    select @ret_status = 0
    select
        @n_gid = Gid, @n_code = Code, @n_frcupd = FrcUpd,
        @n_type = Type, @n_LstUpdTime = LstUpdTime
        from NCLIENT
        where Src = @p_src and Id = @p_id
    if @n_type <> 1
    begin
        raiserror('不是可接收客户', 16, 1)
        return(1)
    end
    select @l_LstUpdTime = LstUpdTime from CLIENT(nolock)
      where Gid = @n_Gid
    if @n_LstUpdTime > '1980-01-01'
      if @n_LstUpdTime <= @l_LstUpdTime
      begin
        raiserror('更新时间比本地早不接收', 16, 1)
        return 2
      end

    select
        @l_gid = LGid
        from CLNXLATE
        where NGid = @n_gid
    if @@RowCount > 0
    begin
        if @p_frcupd = 1 or @n_frcupd = 1
            execute @ret_status = CLNRCVUPD @p_src, @p_id, @l_gid
        delete from NCLIENT
            where Src = @p_src and Id = @p_id
        return(@ret_status)
    end
    if exists (select * from CLIENTH where Gid = @n_gid)
    begin
        if not exists (select * from CLIENT where Gid = @n_gid)
        begin
            if exists (select * from CLIENT where Code = @n_code)
            begin
                raiserror('本地找到相同客户，但与本地其它客户代码重复。', 16, 1)
                select @ret_status = 1
            end else
            begin
                execute @ret_status = CLNRCVAPD @p_src, @p_id
                delete from NCLIENT
                    where Src = @p_src and Id = @p_id
            end
        end else
        begin
            if @p_frcupd = 1 or @n_frcupd = 1
                execute @ret_status = CLNRCVUPD @p_src, @p_id, @n_gid
            delete from NCLIENT
                where Src = @p_src and Id = @p_id
        end
    end
    else begin
        if exists (select * from CLIENT where Code = @n_Code)
        begin
            raiserror('新客户，与本地客户代码重复。', 16, 1)
            select @ret_status = 1
        end else
        begin
            execute @ret_status = CLNRCVAPD @p_src, @p_id
            delete from NCLIENT
                where Src = @p_src and Id = @p_id
        end
    end
    return(@ret_status)
end
GO
