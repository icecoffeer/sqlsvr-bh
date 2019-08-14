CREATE TABLE [dbo].[ZJ]
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
[ZJ_Q] [money] NULL CONSTRAINT [DF__ZJ__ZJ_Q__26BB7CF3] DEFAULT (0),
[ZJ_A] [money] NULL CONSTRAINT [DF__ZJ__ZJ_A__27AFA12C] DEFAULT (0),
[ZJ_T] [money] NULL CONSTRAINT [DF__ZJ__ZJ_T__28A3C565] DEFAULT (0),
[ZJ_I] [money] NULL CONSTRAINT [DF__ZJ__ZJ_I__2997E99E] DEFAULT (0),
[ZJ_R] [money] NULL CONSTRAINT [DF__ZJ__ZJ_R__2A8C0DD7] DEFAULT (0),
[ZJ_Q_B] [money] NULL CONSTRAINT [DF__ZJ__ZJ_Q_B__2B803210] DEFAULT (0),
[ZJ_A_B] [money] NULL CONSTRAINT [DF__ZJ__ZJ_A_B__2C745649] DEFAULT (0),
[ZJ_T_B] [money] NULL CONSTRAINT [DF__ZJ__ZJ_T_B__2D687A82] DEFAULT (0),
[ZJ_I_B] [money] NULL CONSTRAINT [DF__ZJ__ZJ_I_B__2E5C9EBB] DEFAULT (0),
[ZJ_R_B] [money] NULL CONSTRAINT [DF__ZJ__ZJ_R_B__2F50C2F4] DEFAULT (0),
[ZJ_Q_S] [money] NULL CONSTRAINT [DF__ZJ__ZJ_Q_S__3044E72D] DEFAULT (0),
[ZJ_A_S] [money] NULL CONSTRAINT [DF__ZJ__ZJ_A_S__31390B66] DEFAULT (0),
[ZJ_T_S] [money] NULL CONSTRAINT [DF__ZJ__ZJ_T_S__322D2F9F] DEFAULT (0),
[ZJ_I_S] [money] NULL CONSTRAINT [DF__ZJ__ZJ_I_S__332153D8] DEFAULT (0),
[ZJ_R_S] [money] NULL CONSTRAINT [DF__ZJ__ZJ_R_S__34157811] DEFAULT (0),
[ZJS_Q] [money] NULL CONSTRAINT [DF__ZJ__ZJS_Q__35099C4A] DEFAULT (0),
[ZJS_A] [money] NULL CONSTRAINT [DF__ZJ__ZJS_A__35FDC083] DEFAULT (0),
[ZJS_T] [money] NULL CONSTRAINT [DF__ZJ__ZJS_T__36F1E4BC] DEFAULT (0),
[ZJS_I] [money] NULL CONSTRAINT [DF__ZJ__ZJS_I__37E608F5] DEFAULT (0),
[ZJS_R] [money] NULL CONSTRAINT [DF__ZJ__ZJS_R__38DA2D2E] DEFAULT (0),
[ZJS_Q_B] [money] NULL CONSTRAINT [DF__ZJ__ZJS_Q_B__39CE5167] DEFAULT (0),
[ZJS_A_B] [money] NULL CONSTRAINT [DF__ZJ__ZJS_A_B__3AC275A0] DEFAULT (0),
[ZJS_T_B] [money] NULL CONSTRAINT [DF__ZJ__ZJS_T_B__3BB699D9] DEFAULT (0),
[ZJS_I_B] [money] NULL CONSTRAINT [DF__ZJ__ZJS_I_B__3CAABE12] DEFAULT (0),
[ZJS_R_B] [money] NULL CONSTRAINT [DF__ZJ__ZJS_R_B__3D9EE24B] DEFAULT (0),
[ZJS_Q_S] [money] NULL CONSTRAINT [DF__ZJ__ZJS_Q_S__3E930684] DEFAULT (0),
[ZJS_A_S] [money] NULL CONSTRAINT [DF__ZJ__ZJS_A_S__3F872ABD] DEFAULT (0),
[ZJS_T_S] [money] NULL CONSTRAINT [DF__ZJ__ZJS_T_S__407B4EF6] DEFAULT (0),
[ZJS_I_S] [money] NULL CONSTRAINT [DF__ZJ__ZJS_I_S__416F732F] DEFAULT (0),
[ZJS_R_S] [money] NULL CONSTRAINT [DF__ZJ__ZJS_R_S__42639768] DEFAULT (0),
[ZJY_Q] [money] NULL CONSTRAINT [DF__ZJ__ZJY_Q__4357BBA1] DEFAULT (0),
[ZJY_A] [money] NULL CONSTRAINT [DF__ZJ__ZJY_A__444BDFDA] DEFAULT (0),
[ZJY_T] [money] NULL CONSTRAINT [DF__ZJ__ZJY_T__45400413] DEFAULT (0),
[ZJY_I] [money] NULL CONSTRAINT [DF__ZJ__ZJY_I__4634284C] DEFAULT (0),
[ZJY_R] [money] NULL CONSTRAINT [DF__ZJ__ZJY_R__47284C85] DEFAULT (0),
[ZJY_Q_B] [money] NULL CONSTRAINT [DF__ZJ__ZJY_Q_B__481C70BE] DEFAULT (0),
[ZJY_A_B] [money] NULL CONSTRAINT [DF__ZJ__ZJY_A_B__491094F7] DEFAULT (0),
[ZJY_T_B] [money] NULL CONSTRAINT [DF__ZJ__ZJY_T_B__4A04B930] DEFAULT (0),
[ZJY_I_B] [money] NULL CONSTRAINT [DF__ZJ__ZJY_I_B__4AF8DD69] DEFAULT (0),
[ZJY_R_B] [money] NULL CONSTRAINT [DF__ZJ__ZJY_R_B__4BED01A2] DEFAULT (0),
[ZJY_Q_S] [money] NULL CONSTRAINT [DF__ZJ__ZJY_Q_S__4CE125DB] DEFAULT (0),
[ZJY_A_S] [money] NULL CONSTRAINT [DF__ZJ__ZJY_A_S__4DD54A14] DEFAULT (0),
[ZJY_T_S] [money] NULL CONSTRAINT [DF__ZJ__ZJY_T_S__4EC96E4D] DEFAULT (0),
[ZJY_I_S] [money] NULL CONSTRAINT [DF__ZJ__ZJY_I_S__4FBD9286] DEFAULT (0),
[ZJY_R_S] [money] NULL CONSTRAINT [DF__ZJ__ZJY_R_S__50B1B6BF] DEFAULT (0),
[ZJT_Q] [money] NULL CONSTRAINT [DF__ZJ__ZJT_Q__51A5DAF8] DEFAULT (0),
[ZJT_A] [money] NULL CONSTRAINT [DF__ZJ__ZJT_A__5299FF31] DEFAULT (0),
[ZJT_T] [money] NULL CONSTRAINT [DF__ZJ__ZJT_T__538E236A] DEFAULT (0),
[ZJT_I] [money] NULL CONSTRAINT [DF__ZJ__ZJT_I__548247A3] DEFAULT (0),
[ZJT_R] [money] NULL CONSTRAINT [DF__ZJ__ZJT_R__55766BDC] DEFAULT (0),
[ZJT_Q_B] [money] NULL CONSTRAINT [DF__ZJ__ZJT_Q_B__566A9015] DEFAULT (0),
[ZJT_A_B] [money] NULL CONSTRAINT [DF__ZJ__ZJT_A_B__575EB44E] DEFAULT (0),
[ZJT_T_B] [money] NULL CONSTRAINT [DF__ZJ__ZJT_T_B__5852D887] DEFAULT (0),
[ZJT_I_B] [money] NULL CONSTRAINT [DF__ZJ__ZJT_I_B__5946FCC0] DEFAULT (0),
[ZJT_R_B] [money] NULL CONSTRAINT [DF__ZJ__ZJT_R_B__5A3B20F9] DEFAULT (0),
[ZJT_Q_S] [money] NULL CONSTRAINT [DF__ZJ__ZJT_Q_S__5B2F4532] DEFAULT (0),
[ZJT_A_S] [money] NULL CONSTRAINT [DF__ZJ__ZJT_A_S__5C23696B] DEFAULT (0),
[ZJT_T_S] [money] NULL CONSTRAINT [DF__ZJ__ZJT_T_S__5D178DA4] DEFAULT (0),
[ZJT_I_S] [money] NULL CONSTRAINT [DF__ZJ__ZJT_I_S__5E0BB1DD] DEFAULT (0),
[ZJT_R_S] [money] NULL CONSTRAINT [DF__ZJ__ZJT_R_S__5EFFD616] DEFAULT (0),
[ACNT] [smallint] NULL CONSTRAINT [DF__ZJ__ACNT__5FF3FA4F] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EZJ_INS] on [dbo].[ZJ] instead of insert as
begin
  -- 进货日报,月报,年报
  -- 库存调整日报,月报,年报
  -- 供应商帐款月报,年报

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
    raiserror('EZJ_INS', 16, 1)
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
        ZJ_Q + ZJ_Q_B + ZJ_Q_S
        + ZJT_Q + ZJT_Q_B + ZJT_Q_S
        + ZJ_A + ZJ_A_B + ZJ_A_S + ZJ_T + ZJ_T_B + ZJ_T_S
        + ZJT_T + ZJT_T_B + ZJT_T_S + ZJT_A + ZJT_A_B + ZJT_A_S
        + ZJ_I + ZJ_I_B + ZJ_I_S
        + ZJT_I + ZJT_I_B + ZJT_I_S
        + ZJ_R + ZJ_R_B + ZJ_R_S
        + ZJT_R + ZJT_R_B + ZJT_R_S
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
        DQ1 = DQ1 + ZJ_Q + ZJ_Q_B + ZJ_Q_S,
        DQ4 = DQ4 + ZJT_Q + ZJT_Q_B + ZJT_Q_S,
        DT1 = convert( dec(20,2),  DT1 + ZJ_A + ZJ_A_B + ZJ_A_S + ZJ_T + ZJ_T_B + ZJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZJT_T + ZJT_T_B + ZJT_T_S + ZJT_A + ZJT_A_B + ZJT_A_S ),
        DI1 = convert( dec(20,2),  DI1 + ZJ_I + ZJ_I_B + ZJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZJT_I + ZJT_I_B + ZJT_I_S ),
        DR1 = convert( dec(20,2),  DR1 + ZJ_R + ZJ_R_B + ZJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZJT_R + ZJT_R_B + ZJT_R_S ),
        LSTUPDTIME = getdate()
      from inserted
      where INDRPT.ASETTLENO = @settleno and INDRPT.ADATE = @date
      and INDRPT.BGDGID = @gdgid and INDRPT.BVDRGID = @vdrgid
      and INDRPT.BWRH = @wrh
      and INDRPT.ASTORE = @store
      -- 进货月报
      if not exists ( select * from INMRPT
      where ASETTLENO = @settleno and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh AND ASTORE = @store) begin
        insert into INMRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@settleno, @gdgid, @vdrgid, @wrh, @store)
      end
      update INMRPT set
        DQ1 = DQ1 + ZJ_Q + ZJ_Q_B + ZJ_Q_S,
        DQ4 = DQ4 + ZJT_Q + ZJT_Q_B + ZJT_Q_S,
        DT1 = convert( dec(20,2),  DT1 + ZJ_A + ZJ_A_B + ZJ_A_S + ZJ_T + ZJ_T_B + ZJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZJT_T + ZJT_T_B + ZJT_T_S + ZJT_A + ZJT_A_B + ZJT_A_S ),
        DI1 = convert( dec(20,2),  DI1 + ZJ_I + ZJ_I_B + ZJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZJT_I + ZJT_I_B + ZJT_I_S ),
        DR1 = convert( dec(20,2),  DR1 + ZJ_R + ZJ_R_B + ZJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZJT_R + ZJT_R_B + ZJT_R_S )
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
        DQ1 = DQ1 + ZJ_Q + ZJ_Q_B + ZJ_Q_S,
        DQ4 = DQ4 + ZJT_Q + ZJT_Q_B + ZJT_Q_S,
        DT1 = convert( dec(20,2),  DT1 + ZJ_A + ZJ_A_B + ZJ_A_S + ZJ_T + ZJ_T_B + ZJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZJT_T + ZJT_T_B + ZJT_T_S + ZJT_A + ZJT_A_B + ZJT_A_S ),
        DI1 = convert( dec(20,2),  DI1 + ZJ_I + ZJ_I_B + ZJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZJT_I + ZJT_I_B + ZJT_I_S ),
        DR1 = convert( dec(20,2),  DR1 + ZJ_R + ZJ_R_B + ZJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZJT_R + ZJT_R_B + ZJT_R_S )
      from inserted
      where INYRPT.ASETTLENO = @yno and INYRPT.BGDGID = @gdgid
      and INYRPT.BVDRGID = @vdrgid and INYRPT.BWRH = @wrh
      and INYRPT.ASTORE = @store
    end

    -- 库存调整日报,月报,年报
    if (select
        ZJS_Q + ZJS_Q_B + ZJS_Q_S + ZJY_Q + ZJY_Q_B + ZJY_Q_S
        + ZJS_I + ZJS_I_B + ZJS_I_S + ZJY_I + ZJY_I_B + ZJY_I_S
        + ZJS_R + ZJS_R_B + ZJS_R_S + ZJY_R + ZJY_R_B + ZJY_R_S
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
        DQ1 = DQ1 + ZJY_Q + ZJY_Q_B + ZJY_Q_S - (ZJS_Q + ZJS_Q_B + ZJS_Q_S),
        DI1 = convert( dec(20,2),  DI1 + ZJY_I + ZJY_I_B + ZJY_I_S - (ZJS_I + ZJS_I_B + ZJS_I_S) ),
        DR1 = convert( dec(20,2),  DR1 + ZJY_R + ZJY_R_B + ZJY_R_S - (ZJS_R + ZJS_R_B + ZJS_R_S) ),
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
        DQ1 = DQ1 + ZJY_Q + ZJY_Q_B + ZJY_Q_S - (ZJS_Q + ZJS_Q_B + ZJS_Q_S),
        DI1 = convert( dec(20,2),  DI1 + ZJY_I + ZJY_I_B + ZJY_I_S - (ZJS_I + ZJS_I_B + ZJS_I_S) ),
        DR1 = convert( dec(20,2),  DR1 + ZJY_R + ZJY_R_B + ZJY_R_S - (ZJS_R + ZJS_R_B + ZJS_R_S) )
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
        DQ1 = DQ1 + ZJY_Q + ZJY_Q_B + ZJY_Q_S - (ZJS_Q + ZJS_Q_B + ZJS_Q_S),
        DI1 = convert( dec(20,2),  DI1 + ZJY_I + ZJY_I_B + ZJY_I_S - (ZJS_I + ZJS_I_B + ZJS_I_S) ),
        DR1 = convert( dec(20,2),  DR1 + ZJY_R + ZJY_R_B + ZJY_R_S - (ZJS_R + ZJS_R_B + ZJS_R_S) )
      from inserted
      where INVCHGYRPT.ASETTLENO = @yno and INVCHGYRPT.BGDGID = @gdgid
      and INVCHGYRPT.BWRH = @wrh
      and INVCHGYRPT.ASTORE = @store
    end
  end /* @mode = 0 or 2 */

  if @mode = 1 or @mode = 2 begin
    -- 供应商帐款月报,年报
    if (select
          (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
          + (ZJT_Q + ZJT_Q_B + ZJT_Q_S)
          + (ZJ_A + ZJ_A_B + ZJ_A_S)
          + (ZJ_T + ZJ_T_B + ZJ_T_S)
          + (ZJT_A + ZJT_A_B + ZJT_A_S)
          + (ZJT_T + ZJT_T_B + ZJT_T_S)
    from inserted) <> 0 begin
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
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) ),
          DQ3 = DQ3 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) ),
          DQ3 = DQ3 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) ),
          DQ3 = DQ3 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end else begin
        -- 代销/联销
        -- 供应商帐款日报
        update VDRDRPT set
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (ZJ_Q + ZJ_Q_B + ZJ_Q_S)
                    - (ZJT_Q + ZJT_Q_B + ZJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZJ_A + ZJ_A_B + ZJ_A_S)
                    + (ZJ_T + ZJ_T_B + ZJ_T_S)
                    - (ZJT_A + ZJT_A_B + ZJT_A_S)
                    - (ZJT_T + ZJT_T_B + ZJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end
    end
  end /* @mode = 0 or 2 */
  --DELETE FROM ZJ
end
GO
