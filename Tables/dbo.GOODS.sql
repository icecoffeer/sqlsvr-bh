CREATE TABLE [dbo].[GOODS]
(
[GID] [int] NOT NULL,
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__GOODS__SORT__1645E95F] DEFAULT ('-'),
[RTLPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__RTLPRC__173A0D98] DEFAULT (0),
[INPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__INPRC__182E31D1] DEFAULT (0),
[TAXRATE] [money] NOT NULL CONSTRAINT [DF__GOODS__TAXRATE__1922560A] DEFAULT (17),
[PROMOTE] [smallint] NOT NULL CONSTRAINT [DF__GOODS__PROMOTE__1A167A43] DEFAULT ((-1)),
[PRCTYPE] [smallint] NOT NULL CONSTRAINT [DF__GOODS__PRCTYPE__1B0A9E7C] DEFAULT (0),
[SALE] [smallint] NOT NULL CONSTRAINT [DF__GOODS__SALE__1BFEC2B5] DEFAULT (1),
[LSTINPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__LSTINPRC__1CF2E6EE] DEFAULT (0),
[INVPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__INVPRC__1DE70B27] DEFAULT (0),
[OLDINVPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__OLDINVPRC__1EDB2F60] DEFAULT (0),
[LWTRTLPRC] [money] NULL,
[WHSPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__WHSPRC__1FCF5399] DEFAULT (0),
[WRH] [int] NOT NULL CONSTRAINT [DF__GOODS__WRH__20C377D2] DEFAULT (1),
[ACNT] [smallint] NOT NULL CONSTRAINT [DF__GOODS__ACNT__21B79C0B] DEFAULT (1),
[PAYTODTL] [smallint] NOT NULL CONSTRAINT [DF__GOODS__PAYTODTL__22ABC044] DEFAULT (0),
[PAYRATE] [money] NULL CONSTRAINT [DF__GOODS__PAYRATE__239FE47D] DEFAULT (75),
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__GOODS__MUNIT__249408B6] DEFAULT (''),
[ISPKG] [smallint] NOT NULL CONSTRAINT [DF__GOODS__ISPKG__25882CEF] DEFAULT (0),
[GFT] [smallint] NOT NULL CONSTRAINT [DF__GOODS__GFT__267C5128] DEFAULT (0),
[QPC] [money] NOT NULL CONSTRAINT [DF__GOODS__QPC__27707561] DEFAULT (1),
[TM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MANUFACTOR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[MCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GPR] [money] NULL,
[LOWINV] [money] NULL,
[HIGHINV] [money] NULL,
[VALIDPERIOD] [smallint] NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__GOODS__CREATEDAT__2864999A] DEFAULT (getdate()),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CHKVD] [smallint] NOT NULL CONSTRAINT [DF__GOODS__CHKVD__2958BDD3] DEFAULT (0),
[SRC] [int] NOT NULL CONSTRAINT [DF__GOODS__SRC__2A4CE20C] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__GOODS__LSTUPDTIM__2B410645] DEFAULT (getdate()),
[DXPRC] [money] NOT NULL CONSTRAINT [DF__GOODS__DXPRC__2C352A7E] DEFAULT (0),
[BILLTO] [int] NOT NULL CONSTRAINT [DF__GOODS__BILLTO__2D294EB7] DEFAULT (1),
[AUTOORD] [smallint] NOT NULL CONSTRAINT [DF__GOODS__AUTOORD__2E1D72F0] DEFAULT (0),
[ORIGIN] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MBRPRC] [money] NULL,
[SALETAX] [money] NOT NULL CONSTRAINT [DF__GOODS__SALETAX__2F119729] DEFAULT (17),
[PSR] [int] NOT NULL CONSTRAINT [DF__GOODS__PSR__3005BB62] DEFAULT (1),
[F1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[F2] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F3] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__GOODS__FILLER__30F9DF9B] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__GOODS__MODIFIER__31EE03D4] DEFAULT (1),
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CODE2] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[MKTINPRC] [money] NULL,
[MKTRTLPRC] [money] NULL,
[CNTINPRC] [money] NULL,
[ALCQTY] [money] NULL CONSTRAINT [DF__GOODS__ALCQTY__32E2280D] DEFAULT (1),
[ISBIND] [smallint] NULL CONSTRAINT [DF__GOODS__ISBIND__33D64C46] DEFAULT (0),
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ISLTD] [smallint] NULL CONSTRAINT [DF__GOODS__ISLTD__7C91CFAB] DEFAULT (0),
[INVCOST] [money] NULL CONSTRAINT [DF__GOODS__INVCOST__2EB1A476] DEFAULT (0),
[bqtyprc] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[KEEPTYPE] [int] NOT NULL CONSTRAINT [DF__GOODS__KEEPTYPE__3BD6956A] DEFAULT (0),
[NEndTime] [datetime] NULL,
[NCanPay] [smallint] NOT NULL CONSTRAINT [DF__GOODS__NCanPay__56B5742F] DEFAULT (0),
[SSStart] [datetime] NULL,
[SSEnd] [datetime] NULL,
[Season] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[HQControl] [smallint] NOT NULL CONSTRAINT [DF__GOODS__HQControl__5991E0DA] DEFAULT (0),
[ORDCYCLE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ALCCTR] [int] NULL,
[isdisp] [smallint] NOT NULL CONSTRAINT [DF__goods__isdisp__52DAC1AA] DEFAULT (1),
[TOPRTLPRC] [money] NULL,
[LSTUPDTIME2] [datetime] NULL,
[UPCTRL] [int] NOT NULL CONSTRAINT [DF__GOODS__UPCTRL__67E26236] DEFAULT (0),
[MINLOWQTY] [money] NULL,
[F4] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SubmitType] [smallint] NULL,
[ORDERQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__GOODS__ORDERQTY] DEFAULT (1),
[ELIREASON] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NOAUTOORDREASON] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[SALCQTY] [int] NULL,
[SALCQSTART] [int] NULL,
[TJCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__goods__TJCODE__2537EB3E] DEFAULT ('-'),
[ISOFFSETGOODS] [smallint] NOT NULL CONSTRAINT [DF__GOODS__ISOFFSETG__01070E6E] DEFAULT (0),
[ZJSORT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[SHOPNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[Length] [money] NULL,
[Width] [money] NULL,
[Height] [money] NULL,
[SHORTNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[TAXSORT] [int] NULL,
[taxSortCode] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GD_DLT] on [dbo].[GOODS] for delete as  
begin  
  declare @storegid int,  
     @singlevdr smallint  
  if exists (select * from deleted where GID = 1)  
  begin  
    rollback transaction  
    raiserror('不能删除系统设定的记录', 16, 1)  
    return  
  end  
  if exists ( select * from INV where GDGID in (select GID from DELETED)  
    and (QTY <> 0 or TOTAL > 0.01 or TOTAL < -0.01 ))  
  begin  
    rollback transaction  
    raiserror( '本商品尚有库存, 不能删除.', 16, 1 )  
    return  
  end  
  
/*  2000-1-3 liqi  
    商品删除时，对大小包装商品不再删除PKG表，而是报错 */  
  if exists (select 1 from PKG where PGID in (select GID from deleted))  
  begin  
    rollback transaction  
    raiserror( '本商品是大包装商品, 不能删除. 若要删除，请先取消大小包装.', 16, 1 )  
    return  
  end  
  if exists (select 1 from PKG where EGID in (select GID from deleted))  
  begin  
    rollback transaction  
    raiserror( '本商品是小包装商品, 不能删除. 若要删除，请先取消大小包装.', 16, 1 )  
    return  
  end  
/*  
  if exists (select * from V_VDRYRPT, deleted  
    where V_VDRYRPT.BGDGID = deleted.GID  
    and (NPQTY <> 0 or NPTL <> 0)  
  ) begin  
    rollback transaction  
    raiserror('本商品尚未全部结清，不能删除。', 16, 1)  
    return  
  end  
*/  
  /* 2000-04-21 */  
  if exists ( select * from INV where GDGID in (select GID from DELETED)  
    and DSPQTY <> 0 )  
  begin  
    rollback transaction  
    raiserror( '本商品尚有未提数, 不能删除.', 16, 1 )  
    return  
  end  
  
  if exists ( select * from INV where GDGID in (select GID from DELETED)  
    and BCKQTY <> 0 )  
  begin  
    rollback transaction  
    raiserror( '本商品尚有退货数, 不能删除.', 16, 1 )  
    return  
  end  
  
  delete from GDINPUT from DELETED where GDINPUT.GID = DELETED.GID  
  
  --2006.4.6, Edited by ShenMin, Q6127, [一品多规格]商品资料改动  
  delete from GDQPC from DELETED where GDQPC.GID = DELETED.GID  
  
/*  2000-1-3 liqi  
    商品删除时，对大小包装商品不再删除PKG表，而是报错 */  
  /* delete from PKG from deleted where EGID = GID */  
  
  delete from INV from deleted where GDGID = GID  
/*  delete from VDRGD from deleted where GDGID = GID*/  
  delete from GDXLATE from deleted where GID = LGID  
  if (select RSTWRH from SYSTEM) = 0 begin  
    delete from VDRGD  
    from deleted  
    where BILLTO = VDRGID  
    and GID = GDGID  
    and VDRGD.WRH = deleted.WRH  
  end  
  update GOODSH set LSTUPDTIME = GETDATE()  
    where GID in ( select GID from deleted )  
--Added By Wang xin 2002-05-12  
  select @singlevdr = SINGLEVDR, @storegid = USERGID from system  
  if @singlevdr = 2  
   delete from  VDRGD2  
   from deleted  
   where VDRGD2.STOREGID = @storegid and VDRGD2.GDGID = deleted.GID  
  
  /*2002.08.18*/  
  delete from GDWRH  
    where GDGID in (select GID from deleted)  
  --删除便利一品多供应商增量更新表  
  if exists(select 1 from deleted where Alc = '直配')  
    if exists(select 1 from HDOPTION (nolock)  
     where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1)  
    begin  
        delete ECGDVDRSEND from deleted where GDGID = deleted.GID  
       insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)  
         select s.gid, a.BILLTO, a.GID, 1 from deleted a, store s(nolock)  
         where a.ALC = '直配'  
    end  
  
end

GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GD_INS] on [dbo].[GOODS] for insert as
begin
  declare
    @storegid int,
    @singlevdr smallint,
    @userproperty int

  insert into GOODSH
    select * from INSERTED

  INSERT INTO GDINPUT (GID,CODE)
    SELECT GID,CODE FROM INSERTED
    WHERE NOT EXISTS
    (SELECT 1 FROM GDINPUT WHERE GDINPUT.GID = INSERTED.GID AND GDINPUT.CODE = INSERTED.CODE)

  --ADD 百货管理
  if (select optionvalue from hdoption(nolock) where optioncaption = 'ADDGDINPUT' and moduleno = 713) = 1
  begin
    INSERT INTO GDINPUT (GID,CODE)
      SELECT GID,'P' + RTRIM(BRAND) + 'H' + RTRIM(MCODE) FROM INSERTED
      WHERE NOT EXISTS
      (SELECT 1 FROM GDINPUT WHERE GDINPUT.GID = INSERTED.GID AND GDINPUT.CODE = 'P' + RTRIM(INSERTED.BRAND) + 'H' + RTRIM(INSERTED.MCODE))
  end

