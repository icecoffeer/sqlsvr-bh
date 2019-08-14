SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PRCPRMRCVGO](  
  @p_src int,  
  @p_id int,  
  @p_l_filler int,  
  @p_l_checker int  
) --with encryption  
as  
begin  
  declare  
    @ret_status int,  
    @curr_settleno int,  
    @n_num char(10),  
    @n_frcchk smallint,  
    @l_num char(10),  
    @l_newnum char(10),
    @n_stat int,
    @l_stat int,
    @l_oldnum char(10), --srcnum = @n_num的本地单据的单号
    @errormsg varchar(255)
  
  
  select @ret_status = 0  
  select @n_num = Num, @n_frcchk = FrcChk, @n_stat = stat   
      from NPRCPRM where Src = @p_src and Id = @p_id  
  select @l_num = max(Num) from PRCPRM  
  if @l_num is not null  
    execute NEXTBN @l_num, @l_newnum output  
  else  
    select @l_newnum = '0000000000'  
  
  --接收促销主题  
  exec PRCPRMTOPICRCV @p_src, @p_id  
  
  if not exists (select * from PRCPRM where Src = @p_src and SrcNum = @n_num)        --单据是否已被接收过  
  begin  
    select @curr_settleno = max(No) from MONTHSETTLE  
    insert into PRCPRMDTLDTL(  
        Num, Line, Item, SettleNo,  
        Start, Finish, Cycle, CStart, CFinish,  
        CSpec, QtyLo, QtyHi, Price, Discount,  
        InPrc, MbrPrc, GftGid, GftQty, GftPer,  
        GftType, PrmTag, PrmLwtPrc)  
    select  
        @l_newnum, N.Line, N.Item, @curr_settleno,  
        N.Start, N.Finish, N.Cycle, N.CStart, N.CFinish,  
        N.CSpec, N.QtyLo, N.QtyHi, N.Price, N.Discount,  
        N.InPrc, N.MbrPrc, X.LGid, N.GftQty, N.GftPer,  
        N.GftType, N.PrmTag, N.PrmLwtPrc  
    from NPRCPRMDTLDTL N, GDXLATE X  
    where N.Src = @p_src and N.Id = @p_id and  
        N.GftGid *= X.NGid  
    insert into PRCPRMDTL(  
        Num, Line, SettleNo,  
        GdGid, PrmType, CanGft, Qpc, QpcStr)  
    select  
        @l_newnum, N.Line, @curr_settleno,  
        X.LGid, N.PrmType, N.CanGft, N.Qpc, N.QpcStr  
    from NPRCPRMDTL N, GDXLATE X  
    where N.Src = @p_src and N.Id = @p_id and  
        N.GdGid = X.NGid  
    insert into PRCPRM(  
        Num, SettleNo, FilDate, Filler, Checker,  
        RecCnt, Stat, Note, Src, SrcNum,  
        SndTime, EON, Launch, TOPIC, --2002-09-02 wang xin  
        OverWriteRule, PRIORITY)  
    select  
        @l_newnum, @curr_settleno, FilDate, @p_l_filler, @p_l_checker,  
        RecCnt, 0, Note, Src, Num,  
        null, 1, Launch, ISNULL(TOPIC,'-'), --2002-09-02 wang xin --改回原来状态 by jinlei --默认促销主题  
        OverWriteRule, PRIORITY  
    from NPRCPRM  
    where Src = @p_src and Id = @p_id  
  
   --ShenMin  
    exec WritePrcPrmLog '促销单', @l_newnum, '接收'  
  
    if @n_frcchk = 1  
      execute @ret_status = PRCPRMCHK @l_newnum           
  end  
  else if (select count(num) from PRCPRM where src = @p_src and SrcNum = @n_num) = 1
  begin
    select @l_stat = stat, @l_oldnum = num from prcprm(nolock) where src = @p_src and SrcNum = @n_num
    if @l_stat = 1 and @n_stat = 21
    begin
      execute @ret_status = PRCPRM_BAL @l_oldnum, @p_l_checker, @errormsg output
      if @ret_status <> 0
      begin
        update nprcprm set nnote = @errormsg where src = @p_src and id = @p_id
        return @ret_status
      end
    end
    else if @l_stat = 5 and @n_stat = 22
    begin
      execute @ret_status = PRCPRM_END @l_oldnum, @p_l_checker, @errormsg output
      if @ret_status <> 0
      begin
        update nprcprm set nnote = @errormsg where src = @p_src and id = @p_id
        return @ret_status
      end    
    end 	
  end
  
  delete from NPRCPRMDTLDTL  
      where Src = @p_src and Id = @p_id  
  delete from NPRCPRMDTL  
      where Src = @p_src and Id = @p_id  
  delete from NPRCPRM  
      where Src = @p_src and Id = @p_id  
  delete from NPRMTOPIC  
      where Src = @p_src and Id = @p_id  
  return(@ret_status)  
end  
GO
