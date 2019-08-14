SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRMOFFSETSND]

(
    @num  varchar(14),
    @rcv int,
    @frcchk smallint,  --接收方是否强制审核
    @ErrMsg varchar(256) output
) as
begin
    declare
    @user_gid int,
    @curr_date datetime,

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
    @m_chkdate datetime,
    @M_VdrGid int,
    @total decimal(24, 4),
    @tax decimal(24, 4),
    @amount decimal(24, 4),
    @billTo int,
    @offsetType int,
    @offsetCalcType INT,
    @gatheringMode INT;

    select @user_gid = UserGid from System
    select
        @m_stat = Stat,
        @curr_date = getdate(),
        @m_fildate = FilDate, @M_VdrGid = VDRGID,
        @m_checker = Checker, @m_note = Note, @m_reccnt = RecCnt,
        @m_launch = Launch,@m_settleno=settleno,@m_filler=filler ,
        @m_chkdate=chkdate,@m_note=note,
        @billTo = BillTo, @offsetType = OffsetType, @offsetCalcType = OffsetCalcType,
        @tax = Tax, @total = Total, @amount = Amount, @gatheringMode = GatheringMode
        from PRMOFFSET(nolock)
        where Num = @num;
    if @m_stat <> 100 and @m_stat <> 800
    begin
        set @ErrMsg = '不是已审核或已生效的单据。';
        return(1);
    end

    if not exists(select 1 from PRMOFFSETLACDTL where num = @num
  and storegid = @rcv)
    begin
  select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @rcv;
  select @m_note ='单号' + @num + '的单据不在门店' + rtrim(@m_note) +'生效。';
        set @ErrMsg = @m_note;
        return(2);
    end

    execute GetNetBillId @n_billid output
    delete from NPrmOffset where num = @num
    delete from NPrmOffsetDtl where num = @num
    insert into NPRMOFFSET(
      ID, NUM, VDRGID, FilDate, Checker, NStat,Note, RecCnt, Launch, Src, Rcv,
      SndTime, RcvTime, Type, NNote,Stat,Settleno,filler,lstupdtime,
      Chkdate,FrcChk, Total, Tax, Amount, BillTo, OffsetType, OffsetCalcType, GatheringMode)
    values (
      @n_billid, @num, @m_VdrGid, @m_fildate, @m_checker, 0,
      @m_note, @m_RecCnt, @m_launch, @user_gid, @rcv,
      @curr_date, null, 0, null,@m_stat,@m_settleno,@m_filler,getdate(),
      @m_chkdate,@frcchk, @total, @tax, @amount, @billTo, @offsetType, @offsetCalcType, @gatheringMode);
    update PRMOFFSET set SndTime = @curr_date
    where  Num = @num;
    insert into NPRMOFFSETDTL(ID, SettleNo, NUM, LINE, GdGid, QPC, QPCSTR, OFFSETPRC, CNTINPRC, QTY, START, FINISH, NOTE, Tax, Amount, total, Alc, DiffPrc)
    select @n_billid, SettleNo, @num, LINE, GdGid, QPC, QPCSTR, OFFSETPRC, CNTINPRC, QTY, START, FINISH, NOTE, Tax, Amount, Total, Alc, DiffPrc
      from PRMOFFSETDTL where Num = @num;
    return(0)
end
GO
