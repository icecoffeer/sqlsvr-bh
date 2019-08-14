SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[gftprmbck_delbill]  
(  
  @Num char(14),  
  @Oper char(30),  
  @Cls char(10),  
  @TOSTAT INT,  
  @Msg varchar(255) output  
)  
as  
begin  
  declare @stat int, @return_status int  
  declare @rcode char(18), @sndnum char(14)  
  declare @cur_date datetime, @cur_settleno int  
  declare @wrh int, @gdgid int, @vdr int, @billto int  
  declare @qty money, @amount money  
  declare @vRet int, @sndstat int  
  declare @negnum varchar(14), @usergid int  
  
  select @vRet = 0  
  select @cur_date = convert(datetime, convert(char, getdate(), 102))  
  select @cur_settleno = max(NO) from MONTHSETTLE  
  select @usergid = usergid from system  
  --检查单据  
  select @stat = stat from gftprmbck where num = @Num  
  if @stat <> 100  
  begin  
    set @Msg = @Num + '不是已审核单据，不能冲单。'  
    return 1  
  end  
  --发放单预处理  
  select @sndnum = sndnum from gftprmbck where num like @Num  
  select @sndstat = stat from gftprmsnd where num like @sndnum  
  if @sndstat not in (100)  
  begin  
    set @Msg = @Num + '关联的发放单的状态为非审核状态不能继续冲单操作。'  
    return 1  
  end  
  --开始处理  
  --一、生成负单  
  exec gennextbillnum '','gftprmbck',@negnum output  
  insert into gftprmbck  
            (NUM, STAT, FILLER, FILDATE, settleno, SRC, LSTUPDTIME, NOTE, SNDNUM, CLS, POSNO, FLOWNO, CLIENT, CTRNAME, GENNUM, CHECKER, CHECKDATE, PRNTIME, MODNUM)  
  select @negnum, 120, @Oper, FILDATE, settleno, @usergid, LSTUPDTIME, NOTE, SNDNUM, CLS, POSNO, FLOWNO, CLIENT, CTRNAME, GENNUM, CHECKER, CHECKDATE, PRNTIME, @NUM  
  from gftprmbck where num like @Num  
  
  insert into gftprmbckdtl  
            (NUM, LINE, GROUPID, RCODE, GFTGID, SRCQTY,  BCKQTY,  QTY,  AMT,  BCKAMT, GFTPRC, REALGFTPRC,  RULEBCKCNT)  
  select @negnum, LINE, GROUPID, RCODE, GFTGID, SRCQTY, -BCKQTY, -QTY, -AMT, -BCKAMT, GFTPRC, REALGFTPRC, -RULEBCKCNT  
  from gftprmbckdtl where num like @Num  
  
  insert into gftprmbckdtldtl  --add by jinlei  
            (NUM, LINE, GROUPID, RCODE, GFTGID, SRCQTY,  BCKQTY,  QTY,  AMT,  BCKAMT, GFTPRC, REALGFTPRC,  RULEBCKCNT, MAINLINE)  
  select @negnum, LINE, GROUPID, RCODE, GFTGID, SRCQTY, -BCKQTY, -QTY, -AMT, -BCKAMT, GFTPRC, REALGFTPRC, -RULEBCKCNT, MAINLINE  
  from gftprmbckdtldtl where num like @Num  
  
  --二、回写赠品发放单  
  update gftprmsndgift set  
        bckqty = gftprmsndgift.bckqty + bckd.bckqty  
  from gftprmbck bckm left join gftprmbckdtl bckd on bckm.num = bckd.num  
    where gftprmsndgift.Num     = bckm.SndNum and bckm.Num = @negnum  
           and gftprmsndgift.rcode   = bckd.rcode  
           and gftprmsndgift.Groupid = bckd.Groupid  
           and gftprmsndgift.gftgid  = bckd.gftgid  
  if object_id('tempdb..#tmp_rulebckcnt') is not null drop table #tmp_rulebckcnt  
  select rcode, sum(rulebckcnt)/count(1) rulebckcnt, count(1) gftcnt  
        into #tmp_rulebckcnt  
        from gftprmbckdtl  
    where num = @negnum group by rcode  
  update gftprmsndrule set bckcount = ru.bckcount + res.rulebckcnt  
         from #tmp_rulebckcnt res(nolock), gftprmsndrule ru(nolock)  
     where res.rcode = ru.rcode  
     and ru.num = @sndnum and res.rcode <> '-'  
  if object_id('tempdb..#tmp_rulebckcnt') is not null drop table #tmp_rulebckcnt  
  
  --三、折价金额商品销售 -> BCKQTY - QTY 金额：AMT 单价: AMT/(BCKQTY-QTY)  
  if object_id('c_gftbck') is not null deallocate c_gftbck  
  declare c_gftbck cursor for  
  select GFTGID, sum(BCKQTY - QTY), sum(AMT) from gftprmbckdtldtl --edited by jinlei  
   where NUM = @negnum and (bckqty - qty)<>0 group by GFTGID  
  open c_gftbck  
  fetch next from c_gftbck into @gdgid, @qty, @amount  
  while @@fetch_status = 0  
  begin  
    select @wrh = WRH, @billto = BILLTO from GOODS(nolock) where GID = @gdgid  
    set @qty = -1*@qty  
    execute @vRet = LOADIN @wrh, @gdgid, @qty, 0, null /*取售价为0*/  
    set @qty = -1*@qty  
    if @vRet <> 0  
    begin  
      close c_gftbck  
      deallocate c_gftbck  
      raiserror('处理折价商品时发生异常', 16, 1)  
      return 1  
    end  
    select @cur_settleno = MAX(NO) from MONTHSETTLE(nolock)  
    insert into XS (ADATE, ASETTLENO, BWRH, BGDGID, BCSTGID, BSLRGID, BVDRGID,  
      LS_Q, LS_A, LS_T, LS_I, LS_R)  
    values(@cur_date, @cur_settleno, @wrh,  
        @gdgid, 1, 1, @billto, @qty, @amount, 0, 0, 0)  
    fetch next from c_gftbck into @gdgid, @qty, @amount  
  end  
  close c_gftbck  
  deallocate c_gftbck  
  
  --四、退赠品记报表 - BCKQTY  
  if object_id('c_gftbck') is not null  
        deallocate c_gftbck  
  declare c_gftbck cursor for  
    select gftgid, sum(bckqty), sum(realgftprc*bckqty)  
    from gftprmbckdtldtl  --edited by jinlei  
   where num = @negnum and bckqty<>0 group by gftgid  
  open c_gftbck  
  fetch next from c_gftbck into @gdgid, @qty, @amount  
  while @@fetch_status = 0  
  begin  
    select @wrh = WRH, @billto = BILLTO from GOODS(nolock) where GID = @gdgid  
    set @qty = -1*@qty  
    execute @vRet = UNLOAD @wrh, @gdgid, @qty, 0, null /*取售价为0*/  
    set @qty = -1*@qty  
    if @vRet <> 0  
    begin  
      close c_gftbck  
      deallocate c_gftbck  
      raiserror('加载库存时发生异常', 16, 1)  
      return 1  
    end  
    select @cur_settleno = MAX(NO) from MONTHSETTLE(nolock)  
    execute @vRet = stkoutbckdtlchkcrt  
       '零售', @cur_date, @cur_settleno, @cur_date,  
       @cur_settleno, 1, 1, @wrh,  
       @gdgid, @qty, @amount, 0, 0, 0, @billto, 1, 0 /* add by jinlei 3692*/  
    if @vRet <> 0  
    begin  
      close c_gftbck  
      deallocate c_gftbck  
      raiserror('记录报表时发生异常', 16, 1)  
      return 1  
    end  
    fetch next from c_gftbck into @gdgid, @qty, @amount  
  end  
  close c_gftbck  
  deallocate c_gftbck  
  
  --五、处理单据  
  update gftprmbck set stat = 130, lstupdtime = getdate() where num = @Num  
  exec gftprmbck_addlog @Num, 130, @Oper  
  return 0  
end
GO
