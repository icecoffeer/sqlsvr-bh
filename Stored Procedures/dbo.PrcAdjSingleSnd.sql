SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PrcAdjSingleSnd](
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
    if not exists(select 1 from prcadjlacdtl where cls = @p_cls and num = @p_num 
	and storegid = @P_rcv)
    begin
	select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
	select @m_note ='类型'+rtrim(@p_cls) + '单号' + @p_num + '的单据不在门店' + rtrim(@m_note) +'生效。'
        raiserror(@m_note, 16, 1)
        return(3)
    end

	execute GetNetBillId @n_billid output
	insert into NPrcAdj(
	    ID, Cls, Num, FilDate, Checker, NStat,
	    Note, RecCnt, Launch, Src, Rcv,
	    SndTime, RcvTime, FrcChk, Type, NNote)
	    values (
	    @n_billid, @m_cls, @m_num, @m_fildate, @m_checker, 0,
	    @m_note, @m_RecCnt, @m_launch, @user_gid, @p_rcv,
	    @curr_date, null, @p_frcchk, 0, null)
	update PrcAdj
	    set SndTime = @curr_date
	    where Cls = @p_cls and Num = @p_num
	if @p_cls = '量贩价'
	begin    	
	insert into NPrcAdjDtl(
	    Src, ID, Line,
	    GdGid, OldPrc, NewPrc, QTY, QPC, QPCSTR)
	    select
		@user_gid, @n_billid, Line,
		GdGid, OldPrc, NewPrc, QTY, QPC, QPCSTR
	    from PrcAdjDtl
	    where Cls = @p_cls and Num = @p_num
	end
	else
	begin
	insert into NPrcAdjDtl(
	    Src, ID, Line,
	    GdGid, OldPrc, NewPrc, QPC, QPCSTR)
	    select
		@user_gid, @n_billid, Line,
		GdGid, OldPrc, NewPrc, QPC, QPCSTR
	    from PrcAdjDtl
	    where Cls = @p_cls and Num = @p_num
	end

    return(0)
end
GO
