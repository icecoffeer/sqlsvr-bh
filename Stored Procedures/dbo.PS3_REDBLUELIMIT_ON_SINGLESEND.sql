SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PS3_REDBLUELIMIT_ON_SINGLESEND]
(
    @piNum char(14),
    @piRcv int,
    @piFrcchk smallint,
    @piOper varchar(30)
) as
begin
    declare @user_gid int,
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
    @lastmodifier char(30),
    @settleno int,
    @sndtime datetime,
    @vVendor int

    select @user_gid = UserGid from System
    select
        @m_src = Src, @m_stat = Stat, @settleno = SETTLENO,
        @curr_date = getdate(),
        @m_num = Num, @m_fildate = FilDate, @sndtime = SNDTIME,
        @m_checker = Checker, @m_note = Note, 
        @m_filler=filler, @vVendor = VENDOR,
        @m_chkdate=chkdate, @m_note=note
        from PS3REDBLUECARD(nolock)
        where Num = @piNum

    if @m_stat <> 100
    begin
        raiserror('不是已审核的单据。', 16, 1)
        return(1)
    end
    if @m_src <> @user_gid and @m_src <> 1
    begin
        raiserror('不是本单位产生的单据。', 16, 1)
        return(2)
    end
    if not exists(select 1 from PS3REDBLUECARDSTOREDTL(nolock) where num = @piNum
	and storegid = @piRcv)
    begin
	select @m_note = rtrim(name) +'[' + rtrim(code) + ']' from store where gid = @piRcv
	select @m_note = '单号' + @piNum + '的单据不在门店' + rtrim(@m_note) +'生效。'
        raiserror(@m_note, 16, 1)
        return(3)
    end

    delete from NPS3REDBLUECARDDTL where NUM = @piNum and Src = @user_gid and Rcv = @piRcv

    delete from NPS3REDBLUECARD where NUM = @piNum and Src = @user_gid and Rcv = @piRcv
    execute GetNetBillId @n_billid output
    insert into NPS3REDBLUECARD(NUM, SETTLENO, STAT, SRC, NOTE, ID, RCV, FRCCHK, 
      NTYPE, NSTAT, SNDTIME, FILDATE, FILLER, CHECKER, CHKDATE, VENDOR)
    values
    (@piNum, @settleno, @m_stat, @user_gid, @m_note, @n_billid, @piRcv, @piFrcchk, 0, 0, @sndtime, @m_fildate, @m_filler, @m_checker, @m_chkdate, @vVendor)

    insert into NPS3REDBLUECARDDTL(NUM, LINE, GDGID, LOWLIMIT, TOPLIMIT, LIMITPERCENT, LIMITTOTAL, NOTE, SRC, RCV, ID)
      select NUM, LINE, GDGID, LOWLIMIT, TOPLIMIT, LIMITPERCENT, LIMITTOTAL, NOTE, @user_gid, @piRcv, @n_billid
      from PS3REDBLUECARDDTL where NUM = @piNum

    -- 记录日志
    INSERT INTO NPS3REDBLUECARDLOG (NUM, MODIFIER, TIME, ACT)
    VALUES (@piNUm, @piOper, GETDATE(), '发送')
    update PS3REDBLUECARD set SndTime = getdate() where NUM = @piNum
    return(0)
End
GO
