SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCADJSND](
    @p_cls char(8),
    @p_num char(10),
    @p_rcv int,
    @p_frcchk smallint
) with encryption as
begin
    declare
    @user_gid int,
    @curr_date datetime,

    @m_src int,
    @m_stat smallint,
    @m_cls char(8),
    @m_num char(10),
    @m_fildate datetime,
    @m_checker int,
    @m_note varchar(100),
    @m_reccnt int,
    @m_launch datetime,
    @d_storegid int,
    @n_billid int

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat,
        @curr_date = getdate(),
        @m_cls = Cls, @m_num = Num, @m_fildate = FilDate,
        @m_checker = Checker, @m_note = Note, @m_reccnt = RecCnt,
        @m_launch = Launch
        from PrcAdj
        where Cls = @p_cls and Num = @p_num
    if @m_stat <> 1 and @m_stat <> 5
    begin
        raiserror('不是已审核或已生效的单据。', 16, 1)
        return(1)
    end
    if @m_src <> @user_gid and @m_src <> 1
    begin
        raiserror('不是本单位产生的单据。', 16, 1)
        return(2)
    end

    declare c_lac cursor for
        select StoreGid from PrcAdjLacDtl
        where Cls = @p_cls and Num = @p_num
        for read only
    open c_lac
    fetch next from c_lac into @d_storegid

    --2005.8.9, Added by ShenMin, Q4706, 调价类单记录日志
    if @@fetch_status = 0
        exec WritePrcAdjLog @p_cls, @p_num, '发送'

    while @@fetch_status = 0
    begin
        execute GetNetBillId @n_billid output
        if @p_cls <> '量贩价' begin
        insert into NPrcAdj(
            ID, Cls, Num, FilDate, Checker, NStat,
            Note, RecCnt, Launch, Src, Rcv,
            SndTime, RcvTime, FrcChk, Type, NNote)
            values (
            @n_billid, @m_cls, @m_num, @m_fildate, @m_checker, 0,
            @m_note, @m_RecCnt, @m_launch, @user_gid, @d_storegid,
            @curr_date, null, @p_frcchk, 0, null)
        update PrcAdj
            set SndTime = @curr_date
            where Cls = @p_cls and Num = @p_num
        insert into NPrcAdjDtl(
            Src, ID, Line,
            GdGid, OldPrc, NewPrc, QPC, QPCSTR)
            select
                @user_gid, @n_billid, Line,
                GdGid, OldPrc, NewPrc, QPC, QPCSTR
            from PrcAdjDtl
            where Cls = @p_cls and Num = @p_num
         end
         else    --Addded By Wang xin 2002-05-06 增加量贩价调整单处理
         begin
            insert into NPrcAdj(
            ID, Cls, Num, FilDate, Checker, NStat,
            Note, RecCnt, Launch, Src, Rcv,
            SndTime, RcvTime, FrcChk, Type, NNote)
            values (
            @n_billid, @m_cls, @m_num, @m_fildate, @m_checker, 0,
            @m_note, @m_RecCnt, @m_launch, @user_gid, @d_storegid,
            @curr_date, null, @p_frcchk, 0, null)
        update PrcAdj
            set SndTime = @curr_date
            where Cls = @p_cls and Num = @p_num
        insert into NPrcAdjDtl(
            Src, ID, Line,
            GdGid, OldPrc, NewPrc, QTY, QPC, QPCSTR)
            select
                @user_gid, @n_billid, Line,
                GdGid, OldPrc, NewPrc, QTY, QPC, QPCSTR 
            from PrcAdjDtl
            where Cls = @p_cls and Num = @p_num
         end

  	
        fetch next from c_lac into @d_storegid
    end
    close c_lac
    deallocate c_lac

    return(0)
end
GO
