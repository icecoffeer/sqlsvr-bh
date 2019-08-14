SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCINPRMSingleSND](
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
    @m_checker int,
    @m_reccnt int,
    @m_vdrgid int,
    @m_filler int,    
    @m_note varchar(100),
    @d_storegid int
    

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat,
        @curr_date = getdate(),
        @m_fildate = FilDate, @m_checker = Checker,
 	@m_filler = filler, @m_vdrgid =vdrgid,
        @m_reccnt = RecCnt, @m_note = Note
        from InPrcPrm
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
    if not exists(select 1 from INPRCPRMlacdtl where num = @p_num 
	and storegid = @P_rcv)
    begin
	select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
	select @m_note ='进价促销单' + @p_num + '不在门店' + rtrim(@m_note) +'生效。'
        raiserror(@m_note, 16, 1)
        return(3)
    end

        execute GetNetBillId @n_billid output
        insert into NInPrcPrm(
            ID, Num, VdrGid, FilDate, Filler, Checker, RecCnt,
            NStat, Note, Src, Rcv, SndTime,
            RcvTime, FrcChk, Type, NNote)
            values (
            @n_billid, @p_num, @m_vdrGid, @m_fildate, @m_filler, @m_checker, @m_reccnt,
            0, @m_note, @user_gid, @p_rcv, @curr_date,
            Null, @p_frcchk, 0, Null)
        update InPrcPrm
            set SndTime = @curr_date
            where Num = @p_num
        insert into NINPRCPRMDtl(
            Src, Id, Line, GdGid, Astart, Afinish,
            Price)
            select
                @user_gid, @n_billid, Line, GdGid, Astart, Afinish,
                Price
                from INPRCPRMDtl
                where Num = @p_num

    return(0)
end
GO
