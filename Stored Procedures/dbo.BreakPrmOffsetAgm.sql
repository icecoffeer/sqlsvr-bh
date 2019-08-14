SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[BreakPrmOffsetAgm]
(
  @Num varchar(14),
  @Oper varchar(30),  --操作人
  @NewNum varchar(4000) output,
  @Errmsg varchar(4000) output
) as
begin
  declare
    @NewBillNum varchar(14),              @AgmcntInprc decimal(24, 4),    @Qpc decimal(24, 4),
    @settleno int,                        @line int,
    @vdrgid int,                          @gdgid int,
    @psr int,                             @Mnuit varchar(6),
    @OffsetView int,                      @AgmPrc decimal(24, 4),
    @Filler varchar(30),                  @DiffPrc decimal(24, 4),
    @Reccnt int,                          @TopAmt decimal(24, 2),
    @DeptLmt int,                         @TopQty decimal(24, 4),
    @MstNote varchar(255),                @QpcStr varchar(15),
    @Launch datetime,                     @Note varchar(255),
    @CoverAll smallint,                   @AStart datetime,
    @BeginDate datetime,                  @AFinish datetime,
    @EndDate datetime,                    @src int,
    @optBreakByGdStoreBilltoOn int,       @StoreGid int,
    @FaZBGid int;

  select @FaZBGid = ZBGid from FaSystem(NoLock)
  exec OPTREADINT 761, 'BreakByGdStoreBilltoOn', '0', @optBreakByGdStoreBilltoOn OUTPUT
  if @optBreakByGdStoreBilltoOn = 0
  begin
    --若所有明细在商品资料中的缺省供应商均一致，则不拆分
    if (select count(distinct(G.Billto)) from PRMOFFSETAGMDTL P(nolock), GOODS G(nolock)
       where P.GDGID = G.GID
         and P.NUM = @NUM) = 1
    begin
      select @NewNum = @Num ;
      update PRMOFFSETAGM
      set vdrgid = (select distinct goods.billto
      from goods(nolock), PRMOFFSETAGMDTL(nolock)
          where goods.gid = PRMOFFSETAGMDTL.gdgid
            and PRMOFFSETAGMDTL.num = @NUM)
      where Num = @Num
      select cast(@NUM as text) NEWSUMNUM;
      return(0);
    end;

    select @settleno = max(no) from monthsettle;
    select @NewNum  = '';
    select @src = SRC, @OffsetView = OFFSETVIEW, @Filler = FILLER, @psr = PSR, @MstNote = IsNull(NOTE, ''), @Launch = LAUNCH, @CoverAll = COVERALL
    from PRMOFFSETAGM(nolock)
    where NUM = @num;

    declare cur_Agm cursor for
      select distinct G.billto From PRMOFFSETAGMDTL P(nolock), GOODS G(nolock)
      where P.GDGID = G.GID
        and P.NUM = @NUM;
    open cur_Agm;
    fetch next from cur_Agm into @vdrgid;
    while @@fetch_status = 0
    begin
      set @line = 1;
      set @BeginDate = null;
      set @EndDate = null;
      exec GENNEXTBILLNUM @PICLS = null, @PIBILL = 'PRMOFFSETAGM', @PONEWNUM = @NewBillNum output;
      declare cur_Agmdtl cursor for
        select D.GDGID, D.MUNIT, D.QPC, D.QPCSTR, D.AGMCNTINPRC, D.AGMPRC, D.DIFFPRC, D.TOPQTY, D.TOPAMT, D.NOTE, D.ASTART, D.AFINISH
        from PRMOFFSETAGMDTL D(nolock), GOODS G(nolock)
        where D.NUM = @NUM
          and D.GDGID = G.GID
          and G.BILLTO = @vdrgid
        order by D.LINE;

      open cur_Agmdtl;
      fetch next from cur_Agmdtl into @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish;

      while @@fetch_status = 0
      begin
       --新单据的开始日期、结束日期分别取单据明细最小的开始日期和最大的结束日期
          if (@BeginDate is null) or (@BeginDate > @AStart)
            set @BeginDate = @AStart;
          if (@EndDate is null) or (@EndDate < @AFinish)
            set @EndDate = @AFinish;

        insert into PRMOFFSETAGMDTL (NUM, LINE, GDGID, MUNIT, QPC, QPCSTR, AGMCNTINPRC, AGMPRC, DIFFPRC, TOPQTY, TOPAMT, NOTE, ASTART, AFINISH)
        values(@NewBillNum, @line, @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish);

        fetch next from cur_Agmdtl into @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish;
        set @line = @line + 1;
      end;

      close cur_Agmdtl;
      deallocate cur_Agmdtl;

      --插入促销补差协议汇总
      insert into PRMOFFSETAGM (NUM, VDRGID, BEGINDATE, ENDDATE, SRC, STAT, OFFSETVIEW, SETTLENO, PSR, FILLER,
                                FILDATE, RECCNT, DeptLmt, NOTE, LAUNCH, COVERALL)
      values (@NewBillNum, @vdrgid, @BeginDate, @EndDate, @Src, 0, @OffsetView, @settleno, @Psr, @Filler,
             getdate(), @line - 1, @DeptLmt, '由' + @Num + ' 号促销补差协议拆分而来：' + @MstNote, @Launch, @CoverAll);
      --插入促销补差协议结算单位
      insert into PRMOFFSETAGMLACSTORE(NUM, STOREGID)
        select @NewBillNum, STOREGID
        from PRMOFFSETAGMLACSTORE
        where NUM = @Num

      --插入促销补差协议促销单关系表
      insert into PRMOFFSETAGMPRM(NUM, SRCPRMNUM, SRCPRMCLS)
      select @NewBillNum, SRCPRMNUM, SRCPRMCLS
      from PRMOFFSETAGMPRM
      where NUM = @Num;

      --插入促销目录促销补差协议关系表
      insert into PRMDIRPRMOFFSETAGM(PRMSEQ, PRMOFFSETAGMNO)
      select PRMSEQ, @NewBillNum
      from PRMDIRPRMOFFSETAGM
      where PRMOFFSETAGMNO = @Num;

      if @NewNum = ''
        set @NewNum = @NewBillNum
      else
        set @NewNum = @NewNum + ',' + @NewBillNum;
      fetch next from cur_Agm into @vdrgid;

    end;
    close cur_Agm;
    deallocate cur_Agm;
  end
  else begin
  /*@optBreakByGdStoreBilltoOn为1时，商品按GDSTORE中的供应商进行拆分，遇到门店是总部时，仍按GOODS表的供应商拆分*/
    --若只有一家生效门店，且所有明细的供应商均一致，则不拆分
    if (select count(StoreGid) from PrmOffsetAgmLacStore S(NoLock) where Num = @Num) = 1
    begin
      if (select StoreGid from PrmOffsetAgmLacStore S(NoLock) where Num = @Num) = @FaZBGid
      begin
        if (select count(distinct(G.Billto)) from PRMOFFSETAGMDTL P(nolock), GOODS G(nolock)
           where P.GDGID = G.GID
             and P.NUM = @NUM) = 1
        begin
          select @NewNum = @Num ;
          update PRMOFFSETAGM
          set vdrgid = (select distinct goods.billto
          from goods(nolock), PRMOFFSETAGMDTL(nolock)
              where goods.gid = PRMOFFSETAGMDTL.gdgid
                and PRMOFFSETAGMDTL.num = @NUM)
          where Num = @Num
          select cast(@NUM as text) NEWSUMNUM;
          return(0);
        end
      end
      else
      begin
        if (select count(distinct(G.Billto))
            from PRMOFFSETAGMDTL P(nolock), GdStore G(nolock), PrmOffsetAgmLacStore S(NoLock)
            where P.GdGid = G.GdGid
            and G.StoreGid = S.StoreGid
            and S.Num = P.Num
            and P.NUM = @NUM) = 1
        begin
          select @NewNum = @Num ;
          update PRMOFFSETAGM
          set vdrgid = (select distinct G.Billto
          from PRMOFFSETAGMDTL P(NoLock), GdStore G(NoLock), PrmOffsetAgmLacStore S(NoLock)
              where P.GdGid = G.GdGid
                and G.StoreGid = S.StoreGid
                and S.Num = P.Num
                and P.num = @NUM)
          where Num = @Num
          select cast(@NUM as text) NEWSUMNUM;
          return(0);
        end
      end
    end

    select @settleno = max(no) from monthsettle;
    select @NewNum  = '';
    select @src = SRC, @OffsetView = OFFSETVIEW, @Filler = FILLER, @psr = PSR, @MstNote = IsNull(NOTE, ''), @Launch = LAUNCH, @CoverAll = COVERALL
    from PRMOFFSETAGM(nolock)
    where NUM = @num;

    declare c_store cursor for
      select storegid from PrmOffsetAgmLacStore(NoLock)
      where Num = @Num
    open c_store
    fetch next from c_store into @storegid
    while @@fetch_status = 0
    begin
      if @storegid <> @FaZBGid
        declare cur_Agm cursor for
          select distinct G.Billto
          From PRMOFFSETAGMDTL P(NoLock), GdStore G(NoLock)
          where P.GdGid = G.GdGid
            and G.StoreGid = @storegid
            and P.Num = @Num
      else
        declare cur_Agm cursor for
          select distinct G.Billto
          From PRMOFFSETAGMDTL P(NoLock), Goods G(NoLock)
          where P.GdGid = G.Gid
            and P.Num = @Num
      open cur_Agm;
      fetch next from cur_Agm into @vdrgid;
      while @@fetch_status = 0
      begin
        set @line = 1;
        set @BeginDate = null;
        set @EndDate = null;
        exec GENNEXTBILLNUM @PICLS = null, @PIBILL = 'PRMOFFSETAGM', @PONEWNUM = @NewBillNum output;

        if @storegid <> @FaZBGid
          declare cur_Agmdtl cursor for
            select D.GDGID, D.MUNIT, D.QPC, D.QPCSTR, D.AGMCNTINPRC, D.AGMPRC, D.DIFFPRC, D.TOPQTY, D.TOPAMT, D.NOTE, D.ASTART, D.AFINISH
            from PRMOFFSETAGMDTL D(nolock), GdStore G(nolock)
            where D.NUM = @NUM
              and D.GDGID = G.GdGid
              and G.BILLTO = @vdrgid
              and G.StoreGid = @StoreGid
            order by D.LINE
        else
          declare cur_Agmdtl cursor for
            select D.GDGID, D.MUNIT, D.QPC, D.QPCSTR, D.AGMCNTINPRC, D.AGMPRC, D.DIFFPRC, D.TOPQTY, D.TOPAMT, D.NOTE, D.ASTART, D.AFINISH
            from PRMOFFSETAGMDTL D(nolock), GOODS G(nolock)
            where D.NUM = @NUM
              and D.GDGID = G.GID
              and G.BILLTO = @vdrgid
            order by D.LINE;
        open cur_Agmdtl;
        fetch next from cur_Agmdtl into @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish;
        while @@fetch_status = 0
        begin
         --新单据的开始日期、结束日期分别取单据明细最小的开始日期和最大的结束日期
            if (@BeginDate is null) or (@BeginDate > @AStart)
              set @BeginDate = @AStart;
            if (@EndDate is null) or (@EndDate < @AFinish)
              set @EndDate = @AFinish;

          insert into PRMOFFSETAGMDTL (NUM, LINE, GDGID, MUNIT, QPC, QPCSTR, AGMCNTINPRC, AGMPRC, DIFFPRC, TOPQTY, TOPAMT, NOTE, ASTART, AFINISH)
          values(@NewBillNum, @line, @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish);

          fetch next from cur_Agmdtl into @Gdgid, @Mnuit, @Qpc, @QpcStr, @AgmcntInprc, @AgmPrc, @DiffPrc, @TopQty, @TopAmt, @Note, @AStart, @AFinish;
          set @line = @line + 1;
        end;
        close cur_Agmdtl;
        deallocate cur_Agmdtl;

        --插入促销补差协议汇总
        insert into PRMOFFSETAGM (NUM, VDRGID, BEGINDATE, ENDDATE, SRC, STAT, OFFSETVIEW, SETTLENO, PSR, FILLER,
                                  FILDATE, RECCNT, DeptLmt, NOTE, LAUNCH, COVERALL)
        values (@NewBillNum, @vdrgid, @BeginDate, @EndDate, @Src, 0, @OffsetView, @settleno, @Psr, @Filler,
               getdate(), @line - 1, @DeptLmt, '由' + @Num + ' 号促销补差协议拆分而来：' + @MstNote, @Launch, @CoverAll);
        --插入促销补差协议结算单位
        insert into PRMOFFSETAGMLACSTORE(NUM, STOREGID)
          select @NewBillNum, @StoreGid

        --插入促销补差协议促销单关系表
        insert into PRMOFFSETAGMPRM(NUM, SRCPRMNUM, SRCPRMCLS)
        select @NewBillNum, SRCPRMNUM, SRCPRMCLS
        from PRMOFFSETAGMPRM
        where NUM = @Num;

        --插入促销目录促销补差协议关系表
        insert into PRMDIRPRMOFFSETAGM(PRMSEQ, PRMOFFSETAGMNO)
        select PRMSEQ, @NewBillNum
        from PRMDIRPRMOFFSETAGM
        where PRMOFFSETAGMNO = @Num;

        if @NewNum = ''
          set @NewNum = @NewBillNum
        else
          set @NewNum = @NewNum + ',' + @NewBillNum;
        fetch next from cur_Agm into @vdrgid;
      end;
      close cur_Agm;
      deallocate cur_Agm;
      fetch next from c_store into @storegid
    end
    close c_store
    deallocate c_store
  end
  --原单据状态变为已终止
  update PRMOFFSETAGM
  set STAT = 1400,
      NOTE = '已拆分为以下单据：' + @NewNum
  where NUM = @Num;

  --记录日志
  exec PrmOffsetAgm_ADD_LOG @Num, 0, 1400, @Oper;

  select cast(@NewNum as text) NEWSUMNUM;
  return (0);
end;
GO