--2006.4.6, Edited by ShenMin, Q6127, [一品多规格]商品资料改动
  INSERT INTO GDQPC (GID, MUNIT, RTLPRC, WHSPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC)
    SELECT GID, MUNIT, RTLPRC, WHSPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC FROM INSERTED
    WHERE NOT EXISTS
    (SELECT 1 FROM GDQPC WHERE GDQPC.GID = INSERTED.GID)

/* 20:46 98-10-13 李希明：
  应杭百要求，当新增一个商品时最新进价=核算价 */
  update GOODS set LSTINPRC = inserted.INPRC from inserted
  where GOODS.GID = inserted.GID
  update GOODSH set LSTINPRC = inserted.INPRC from inserted
  where GOODSH.GID = inserted.GID

  update goods set invprc = inserted.inprc from inserted where goods.gid = inserted.gid
  update goodsh set invprc = inserted.inprc from inserted where goodsh.gid = inserted.gid

  update GOODS set INPRC = inserted.DXPRC from inserted
  where GOODS.GID = inserted.GID and inserted.SALE = 2
  update GOODSH set INPRC = inserted.DXPRC from inserted
  where GOODSH.GID = inserted.GID and inserted.SALE = 2

  --add by jinlei 2005-09-23
  if (select optionvalue from hdoption(nolock) where optioncaption = 'UseF4') = 1
  begin
    declare @a varchar(50), @b varchar(50), @gid int

    declare c_goods cursor for
      select isnull(F4, ''), gid
      from inserted(nolock)
    open c_goods
    fetch next from c_goods into @a, @gid
    while @@fetch_status = 0
    begin
      if @a = ''
      begin
        update goods set MinLowQty = null where gid = @gid
        update goodsh set MinLowQty = null where gid = @gid
      end else begin
        set @b = convert(varchar(15), @gid)
        exec('update goods set MinLowQty = ' + @a + ' where gid = ' + @b)
        exec('update goodsh set MinLowQty = ' + @a + ' where gid = ' + @b)
      end
      fetch next from c_goods into @a, @gid
    end
    close c_goods
    deallocate c_goods
  end

  /* 2000-4-6 */
  if (select inprctax from system) = 1
  begin
    update GOODS
    set INPRC = inserted.RTLPRC * inserted.PAYRATE / 100.00
    from inserted
    where GOODS.GID = inserted.GID and inserted.SALE = 3
    update GOODSH
    set INPRC = inserted.RTLPRC * inserted.PAYRATE / 100.00
    from inserted
    where GOODSH.GID = inserted.GID and inserted.SALE = 3
  end else begin
    update GOODS
    set INPRC = inserted.RTLPRC * inserted.PAYRATE / 100.00 / (1+inserted.TAXRATE/100)
    from inserted
    where GOODS.GID = inserted.GID and inserted.SALE = 3
    update GOODSH
    set INPRC = inserted.RTLPRC * inserted.PAYRATE / 100.00 / (1+inserted.TAXRATE/100)
    from inserted
    where GOODSH.GID = inserted.GID and inserted.SALE = 3
  end

  insert into GDXLATE (NGID, LGID) select GID, GID from inserted
  if (select RSTWRH from SYSTEM) = 1 begin
    insert into VDRGD (VDRGID, GDGID, WRH)
    select BILLTO, GID, WRH
    from inserted
    where not exists (select 1 from VDRGD where GDGID = inserted.GID)
  end
