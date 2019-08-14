SET QUOTED_IDENTIFIER OFF
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[VDRGD2RCV](
    @p_n_gid int,
    @p_l_gid int
) with encryption as
begin
declare
    @ret_status int,
    @n_storegid int,
    @n_vdrgid int,
    @n_gdgid int,
    @storegid int,
    @n_src int,
    @n_id int,
    @n_vdrgd2id int,
    @n_frcupd smallint

    select @ret_status = 0
    select @storegid = usergid from system

    delete from VDRGD2 where STOREGID = @storegid and GDGID = @p_n_gid

    declare c_vdrgd2 cursor for
        select distinct VDRGID from NVDRGD2
        where GDGID = @p_n_gid
        and STOREGID = @storegid
        for read only
    open c_vdrgd2
    fetch next from c_vdrgd2 into @n_vdrgid
    while @@fetch_status = 0
    begin
                select @n_vdrgd2id = ID from NVDRGD2 where GDGID = @p_n_gid and STOREGID = @storegid  --2003.01.08
                                and VDRGID = @n_vdrgid

        if not exists (select 1 from VENDOR
            where GID = @n_vdrgid)
        begin
            if not exists (select 1 from NVENDOR where GID = @n_vdrgid and RCV = @storegid)
            begin
                select @ret_status = -1
                break
            end
            else
            begin
                select @n_src = SRC, @n_id = ID, @n_frcupd = FRCUPD from NVENDOR where GID = @n_vdrgid and RCV = @storegid
                execute VDRRCV @n_src, @n_id, @n_frcupd
            end
        end
        if not exists (select 1 from VDRGD2
            where STOREGID = @storegid and GDGID = @p_l_gid and VDRGID = @n_vdrgid)
        begin
            insert into VDRGD2(STOREGID, GDGID, VDRGID)
                values(@storegid, @p_l_gid, @n_vdrgid)
        end
        delete from NVDRGD2 where STOREGID = @storegid and GDGID = @p_n_gid and VDRGID = @n_vdrgid and ID = @n_vdrgd2id
        fetch next from c_vdrgd2 into @n_vdrgid
    end
    close c_vdrgd2
    deallocate c_vdrgd2

    return(@ret_status)
end
GO
