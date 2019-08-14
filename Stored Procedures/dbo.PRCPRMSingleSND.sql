SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMSingleSND](
  @p_num char(10),
  @p_rcv int,
  @p_frcchk smallint
) --with encryption
as
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
    @m_note varchar(100),
    @m_act varchar(128),
    @d_storegid int,
    @m_launch datetime, --2002-09-02 wang xin
    @m_Topic varchar(10),
    @m_OverWriteRule smallint,
    @m_Priority int

  select @user_gid = UserGid from System
  select
    @m_src = Src, @m_stat = Stat,
    @curr_date = getdate(),
    @m_fildate = FilDate, @m_checker = Checker,
    @m_reccnt = RecCnt, @m_note = Note,
    @m_launch = Launch, @m_Topic = TOPIC,   --2002-09-02 wang xin
    @m_OverWriteRule = overwriterule,
    @m_Priority = PRIORITY
  from PrcPrm
  where Num = @p_num
  if @m_stat not in (1, 5)--2002-09-02
  begin
    raiserror('不是已审核的单据。', 16, 1)
    return(1)
  end
  if @m_src <> @user_gid and @m_src <> 1
  begin
    raiserror('不是本单位产生的单据。', 16, 1)
    return(2)
  end
  if not exists(select 1 from prcprmlacdtl where num = @p_num
      and storegid = @P_rcv)
  begin
    select @m_note = rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
    select @m_note ='促销单' + @p_num + '不在门店' + rtrim(@m_note) +'生效。'
    raiserror(@m_note, 16, 1)
    return(3)
  end

  execute GetNetBillId @n_billid output
  insert into NPrcPrm(
      ID, Num, FilDate, Checker, RecCnt,
      NStat, Note, Src, Rcv, SndTime,
      RcvTime, FrcChk, Type, NNote, Launch, Topic, overwriterule, PRIORITY) --2002.09.02 wang xin
  values (
      @n_billid, @p_num, @m_fildate, @m_checker, @m_reccnt,
      0, @m_note, @user_gid, @p_rcv, @curr_date,
      Null, @p_frcchk, 0, Null, @m_launch, @m_Topic, @m_OverWriteRule, @m_Priority) --2002-09-02 wang xin
  update PrcPrm
    set SndTime = @curr_date
      where Num = @p_num
  insert into NPrcPrmDtl(
      Src, Id, Line, GdGid, PrmType,
      CanGft, Qpc, QpcStr)
  select
      @user_gid, @n_billid, Line, GdGid, PrmType,
      CanGft, Qpc, QpcStr
  from PrcPrmDtl
  where Num = @p_num
  insert into NPrcPrmDtlDtl(
      Src, Id, Line, Item, Start,
      Finish, Cycle, CStart, CFinish, CSpec,
      QtyLo, QtyHi, Price, Discount, InPrc, MbrPrc,
      GftGid, GftQty, GftPer, GftType, PrmTag)
  select
      @user_gid, @n_billid, Line, Item, Start,
      Finish, Cycle, CStart, CFinish, CSpec,
      QtyLo, QtyHi, Price, Discount, InPrc, MbrPrc,
      GftGid, GftQty, GftPer, GftType, PrmTag
  from PrcPrmDtlDtl
  where Num = @p_num
  --发送促销主题
  exec PRCPRMTOPICSND @P_rcv, @n_billid;
--2005.10.14, Added by ShenMin, Q5047, 售价调整单促销单记录操作日志
  select @m_act = '发送到指定门店' + rtrim(name) +'['+rtrim(code)+']' from store where gid = @p_rcv
  exec WritePrcPrmLog '促销单', @p_num, @m_act

  return(0)
end
GO
