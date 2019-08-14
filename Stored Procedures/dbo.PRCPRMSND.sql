SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMSND](  
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
    @d_storegid int,  
    @m_launch datetime, --2002-09-02 wang xin  
    @m_Topic varchar(10), --ShenMin  
    @m_OverWriteRule smallint,  
    @m_Priority int  
  
  select @user_gid = UserGid from System  
  select  
    @m_src = Src, @m_stat = Stat,  
    @curr_date = getdate(),  
    @m_fildate = FilDate, @m_checker = Checker,  
    @m_reccnt = RecCnt, @m_note = Note,  
    @m_launch = Launch, @m_Topic = TOPIC,   --2002-09-02 wang xin; 2007.4.18, ShenMin  
    @m_OverWriteRule = overwriterule,  
    @m_Priority = PRIORITY  
  from PrcPrm  
  where Num = @p_num  
  if @m_stat not in (1, 5, 21, 22) --2002-09-02  
  begin  
    raiserror('不是已审核、已作废、已生效或已终止的单据。', 16, 1)
    return(1)  
  end  
  if @m_src <> @user_gid and @m_src <> 1  
  begin  
    raiserror('不是本单位产生的单据。', 16, 1)  
    return(2)  
  end  
  
  declare c_lac cursor for  
    select StoreGid from PrcPrmLacDtl  
    where Num = @p_num  
      for read only  
  open c_lac  
  fetch next from c_lac into @d_storegid  
  
--2005.10.14, Added by ShenMin, Q5047, 售价调整单促销单记录操作日志  
  exec WritePrcPrmLog '促销单', @p_num, '发送'  
  
  while @@fetch_status = 0  
  begin  
    execute GetNetBillId @n_billid output  
    insert into NPrcPrm(  
        ID, Num, FilDate, Checker, RecCnt,  
        NStat, Note, Src, Rcv, SndTime,  
        RcvTime, FrcChk, Type, NNote, Launch, TOPIC, overwriterule, PRIORITY) --2002.09.02 wang xin  
    values (  
        @n_billid, @p_num, @m_fildate, @m_checker, @m_reccnt,  
        0, @m_note, @user_gid, @d_storegid, @curr_date,  
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
        GftGid, GftQty, GftPer, GftType, PrmTag, PrmLwtPrc)  
    select  
        @user_gid, @n_billid, Line, Item, Start,  
        Finish, Cycle, CStart, CFinish, CSpec,  
        QtyLo, QtyHi, Price, Discount, InPrc, MbrPrc,  
        GftGid, GftQty, GftPer, GftType, PrmTag, PrmLwtPrc  
    from PrcPrmDtlDtl  
    where Num = @p_num  
    --发送促销主题  
    exec PRCPRMTOPICSND @d_storegid, @n_billid;  
    fetch next from c_lac into @d_storegid  
  end  
  close c_lac  
  deallocate c_lac  
  
  return(0)  
end  
GO
