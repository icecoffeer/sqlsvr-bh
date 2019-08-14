SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PayRatePrm_SingleSnd](
    @p_num char(14),
    @p_rcv int,
    @p_frcchk smallint,
    @OPER VARCHAR(30)
) as
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
    @m_filler char(30),
    @m_chkdate datetime,
    @lastmodifier char(30)

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat,
        @curr_date = getdate(),
        @m_num = Num, @m_fildate = FilDate,
        @m_checker = Checker, @m_note = Note, @m_reccnt = RecCnt,
        @m_launch = Launch,@m_filler=filler ,
        @m_chkdate=chkdate,@m_note=note, @lastmodifier = lastmodifier
        from PayRatePrm
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
    if not exists(select 1 from PAYRATEPRMLACDTL where num = @p_num
	and storegid = @P_rcv)
    begin
	select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
	select @m_note ='单号' + @p_num + '的单据不在门店' + rtrim(@m_note) +'生效。'
        raiserror(@m_note, 16, 1)
        return(3)
    end

    delete NPayRatePrmDtl from NPayRatePrm
    where NPayRatePrmDtl.ID = NPayRatePrm.ID and NPayRatePrm.num = @m_num
          and NPayRatePrm.Src = @user_gid and NPayRatePrm.Rcv = @p_rcv
    delete NPayRatePrm where num = @m_num and Src = @user_gid and Rcv = @p_rcv

    execute GetNetBillId @n_billid output
    insert into NPayRatePrm(
      ID, Num, FilDate, Checker, NStat,Note, RecCnt, Launch, Src, Rcv,
      SndTime, RcvTime, Type, NNote,Stat,filler,lstupdtime,
      Chkdate,FrcChk,lastmodifier)
    values (
      @n_billid, @m_num, @m_fildate, @m_checker, 0,
      @m_note, @m_RecCnt, @m_launch, @user_gid, @p_rcv,
      @curr_date, null, 0, null,@m_stat,@m_filler,getdate(),
      @m_chkdate,@p_frcchk,@lastmodifier)
    update PayRatePrm set SndTime = @curr_date
	    where  Num = @p_num
    insert into NPayRatePrmDtl(src,id,line,gdgid,qpc,qpcstr,astart,afinish,payrate)
      select @user_gid, @n_billid, Line,GdGid,qpc,qpcstr,astart,afinish,payrate
      from PayRatePrmDtl where Num = @p_num

    -- 记录日志
    INSERT INTO PAYRATEPRMLOG (NUM, MODIFIER, TIME, ACT)
    VALUES (@p_num, @OPER, GETDATE(), '发送')

    return(0)
End
GO