--Added By Wang xin 2002-05-12
  select @singlevdr = SINGLEVDR, @storegid = USERGID,
    @userproperty = userproperty from system
  if @singlevdr = 2
    insert into VDRGD2 (STOREGID, VDRGID, GDGID)
    select @storegid, BILLTO, GID
    from inserted
    where not exists (select 1 from VDRGD2
      where STOREGID = @STOREGID
      and VDRGID = inserted.BILLTO
      and GDGID = inserted.GID)
--Added By hufeng 2005-04-11 3815 for 铜陵万花 给总部加上这个供应商
/*
   if @singlevdr = 2 and @userproperty & 16 = 16
    insert into VDRGD2 (STOREGID, VDRGID, GDGID)
    select @storegid, @STOREGID, GID
    from inserted
    where not exists (select 1 from VDRGD2
      where STOREGID = @STOREGID
      and VDRGID = @STOREGID
      and GDGID = inserted.GID)
*/
--Added by ShenMin 2005.5.27
--功能：按照hdoption的UptTime2Flag值设定更新LstUpdTime2值
  update goods set LstUpdTime2 = getdate()
  from inserted
  where goods.gid = inserted.gid
  update goodsh set LstUpdTime2 = getdate()
  from inserted
  where goodsh.gid = inserted.gid
  --2005.12.18 插入便利一品多供应商增量更新表
  if exists(select 1 from inserted where Alc = '直配')
  begin
    if exists(select 1 from HDOPTION (nolock)
      where MODULENO = 0 and OPTIONCAPTION = 'UseEcSendTrigger' and OPTIONVALUE = 1)
    begin
      delete ECGDVDRSEND from inserted where GDGID = inserted.GID
      insert into ECGDVDRSEND(STOREGID, VDRGID, GDGID, ACT)
        select s.gid, a.BILLTO, a.GID, 0 from inserted a, store s(nolock)
        where a.ALC = '直配'
    end
  end

  declare @intret int
  declare @msg varchar(255)
  declare @sort varchar(13)
  declare c_goodsupd cursor for
    select sort from inserted group by sort
  open c_goodsupd
  fetch next from c_goodsupd into @sort
  while @@fetch_status = 0
  begin
    exec GetSortLimit @sort, @intret output, @msg output
    if @intret <> 0
    begin
      close c_goodsupd
      deallocate c_goodsupd
      rollback transaction
      raiserror(@msg, 16, 1)
      return
    end
    fetch next from c_goodsupd into @sort
  end
  close c_goodsupd
  deallocate c_goodsupd

