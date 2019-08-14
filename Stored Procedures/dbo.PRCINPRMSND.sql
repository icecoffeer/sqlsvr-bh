SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCINPRMSND](
    @p_num char(10),
    @p_rcv int,
    @p_frcchk smallint
) with encryption as
begin
    declare
    @user_gid int,
    @curr_date datetime,
    @n_billid int,

    @m_src int,
    @m_stat smallint,
    @m_fildate datetime,
    @m_filler int,
    @m_checker int,
    @m_reccnt int,
    @m_note varchar(100),
    @m_vdrgid int,
    @d_storegid int

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat,
        @curr_date = getdate(),
        @m_fildate = FilDate, @m_checker = Checker, @m_filler = filler,
        @m_reccnt = RecCnt, @m_note = Note, @m_vdrgid = vdrgid
        from INPRCPRM
        where Num = @p_num
    if @m_stat <> 1
    begin
        raiserror('不是已审核的单据。', 16, 1)
        return(1)
    end
    if @m_src <> @user_gid and @m_src <> 1
    begin
        raiserror('不是本单位产生的单据。', 16, 1)
        return(2)
    end

    declare c_lac cursor for
        select StoreGid from INPRCPRMLacDtl
        where Num = @p_num
        for read only
    open c_lac
    fetch next from c_lac into @d_storegid
    while @@fetch_status = 0
    begin
	execute GetNetBillId @n_billid output
        insert into NINPRCPRM(
            ID, Num, VdrGid, FilDate, Filler, Checker, RecCnt,
            Note, NStat, Src, Rcv, SndTime,
            RcvTime, FrcChk, Type, NNote)
            values (
            @n_billid, @p_num, @m_vdrgid, @m_fildate, @m_filler, @m_checker, @m_reccnt,
            @m_note, 0, @user_gid, @d_storegid, @curr_date,
            Null, @p_frcchk, 0, Null)
        update INPRCPRM
            set SndTime = @curr_date
            where Num = @p_num
        insert into NINPRCPRMDtl(
            Src, Id, Line, GdGid, Astart, AFinish,
            Price)
            select
                @user_gid, @n_billid, Line, GdGid, Astart, AFinish,
            Price
                from INPRCPRMDtl
                where Num = @p_num
        fetch next from c_lac into @d_storegid
    end
    close c_lac
    deallocate c_lac

    return(0)
end
GO
