CREATE TABLE [dbo].[PJ]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[BWRH] [int] NULL,
[BGDGID] [int] NULL,
[BVDRGID] [int] NULL,
[BCSTGID] [int] NULL,
[BPSRGID] [int] NULL,
[BSLRGID] [int] NULL,
[ADATE] [datetime] NULL,
[BPOSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ASETTLENO] [int] NULL,
[ASTORE] [int] NULL,
[PJ_Q] [money] NULL CONSTRAINT [DF__PJ__PJ_Q__61DC42C1] DEFAULT (0),
[PJ_A] [money] NULL CONSTRAINT [DF__PJ__PJ_A__62D066FA] DEFAULT (0),
[PJ_T] [money] NULL CONSTRAINT [DF__PJ__PJ_T__63C48B33] DEFAULT (0),
[PJ_I] [money] NULL CONSTRAINT [DF__PJ__PJ_I__64B8AF6C] DEFAULT (0),
[PJ_R] [money] NULL CONSTRAINT [DF__PJ__PJ_R__65ACD3A5] DEFAULT (0),
[PJ_Q_B] [money] NULL CONSTRAINT [DF__PJ__PJ_Q_B__66A0F7DE] DEFAULT (0),
[PJ_A_B] [money] NULL CONSTRAINT [DF__PJ__PJ_A_B__67951C17] DEFAULT (0),
[PJ_T_B] [money] NULL CONSTRAINT [DF__PJ__PJ_T_B__68894050] DEFAULT (0),
[PJ_I_B] [money] NULL CONSTRAINT [DF__PJ__PJ_I_B__697D6489] DEFAULT (0),
[PJ_R_B] [money] NULL CONSTRAINT [DF__PJ__PJ_R_B__6A7188C2] DEFAULT (0),
[PJ_Q_S] [money] NULL CONSTRAINT [DF__PJ__PJ_Q_S__6B65ACFB] DEFAULT (0),
[PJ_A_S] [money] NULL CONSTRAINT [DF__PJ__PJ_A_S__6C59D134] DEFAULT (0),
[PJ_T_S] [money] NULL CONSTRAINT [DF__PJ__PJ_T_S__6D4DF56D] DEFAULT (0),
[PJ_I_S] [money] NULL CONSTRAINT [DF__PJ__PJ_I_S__6E4219A6] DEFAULT (0),
[PJ_R_S] [money] NULL CONSTRAINT [DF__PJ__PJ_R_S__6F363DDF] DEFAULT (0),
[PJS_Q] [money] NULL CONSTRAINT [DF__PJ__PJS_Q__702A6218] DEFAULT (0),
[PJS_A] [money] NULL CONSTRAINT [DF__PJ__PJS_A__711E8651] DEFAULT (0),
[PJS_T] [money] NULL CONSTRAINT [DF__PJ__PJS_T__7212AA8A] DEFAULT (0),
[PJS_I] [money] NULL CONSTRAINT [DF__PJ__PJS_I__7306CEC3] DEFAULT (0),
[PJS_R] [money] NULL CONSTRAINT [DF__PJ__PJS_R__73FAF2FC] DEFAULT (0),
[PJS_Q_B] [money] NULL CONSTRAINT [DF__PJ__PJS_Q_B__74EF1735] DEFAULT (0),
[PJS_A_B] [money] NULL CONSTRAINT [DF__PJ__PJS_A_B__75E33B6E] DEFAULT (0),
[PJS_T_B] [money] NULL CONSTRAINT [DF__PJ__PJS_T_B__76D75FA7] DEFAULT (0),
[PJS_I_B] [money] NULL CONSTRAINT [DF__PJ__PJS_I_B__77CB83E0] DEFAULT (0),
[PJS_R_B] [money] NULL CONSTRAINT [DF__PJ__PJS_R_B__78BFA819] DEFAULT (0),
[PJS_Q_S] [money] NULL CONSTRAINT [DF__PJ__PJS_Q_S__79B3CC52] DEFAULT (0),
[PJS_A_S] [money] NULL CONSTRAINT [DF__PJ__PJS_A_S__7AA7F08B] DEFAULT (0),
[PJS_T_S] [money] NULL CONSTRAINT [DF__PJ__PJS_T_S__7B9C14C4] DEFAULT (0),
[PJS_I_S] [money] NULL CONSTRAINT [DF__PJ__PJS_I_S__7C9038FD] DEFAULT (0),
[PJS_R_S] [money] NULL CONSTRAINT [DF__PJ__PJS_R_S__7D845D36] DEFAULT (0),
[PJY_Q] [money] NULL CONSTRAINT [DF__PJ__PJY_Q__7E78816F] DEFAULT (0),
[PJY_A] [money] NULL CONSTRAINT [DF__PJ__PJY_A__7F6CA5A8] DEFAULT (0),
[PJY_T] [money] NULL CONSTRAINT [DF__PJ__PJY_T__0060C9E1] DEFAULT (0),
[PJY_I] [money] NULL CONSTRAINT [DF__PJ__PJY_I__0154EE1A] DEFAULT (0),
[PJY_R] [money] NULL CONSTRAINT [DF__PJ__PJY_R__02491253] DEFAULT (0),
[PJY_Q_B] [money] NULL CONSTRAINT [DF__PJ__PJY_Q_B__033D368C] DEFAULT (0),
[PJY_A_B] [money] NULL CONSTRAINT [DF__PJ__PJY_A_B__04315AC5] DEFAULT (0),
[PJY_T_B] [money] NULL CONSTRAINT [DF__PJ__PJY_T_B__05257EFE] DEFAULT (0),
[PJY_I_B] [money] NULL CONSTRAINT [DF__PJ__PJY_I_B__0619A337] DEFAULT (0),
[PJY_R_B] [money] NULL CONSTRAINT [DF__PJ__PJY_R_B__070DC770] DEFAULT (0),
[PJY_Q_S] [money] NULL CONSTRAINT [DF__PJ__PJY_Q_S__0801EBA9] DEFAULT (0),
[PJY_A_S] [money] NULL CONSTRAINT [DF__PJ__PJY_A_S__08F60FE2] DEFAULT (0),
[PJY_T_S] [money] NULL CONSTRAINT [DF__PJ__PJY_T_S__09EA341B] DEFAULT (0),
[PJY_I_S] [money] NULL CONSTRAINT [DF__PJ__PJY_I_S__0ADE5854] DEFAULT (0),
[PJY_R_S] [money] NULL CONSTRAINT [DF__PJ__PJY_R_S__0BD27C8D] DEFAULT (0),
[PJT_Q] [money] NULL CONSTRAINT [DF__PJ__PJT_Q__0CC6A0C6] DEFAULT (0),
[PJT_A] [money] NULL CONSTRAINT [DF__PJ__PJT_A__0DBAC4FF] DEFAULT (0),
[PJT_T] [money] NULL CONSTRAINT [DF__PJ__PJT_T__0EAEE938] DEFAULT (0),
[PJT_I] [money] NULL CONSTRAINT [DF__PJ__PJT_I__0FA30D71] DEFAULT (0),
[PJT_R] [money] NULL CONSTRAINT [DF__PJ__PJT_R__109731AA] DEFAULT (0),
[PJT_Q_B] [money] NULL CONSTRAINT [DF__PJ__PJT_Q_B__118B55E3] DEFAULT (0),
[PJT_A_B] [money] NULL CONSTRAINT [DF__PJ__PJT_A_B__127F7A1C] DEFAULT (0),
[PJT_T_B] [money] NULL CONSTRAINT [DF__PJ__PJT_T_B__13739E55] DEFAULT (0),
[PJT_I_B] [money] NULL CONSTRAINT [DF__PJ__PJT_I_B__1467C28E] DEFAULT (0),
[PJT_R_B] [money] NULL CONSTRAINT [DF__PJ__PJT_R_B__155BE6C7] DEFAULT (0),
[PJT_Q_S] [money] NULL CONSTRAINT [DF__PJ__PJT_Q_S__16500B00] DEFAULT (0),
[PJT_A_S] [money] NULL CONSTRAINT [DF__PJ__PJT_A_S__17442F39] DEFAULT (0),
[PJT_T_S] [money] NULL CONSTRAINT [DF__PJ__PJT_T_S__18385372] DEFAULT (0),
[PJT_I_S] [money] NULL CONSTRAINT [DF__PJ__PJT_I_S__192C77AB] DEFAULT (0),
[PJT_R_S] [money] NULL CONSTRAINT [DF__PJ__PJT_R_S__1A209BE4] DEFAULT (0),
[ACNT] [smallint] NULL CONSTRAINT [DF__PJ__ACNT__1B14C01D] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EPJ_INS] on [dbo].[PJ] instead of insert as
begin
  -- 进货日,月,年报
  -- 库存调整日,月,年报

  declare
    @return_status int,
    @settleno int,
    @date datetime,
    @wrh int,
    @gdgid int,
    @vdrgid int,
    @clngid int,
    @slrgid int,
    @psrgid int,
    @posno char(10),
    @store int,
    @mode smallint

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('EPJ_INS', 16, 1)
    return
  end
  -- 取关键字
  select
    @date = ADATE,
    @settleno = ASETTLENO,
    @wrh = BWRH,
    @gdgid = BGDGID,
    @vdrgid = BVDRGID,
    @clngid = BCSTGID,
    @slrgid = BSLRGID,
    @psrgid = BPSRGID,
    @posno = BPOSNO,
    @mode = ACNT,
    @store = ASTORE
    from inserted

  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  declare @yno int
  select @yno = YNO from V_YM where MNO = @settleno

  if @mode = 0 or @mode = 2 begin
    -- 进货日报,月报,年报
    if (select
        PJ_Q + PJ_Q_B + PJ_Q_S
        + PJT_Q + PJT_Q_B + PJT_Q_S
        + PJ_A + PJ_A_B + PJ_A_S + PJ_T + PJ_T_B + PJ_T_S
        + PJT_T + PJT_T_B + PJT_T_S + PJT_A + PJT_A_B + PJT_A_S
        + PJ_I + PJ_I_B + PJ_I_S
        + PJT_I + PJT_I_B + PJT_I_S
        + PJ_R + PJ_R_B + PJ_R_S
        + PJT_R + PJT_R_B + PJT_R_S
    from inserted) <> 0 begin
      execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
      -- 进货日报
      if not exists ( select * from INDRPTI
      where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INDRPTI (ASETTLENO, ADATE, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@settleno, @date, @gdgid, @vdrgid, @wrh, @store)
      end
      if not exists ( select * from INDRPT
      where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INDRPT (ASETTLENO, ADATE, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@settleno, @date, @gdgid, @vdrgid, @wrh, @store)
      end
      update INDRPT set
        DQ2 = DQ2 + PJ_Q + PJ_Q_B + PJ_Q_S,
        DQ4 = DQ4 + PJT_Q + PJT_Q_B + PJT_Q_S,
        DT2 = convert( dec(20,2), DT2 + PJ_A + PJ_A_B + PJ_A_S + PJ_T + PJ_T_B + PJ_T_S ),
        DT4 = convert( dec(20,2), DT4 + PJT_T + PJT_T_B + PJT_T_S + PJT_A + PJT_A_B + PJT_A_S ),
        DI2 = convert( dec(20,2), DI2 + PJ_I + PJ_I_B + PJ_I_S ),
        DI4 = convert( dec(20,2), DI4 + PJT_I + PJT_I_B + PJT_I_S ),
        DR2 = convert( dec(20,2), DR2 + PJ_R + PJ_R_B + PJ_R_S ),
        DR4 = convert( dec(20,2), DR4 + PJT_R + PJT_R_B + PJT_R_S ),
        LSTUPDTIME = getdate()
      from inserted
      where INDRPT.ASETTLENO = @settleno and INDRPT.ADATE = @date
      and INDRPT.BGDGID = @gdgid and INDRPT.BVDRGID = @vdrgid
      and INDRPT.BWRH = @wrh
      and INDRPT.ASTORE = @store
      -- 进货月报
      if not exists ( select * from INMRPT
      where ASETTLENO = @settleno and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INMRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@settleno, @gdgid, @vdrgid, @wrh, @store)
      end
      update INMRPT set
        DQ2 = DQ2 + PJ_Q + PJ_Q_B + PJ_Q_S,
        DQ4 = DQ4 + PJT_Q + PJT_Q_B + PJT_Q_S,
        DT2 = convert( dec(20,2), DT2 + PJ_A + PJ_A_B + PJ_A_S + PJ_T + PJ_T_B + PJ_T_S ),
        DT4 = convert( dec(20,2), DT4 + PJT_T + PJT_T_B + PJT_T_S + PJT_A + PJT_A_B + PJT_A_S ),
        DI2 = convert( dec(20,2), DI2 + PJ_I + PJ_I_B + PJ_I_S ),
        DI4 = convert( dec(20,2), DI4 + PJT_I + PJT_I_B + PJT_I_S ),
        DR2 = convert( dec(20,2), DR2 + PJ_R + PJ_R_B + PJ_R_S ),
        DR4 = convert( dec(20,2), DR4 + PJT_R + PJT_R_B + PJT_R_S )
      from inserted
      where INMRPT.ASETTLENO = @settleno and INMRPT.BGDGID = @gdgid
      and INMRPT.BVDRGID = @vdrgid and INMRPT.BWRH = @wrh
      and INMRPT.ASTORE = @store
      -- 进货年报
      if not exists ( select * from INYRPT
      where ASETTLENO = @yno and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INYRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@yno, @gdgid, @vdrgid, @wrh, @store)
      end
      update INYRPT set
        DQ2 = DQ2 + PJ_Q + PJ_Q_B + PJ_Q_S,
        DQ4 = DQ4 + PJT_Q + PJT_Q_B + PJT_Q_S,
        DT2 = convert( dec(20,2), DT2 + PJ_A + PJ_A_B + PJ_A_S + PJ_T + PJ_T_B + PJ_T_S ),
        DT4 = convert( dec(20,2), DT4 + PJT_T + PJT_T_B + PJT_T_S + PJT_A + PJT_A_B + PJT_A_S ),
        DI2 = convert( dec(20,2), DI2 + PJ_I + PJ_I_B + PJ_I_S ),
        DI4 = convert( dec(20,2), DI4 + PJT_I + PJT_I_B + PJT_I_S ),
        DR2 = convert( dec(20,2), DR2 + PJ_R + PJ_R_B + PJ_R_S ),
        DR4 = convert( dec(20,2), DR4 + PJT_R + PJT_R_B + PJT_R_S )
      from inserted
      where INYRPT.ASETTLENO = @yno and INYRPT.BGDGID = @gdgid
      and INYRPT.BVDRGID = @vdrgid and INYRPT.BWRH = @wrh
      and INYRPT.ASTORE = @store
    end

    -- 库存调整日报,月报,年报
    if (select
        PJS_Q + PJS_Q_B + PJS_Q_S + PJY_Q + PJY_Q_B + PJY_Q_S
        + PJS_I + PJS_I_B + PJS_I_S + PJY_I + PJY_I_B + PJY_I_S
        + PJS_R + PJS_R_B + PJS_R_S + PJY_R + PJY_R_B + PJY_R_S
    from inserted) <> 0 begin
      execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
      -- 库存调整日报
      if not exists ( select * from INVCHGDRPTI
      where ASETTLENO = @settleno and ADATE = @date
      and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INVCHGDRPTI (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE)
        values (@settleno, @date, @gdgid, @wrh, @store)
      end
      if not exists ( select * from INVCHGDRPT
      where ASETTLENO = @settleno and ADATE = @date
      and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INVCHGDRPT (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE)
        values (@settleno, @date, @gdgid, @wrh, @store)
      end
      update INVCHGDRPT set
        DQ1 = DQ1 - (PJS_Q + PJS_Q_B + PJS_Q_S) + PJY_Q + PJY_Q_B + PJY_Q_S,
        DI1 = convert( dec(20,2), DI1 - (PJS_I + PJS_I_B + PJS_I_S) + PJY_I + PJY_I_B + PJY_I_S ),
        DR1 = convert( dec(20,2), DR1 - (PJS_R + PJS_R_B + PJS_R_S) + PJY_R + PJY_R_B + PJY_R_S ),
        LSTUPDTIME = getdate()
      from inserted
      where INVCHGDRPT.ASETTLENO = @settleno and INVCHGDRPT.ADATE = @date
      and INVCHGDRPT.BGDGID = @gdgid and INVCHGDRPT.BWRH = @wrh
      and INVCHGDRPT.ASTORE = @store
      -- 库存调整月报
      if not exists ( select * from INVCHGMRPT
      where ASETTLENO = @settleno and BGDGID = @gdgid and BWRH = @wrh
      and ASTORE = @store) begin
        insert into INVCHGMRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
        values (@settleno, @gdgid, @wrh, @store)
      end
      update INVCHGMRPT set
        DQ1 = DQ1 - (PJS_Q + PJS_Q_B + PJS_Q_S) + PJY_Q + PJY_Q_B + PJY_Q_S,
        DI1 = convert( dec(20,2), DI1 - (PJS_I + PJS_I_B + PJS_I_S) + PJY_I + PJY_I_B + PJY_I_S ),
        DR1 = convert( dec(20,2), DR1 - (PJS_R + PJS_R_B + PJS_R_S) + PJY_R + PJY_R_B + PJY_R_S )
      from inserted
      where INVCHGMRPT.ASETTLENO = @settleno and INVCHGMRPT.BGDGID = @gdgid
      and INVCHGMRPT.BWRH = @wrh
      and INVCHGMRPT.ASTORE = @store
      -- 库存调整年报
      if not exists ( select * from INVCHGYRPT
      where ASETTLENO = @yno and BGDGID = @gdgid and BWRH = @wrh
      and ASTORE = @store) begin
        insert into INVCHGYRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
        values (@yno, @gdgid, @wrh, @store)
      end
      update INVCHGYRPT set
        DQ1 = DQ1 - (PJS_Q + PJS_Q_B + PJS_Q_S) + PJY_Q + PJY_Q_B + PJY_Q_S,
        DI1 = convert( dec(20,2), DI1 - (PJS_I + PJS_I_B + PJS_I_S) + PJY_I + PJY_I_B + PJY_I_S ),
        DR1 = convert( dec(20,2), DR1 - (PJS_R + PJS_R_B + PJS_R_S) + PJY_R + PJY_R_B + PJY_R_S )
      from inserted
      where INVCHGYRPT.ASETTLENO = @yno and INVCHGYRPT.BGDGID = @gdgid
      and INVCHGYRPT.BWRH = @wrh
      and INVCHGYRPT.ASTORE = @store
    end
  end /* @mode = 0 or 2 */
  --delete from PJ

  if @mode = 1 or @mode = 2 begin
    -- 供应商报表
    if (select
        PJ_Q + PJ_Q_B + PJ_Q_S
        + PJT_Q + PJT_Q_B + PJT_Q_S
        + PJ_A + PJ_A_B + PJ_A_S + PJ_T + PJ_T_B + PJ_T_S
        + PJT_T + PJT_T_B + PJT_T_S + PJT_A + PJT_A_B + PJT_A_S
        + PJ_I + PJ_I_B + PJ_I_S
        + PJT_I + PJT_I_B + PJT_I_S
        + PJ_R + PJ_R_B + PJ_R_S
        + PJT_R + PJT_R_B + PJT_R_S
    from inserted) <> 0 begin
      /* 供应商报表 */
      -- 增加日报记录
      if not exists ( select * from VDRDRPTI
      where ASETTLENO = @settleno and BVDRGID = @vdrgid and ADATE = @date
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into VDRDRPTI (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE, ADATE)
        values (@settleno, @vdrgid, @wrh, @gdgid, @store, @date)
      end
      if not exists ( select * from VDRDRPT
      where ASETTLENO = @settleno and BVDRGID = @vdrgid and ADATE = @date
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into VDRDRPT (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE, ADATE)
        values (@settleno, @vdrgid, @wrh, @gdgid, @store, @date)
      end
      -- 增加月报记录
      if not exists ( select * from VDRMRPT
      where ASETTLENO = @settleno and BVDRGID = @vdrgid
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into VDRMRPT (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE)
        values (@settleno, @vdrgid, @wrh, @gdgid, @store)
      end
      -- 增加年报记录
      if not exists ( select * from VDRYRPT
      where ASETTLENO = @yno and BVDRGID = @vdrgid
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into VDRYRPT (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE)
        values (@yno, @vdrgid, @wrh, @gdgid, @store)
      end
      if (select SALE from GOODSH where GID = @gdgid) = 1 begin
        -- 经销
        -- 供应商帐款日报
        update VDRDRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) ),
          DQ3 = DQ3 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) ),
          DQ3 = DQ3 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) ),
          DQ3 = DQ3 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end else begin
        -- 代销/联销
        -- 供应商帐款日报
        update VDRDRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (PJ_Q + PJ_Q_B + PJ_Q_S)
                    - (PJT_Q + PJT_Q_B + PJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (PJ_A + PJ_A_B + PJ_A_S)
                    + (PJ_T + PJ_T_B + PJ_T_S)
                    - (PJT_A + PJT_A_B + PJT_A_S)
                    - (PJT_T + PJT_T_B + PJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end
    end /* of select <> 0 */
  end /* of mode = 1 or 2 */
end
GO