--Added by Zhuhaohui 2007.12.14 新增商品消息提醒

  declare @title varchar(500)
  declare @code varchar(13),
          @name varchar(50)
  declare @usergid int,
          @username varchar(20)
  declare c_ins CURSOR for
    select GID, RTRIM(CODE), RTRIM(Name), Filler from inserted

  open c_ins
  fetch next from c_ins into @gid, @code, @name, @usergid
  while @@fetch_status = 0
  begin
    --用户信息
    select @username=RTRIM(Name) from EMPLOYEE where GID=@usergid

    --触发提醒
    set @title = '用户[' + @username + ']新增了商品[' + @name + '-' + @code + ']'
    execute GD_MSG_PROMPT @gid, @usergid, @title, '商品新增提醒'

    fetch next from c_ins into @gid, @code, @name, @usergid
  end
  close c_ins
  deallocate c_ins

--end of 新增商品消息提醒
--added by zz 090623, 新增商品取供应商销售计划完成联销率调整
  if (select optionvalue from hdoption(nolock) where optioncaption = 'ShowRateCond' and moduleno = 3004) = 1
  begin
    declare
      @Store int,
      @payrate money,
      @amtValue money,
      @Dept varchar(20),--结算组
      @F1 varchar(20),
      @gdgid int,
      @Wrh int,
      @billto int,
      @opt_SettleDeptLimit int,
      @opt_SettleDeptMethod int,
      @addrate money,
      @enddate datetime,
      @eonnum varchar(14)

    EXEC OptReadInt 0, 'SettleDeptLimit', 0, @opt_SettleDeptLimit output
    EXEC OptReadInt 0, 'AutoGetSettleDeptMethod', 0, @opt_SettleDeptMethod output
    select @store = usergid from system(nolock)

    declare c_rate cursor for
      select GID, F1, isnull(Wrh, 1), isnull(Billto, 1), PayRate
      from inserted(nolock) where Sale = 3
    open c_rate
    fetch next from c_rate into @gdgid, @F1, @Wrh, @Billto, @payrate
    while @@fetch_status = 0
    begin
      --取结算组
      if (@opt_SettleDeptLimit = 1)
      begin
        IF @opt_SettleDeptMethod = 1
          select @dept = code from SETTLEDEPTDEPT(nolock) where deptcode = @f1
        else IF @opt_SettleDeptMethod = 2
          select @dept = code from SETTLEDEPTVDR(nolock) where vdrgid = @billto
        else
          select @dept = code from SETTLEDEPTWRH(nolock) where wrhgid = @wrh
      end

      --检查是否存在已生效的联销率调整记录
      if exists(select 1 from CTCNTR a(nolock), CTCNTRRATECONDPLAN b(nolock)
        where a.num = b.num and a.version = b.version and a.tag = 1
         and b.vendor = @billto and b.dept = @dept and b.exestat = 1)
      begin
        select @amtValue = isnull(max(b.EXPAMT), 0)
          from CTCNTR a(nolock), CTCNTRRATECONDPLAN b(nolock)
          where a.num = b.num and a.version = b.version and a.tag = 1
          and b.vendor = @billto and b.dept = @dept and b.exestat = 1
        select @addrate = b.addrate, @enddate = b.enddate, @eonnum = b.exebillinfo
          from CTCNTR a(nolock), CTCNTRRATECONDPLAN b(nolock)
        where a.num = b.num and a.version = b.version and a.tag = 1
          and b.vendor = @billto and b.dept = @dept and b.exestat = 1 and b.EXPAMT = @amtValue

        --写入联销率促销当前值
        delete from PAYRATEPRICE where gdgid = @gdgid
        insert into PAYRATEPRICE(storegid,gdgid,astart,afinish,payrate,srcnum)
        values(@store, @gdgid, getdate(), @enddate, @payrate + @addrate, @eonnum)
      end

      fetch next from c_rate into @gdgid, @F1, @Wrh, @Billto, @payrate
    end
    close c_rate
    deallocate c_rate
  end
