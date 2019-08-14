SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RtlPrcAdj_SingleSnd](
    @p_num char(14),
    @p_rcv int,
    @p_frcchk smallint
) with encryption as
begin
    declare
    @user_gid int,
    @curr_date datetime,

    @m_src int,
    @m_stat smallint,
    @m_num char(14),
    @m_fildate datetime,
    @m_checker char(30),
    @m_note varchar(100),
    @m_reccnt int,
    @m_launch datetime,
    @d_storegid int,
    @n_billid int,
    @m_settleno int,
    @m_filler char(30),
    @m_chkdate datetime

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat,
        @curr_date = getdate(),
        @m_num = Num, @m_fildate = FilDate,
        @m_checker = Checker, @m_note = Note, @m_reccnt = RecCnt,
        @m_launch = Launch,@m_settleno=settleno,@m_filler=filler ,
        @m_chkdate=chkdate,@m_note=note
        from RtlPrcAdj
        where Num = @p_num
    if @m_stat <> 100 and @m_stat <> 800
    begin
        raiserror('不是已审核或已生效的单据。', 16, 1)
        return(1)
    end
    if @m_src <> @user_gid and @m_src <> 1
    begin
        raiserror('不是本单位产生的单据。', 16, 1)
        return(2)
    end
    if not exists(select 1 from rtlprcadjlacdtl where num = @p_num
	and storegid = @P_rcv)
    begin
	select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
	select @m_note ='单号' + @p_num + '的单据不在门店' + rtrim(@m_note) +'生效。'
        raiserror(@m_note, 16, 1)
        return(3)
    end

    execute GetNetBillId @n_billid output
    insert into NRtlPrcadj(
      ID, Num, FilDate, Checker, NStat,Note, RecCnt, Launch, Src, Rcv,
      SndTime, RcvTime, Type, NNote,Stat,Settleno,filler,lstupdtime,
      Chkdate,FrcChk)
      values (
      @n_billid, @m_num, @m_fildate, @m_checker, 0,
      @m_note, @m_RecCnt, @m_launch, @user_gid, @p_rcv,
      @curr_date, null, 0, null,@m_stat,@m_settleno,@m_filler,getdate(),
      @m_chkdate,@p_frcchk)
    update RtlPrcAdj set SndTime = @curr_date
	    where  Num = @p_num
    insert into NRtlPrcAdjDtl(Src, ID, Line,
      GdGid, oldrtlprc,newrtlprc,oldlwtprc,newlwtprc,oldtopprc,newtopprc,
      oldmbrprc,newmbrprc,oldwhsprc,newwhsprc,qty,note, QPC, QPCSTR)
      select @user_gid, @n_billid, Line,GdGid, oldrtlprc,newrtlprc,oldlwtprc,
      newlwtprc,oldtopprc,newtopprc,oldmbrprc,newmbrprc,oldwhsprc,newwhsprc,
      qty,note, QPC, QPCSTR from rtlprcadjdtl where Num = @p_num

    --2005.10.14, Added by ShenMin, Q5047, 售价调整单促销单记录操作日志
    exec WritePrcAdjLog '售价', @p_num, '发送到指定门店'

    return(0)
end
GO
