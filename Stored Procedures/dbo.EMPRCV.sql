SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[EMPRCV](
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
        from NEMPLOYEE
        where Src = @p_src and Id = @p_id
    if @n_type <> 1
    begin
        raiserror('不是可接收员工', 16, 1)
        return(1)
    end

    select
        @l_gid = LGid
        from EMPXLATE
        where NGid = @n_gid
    if @@RowCount > 0
    begin
        if @p_frcupd = 1 or @n_frcupd = 1
            execute @ret_status = EMPRCVUPD @p_src, @p_id, @l_gid
        delete from NEMPLOYEE
            where Src = @p_src and Id = @p_id
        return(@ret_status)
    end
    if exists (select * from EMPLOYEEH where Gid = @n_gid)
    begin
        if not exists (select * from EMPLOYEE where Gid = @n_gid)
        begin
            if exists (select * from EMPLOYEE where Code = @n_code)
            begin
                raiserror('本地找到相同员工，但与本地其它员工代码重复。', 16, 1)
                select @ret_status = 1
            end else
            begin
                execute @ret_status = EMPRCVAPD @p_src, @p_id
                delete from NEMPLOYEE
                    where Src = @p_src and Id = @p_id
            end
        end
        else begin
            if @p_frcupd = 1 or @n_frcupd = 1
                execute @ret_status = EMPRCVUPD @p_src, @p_id, @n_gid
            delete from NEMPLOYEE
                where Src = @p_src and Id = @p_id
        end
    end
    else begin
        if exists (select * from EMPLOYEE where Code = @n_code)
        begin
            raiserror('新员工，与本地员工代码重复。', 16, 1)
            select @ret_status = 1
        end else
        begin
            execute @ret_status = EMPRCVAPD @p_src, @p_id
            delete from NEMPLOYEE
                where Src = @p_src and Id = @p_id
        end
    end
    return(@ret_status)
end
GO