--end of 新增商品取供应商销售计划完成联销率调整
 --added by zhangzhen 090813,增加价格组商品
 /*if exists(select 1 from RTLPRCGRP)
 begin
   declare
     @RtlPrc money,
     @Qpc Money,
     @QpcStr varchar(15),
     @MUNIT varchar(10)

   set @QpcStr = '1*1'
   declare c_grp CURSOR for
     select GID, RTRIM(CODE), RtlPrc, Qpc, MUNIT from inserted
   open c_grp
   fetch next from c_grp into @Gid, @Code, @RtlPrc, @Qpc, @MUNIT
   while @@fetch_status = 0
   begin
     delete from RTLPRCGRPGD where GDGID = @Gid and GDCODE = @Code

     INSERT INTO RTLPRCGRPGD(GCODE, GDGID, GDCODE, RTLPRC, MUNIT, QPC, QPCSTR, LSTUPDTIME)
     SELECT CODE, @Gid, @Code, @RtlPrc * Ratio / 100, @MUNIT, @Qpc, @QpcStr, getdate()
     from RTLPRCGRP

     fetch next from c_grp into @Gid, @Code, @RtlPrc, @Qpc, @MUNIT
   end
   close c_grp
   deallocate c_grp
 end*/
 --added end 增加价格组商品
