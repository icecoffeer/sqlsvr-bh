CREATE TABLE [dbo].[ZPJ]
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
[ZPJ_Q] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_Q__080DA3F8] DEFAULT (0),
[ZPJ_A] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_A__0901C831] DEFAULT (0),
[ZPJ_T] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_T__09F5EC6A] DEFAULT (0),
[ZPJ_I] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_I__0AEA10A3] DEFAULT (0),
[ZPJ_R] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_R__0BDE34DC] DEFAULT (0),
[ZPJ_Q_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_Q_B__0CD25915] DEFAULT (0),
[ZPJ_A_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_A_B__0DC67D4E] DEFAULT (0),
[ZPJ_T_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_T_B__0EBAA187] DEFAULT (0),
[ZPJ_I_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_I_B__0FAEC5C0] DEFAULT (0),
[ZPJ_R_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_R_B__10A2E9F9] DEFAULT (0),
[ZPJ_Q_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_Q_S__11970E32] DEFAULT (0),
[ZPJ_A_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_A_S__128B326B] DEFAULT (0),
[ZPJ_T_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_T_S__137F56A4] DEFAULT (0),
[ZPJ_I_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_I_S__14737ADD] DEFAULT (0),
[ZPJ_R_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJ_R_S__15679F16] DEFAULT (0),
[ZPJS_Q] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_Q__165BC34F] DEFAULT (0),
[ZPJS_A] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_A__174FE788] DEFAULT (0),
[ZPJS_T] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_T__18440BC1] DEFAULT (0),
[ZPJS_I] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_I__19382FFA] DEFAULT (0),
[ZPJS_R] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_R__1A2C5433] DEFAULT (0),
[ZPJS_Q_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_Q_B__1B20786C] DEFAULT (0),
[ZPJS_A_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_A_B__1C149CA5] DEFAULT (0),
[ZPJS_T_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_T_B__1D08C0DE] DEFAULT (0),
[ZPJS_I_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_I_B__1DFCE517] DEFAULT (0),
[ZPJS_R_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_R_B__1EF10950] DEFAULT (0),
[ZPJS_Q_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_Q_S__1FE52D89] DEFAULT (0),
[ZPJS_A_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_A_S__20D951C2] DEFAULT (0),
[ZPJS_T_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_T_S__21CD75FB] DEFAULT (0),
[ZPJS_I_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_I_S__22C19A34] DEFAULT (0),
[ZPJS_R_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJS_R_S__23B5BE6D] DEFAULT (0),
[ZPJY_Q] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_Q__24A9E2A6] DEFAULT (0),
[ZPJY_A] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_A__259E06DF] DEFAULT (0),
[ZPJY_T] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_T__26922B18] DEFAULT (0),
[ZPJY_I] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_I__27864F51] DEFAULT (0),
[ZPJY_R] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_R__287A738A] DEFAULT (0),
[ZPJY_Q_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_Q_B__296E97C3] DEFAULT (0),
[ZPJY_A_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_A_B__2A62BBFC] DEFAULT (0),
[ZPJY_T_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_T_B__2B56E035] DEFAULT (0),
[ZPJY_I_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_I_B__2C4B046E] DEFAULT (0),
[ZPJY_R_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_R_B__2D3F28A7] DEFAULT (0),
[ZPJY_Q_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_Q_S__2E334CE0] DEFAULT (0),
[ZPJY_A_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_A_S__2F277119] DEFAULT (0),
[ZPJY_T_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_T_S__301B9552] DEFAULT (0),
[ZPJY_I_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_I_S__310FB98B] DEFAULT (0),
[ZPJY_R_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJY_R_S__3203DDC4] DEFAULT (0),
[ZPJT_Q] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_Q__32F801FD] DEFAULT (0),
[ZPJT_A] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_A__33EC2636] DEFAULT (0),
[ZPJT_T] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_T__34E04A6F] DEFAULT (0),
[ZPJT_I] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_I__35D46EA8] DEFAULT (0),
[ZPJT_R] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_R__36C892E1] DEFAULT (0),
[ZPJT_Q_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_Q_B__37BCB71A] DEFAULT (0),
[ZPJT_A_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_A_B__38B0DB53] DEFAULT (0),
[ZPJT_T_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_T_B__39A4FF8C] DEFAULT (0),
[ZPJT_I_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_I_B__3A9923C5] DEFAULT (0),
[ZPJT_R_B] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_R_B__3B8D47FE] DEFAULT (0),
[ZPJT_Q_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_Q_S__3C816C37] DEFAULT (0),
[ZPJT_A_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_A_S__3D759070] DEFAULT (0),
[ZPJT_T_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_T_S__3E69B4A9] DEFAULT (0),
[ZPJT_I_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_I_S__3F5DD8E2] DEFAULT (0),
[ZPJT_R_S] [money] NOT NULL CONSTRAINT [DF__ZPJ__ZPJT_R_S__4051FD1B] DEFAULT (0),
[ACNT] [smallint] NOT NULL CONSTRAINT [DF__ZPJ__ACNT__41462154] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EZPJ_INS] on [dbo].[ZPJ] instead of insert as
begin
  -- 进货日报,月报,年报
  -- 库存调整日报,月报,年报

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
    raiserror('EZPJ_INS', 16, 1)
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
        ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S
        + ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S
        + ZPJ_A + ZPJ_A_B + ZPJ_A_S + ZPJ_T + ZPJ_T_B + ZPJ_T_S
        + ZPJT_T + ZPJT_T_B + ZPJT_T_S + ZPJT_A + ZPJT_A_B + ZPJT_A_S
        + ZPJ_I + ZPJ_I_B + ZPJ_I_S
        + ZPJT_I + ZPJT_I_B + ZPJT_I_S
        + ZPJ_R + ZPJ_R_B + ZPJ_R_S
        + ZPJT_R + ZPJT_R_B + ZPJT_R_S
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
        DQ2 = DQ2 + ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S,
        DQ4 = DQ4 + ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S,
        DT2 = convert( dec(20,2),  DT2 + ZPJ_A + ZPJ_A_B + ZPJ_A_S + ZPJ_T + ZPJ_T_B + ZPJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZPJT_T + ZPJT_T_B + ZPJT_T_S + ZPJT_A + ZPJT_A_B + ZPJT_A_S ),
        DI2 = convert( dec(20,2),  DI2 + ZPJ_I + ZPJ_I_B + ZPJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZPJT_I + ZPJT_I_B + ZPJT_I_S ),
        DR2 = convert( dec(20,2),  DR2 + ZPJ_R + ZPJ_R_B + ZPJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZPJT_R + ZPJT_R_B + ZPJT_R_S ),
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
        DQ2 = DQ2 + ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S,
        DQ4 = DQ4 + ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S,
        DT2 = convert( dec(20,2),  DT2 + ZPJ_A + ZPJ_A_B + ZPJ_A_S + ZPJ_T + ZPJ_T_B + ZPJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZPJT_T + ZPJT_T_B + ZPJT_T_S + ZPJT_A + ZPJT_A_B + ZPJT_A_S ),
        DI2 = convert( dec(20,2),  DI2 + ZPJ_I + ZPJ_I_B + ZPJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZPJT_I + ZPJT_I_B + ZPJT_I_S ),
        DR2 = convert( dec(20,2),  DR2 + ZPJ_R + ZPJ_R_B + ZPJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZPJT_R + ZPJT_R_B + ZPJT_R_S )
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
        DQ2 = DQ2 + ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S,
        DQ4 = DQ4 + ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S,
        DT2 = convert( dec(20,2),  DT2 + ZPJ_A + ZPJ_A_B + ZPJ_A_S + ZPJ_T + ZPJ_T_B + ZPJ_T_S ),
        DT4 = convert( dec(20,2),  DT4 + ZPJT_T + ZPJT_T_B + ZPJT_T_S + ZPJT_A + ZPJT_A_B + ZPJT_A_S ),
        DI2 = convert( dec(20,2),  DI2 + ZPJ_I + ZPJ_I_B + ZPJ_I_S ),
        DI4 = convert( dec(20,2),  DI4 + ZPJT_I + ZPJT_I_B + ZPJT_I_S ),
        DR2 = convert( dec(20,2),  DR2 + ZPJ_R + ZPJ_R_B + ZPJ_R_S ),
        DR4 = convert( dec(20,2),  DR4 + ZPJT_R + ZPJT_R_B + ZPJT_R_S )
      from inserted
      where INYRPT.ASETTLENO = @yno and INYRPT.BGDGID = @gdgid
      and INYRPT.BVDRGID = @vdrgid and INYRPT.BWRH = @wrh
      and INYRPT.ASTORE = @store
    end

    -- 库存调整日报,月报,年报
    if (select
        ZPJS_Q + ZPJS_Q_B + ZPJS_Q_S + ZPJY_Q + ZPJY_Q_B + ZPJY_Q_S
        + ZPJS_I + ZPJS_I_B + ZPJS_I_S + ZPJY_I + ZPJY_I_B + ZPJY_I_S
        + ZPJS_R + ZPJS_R_B + ZPJS_R_S + ZPJY_R + ZPJY_R_B + ZPJY_R_S
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
        DQ1 = DQ1 - (ZPJS_Q + ZPJS_Q_B + ZPJS_Q_S) + ZPJY_Q + ZPJY_Q_B + ZPJY_Q_S,
        DI1 = convert( dec(20,2),  DI1 - (ZPJS_I + ZPJS_I_B + ZPJS_I_S) + ZPJY_I + ZPJY_I_B + ZPJY_I_S ),
        DR1 = convert( dec(20,2),  DR1 - (ZPJS_R + ZPJS_R_B + ZPJS_R_S) + ZPJY_R + ZPJY_R_B + ZPJY_R_S ),
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
        DQ1 = DQ1 - (ZPJS_Q + ZPJS_Q_B + ZPJS_Q_S) + ZPJY_Q + ZPJY_Q_B + ZPJY_Q_S,
        DI1 = convert( dec(20,2),  DI1 - (ZPJS_I + ZPJS_I_B + ZPJS_I_S) + ZPJY_I + ZPJY_I_B + ZPJY_I_S ),
        DR1 = convert( dec(20,2),  DR1 - (ZPJS_R + ZPJS_R_B + ZPJS_R_S) + ZPJY_R + ZPJY_R_B + ZPJY_R_S )
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
        DQ1 = DQ1 - (ZPJS_Q + ZPJS_Q_B + ZPJS_Q_S) + ZPJY_Q + ZPJY_Q_B + ZPJY_Q_S,
        DI1 = convert( dec(20,2),  DI1 - (ZPJS_I + ZPJS_I_B + ZPJS_I_S) + ZPJY_I + ZPJY_I_B + ZPJY_I_S ),
        DR1 = convert( dec(20,2),  DR1 - (ZPJS_R + ZPJS_R_B + ZPJS_R_S) + ZPJY_R + ZPJY_R_B + ZPJY_R_S )
      from inserted
      where INVCHGYRPT.ASETTLENO = @yno and INVCHGYRPT.BGDGID = @gdgid
      and INVCHGYRPT.BWRH = @wrh
      and INVCHGYRPT.ASTORE = @store
    end
  end /* @mode = 0 or 2 */

  if @mode = 1 or @mode = 2 begin
    -- 供应商日报,月报,年报
    if (select
        ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S
        + ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S
        + ZPJ_A + ZPJ_A_B + ZPJ_A_S + ZPJ_T + ZPJ_T_B + ZPJ_T_S
        + ZPJT_T + ZPJT_T_B + ZPJT_T_S + ZPJT_A + ZPJT_A_B + ZPJT_A_S
        + ZPJ_I + ZPJ_I_B + ZPJ_I_S
        + ZPJT_I + ZPJT_I_B + ZPJT_I_S
        + ZPJ_R + ZPJ_R_B + ZPJ_R_S
        + ZPJT_R + ZPJT_R_B + ZPJT_R_S
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
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) ),
          DQ3 = DQ3 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) ),
          DQ3 = DQ3 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) ),
          DQ3 = DQ3 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT3 = convert( dec(20,2),
                DT3 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end else begin
        -- 代销/联销
        -- 供应商帐款日报
        update VDRDRPT set
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) ),
          LSTUPDTIME = getdate()
        from inserted
        where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
        and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
        and VDRDRPT.ASTORE = @store
        and VDRDRPT.ADATE = @date
        -- 供应商帐款月报
        update VDRMRPT set
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) )
        from inserted
        where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
        and VDRMRPT.ASTORE = @store
        -- 供应商帐款年报
        update VDRYRPT set
          DQ1 = DQ1 + (ZPJ_Q + ZPJ_Q_B + ZPJ_Q_S)
                    - (ZPJT_Q + ZPJT_Q_B + ZPJT_Q_S),
          DT1 = convert( dec(20,2),
                DT1 + (ZPJ_A + ZPJ_A_B + ZPJ_A_S)
                    + (ZPJ_T + ZPJ_T_B + ZPJ_T_S)
                    - (ZPJT_A + ZPJT_A_B + ZPJT_A_S)
                    - (ZPJT_T + ZPJT_T_B + ZPJT_T_S) )
        from inserted
        where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
        and VDRYRPT.ASTORE = @store
      end
    end /* of select <> 0 */
  end /* of mode = 1 or 2 */
  --DELETE FROM ZPJ
end
GO