end
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[GD_INS_OL] on [dbo].[GOODS] for insert as
begin
  declare
  	@Gstoregid int, 
    @Gwrhgid int

  --begin 有新增商品资料，要更新下发资料表。
  if EXISTS (select * from PS3_INVUPDGOODS where gdgid in(select gid from INSERTED))
  begin 
    update PS3_INVUPDGOODS set LSTUPDTIME = getdate() from INSERTED where PS3_INVUPDGOODS.gdgid = INSERTED.GID
  end
  else
  begin 
    select @Gstoregid = usergid, @Gwrhgid = DFTWRH from system
    insert into PS3_INVUPDGOODS 
    select @Gstoregid, @Gwrhgid, GID, getdate() from INSERTED
  end
end
GO
ALTER TABLE [dbo].[GOODS] WITH NOCHECK ADD CONSTRAINT [零售价不得低于最低售价] CHECK NOT FOR REPLICATION (([PRCTYPE]=(1) OR [RTLPRC]>=[LWTRTLPRC] OR [LWTRTLPRC] IS NULL))
GO
ALTER TABLE [dbo].[GOODS] ADD CONSTRAINT [PK__GOODS__1551C526] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GOODS] ADD CONSTRAINT [UQ__GOODS__145DA0ED] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [goods_f1_idx] ON [dbo].[GOODS] ([F1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[DF_GOODS_BRAND]', N'[dbo].[GOODS].[BRAND]'
GO
