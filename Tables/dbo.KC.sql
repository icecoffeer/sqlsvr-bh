CREATE TABLE [dbo].[KC]
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
[TJ_Q] [money] NULL CONSTRAINT [DF__KC__TJ_Q__19B68790] DEFAULT (0),
[TJ_A] [money] NULL CONSTRAINT [DF__KC__TJ_A__1AAAABC9] DEFAULT (0),
[TJ_T] [money] NULL CONSTRAINT [DF__KC__TJ_T__1B9ED002] DEFAULT (0),
[TJ_I] [money] NULL CONSTRAINT [DF__KC__TJ_I__1C92F43B] DEFAULT (0),
[TJ_R] [money] NULL CONSTRAINT [DF__KC__TJ_R__1D871874] DEFAULT (0),
[KS_Q] [money] NULL CONSTRAINT [DF__KC__KS_Q__1E7B3CAD] DEFAULT (0),
[KS_A] [money] NULL CONSTRAINT [DF__KC__KS_A__1F6F60E6] DEFAULT (0),
[KS_T] [money] NULL CONSTRAINT [DF__KC__KS_T__2063851F] DEFAULT (0),
[KS_I] [money] NULL CONSTRAINT [DF__KC__KS_I__2157A958] DEFAULT (0),
[KS_R] [money] NULL CONSTRAINT [DF__KC__KS_R__224BCD91] DEFAULT (0),
[KS_Q_B] [money] NULL CONSTRAINT [DF__KC__KS_Q_B__233FF1CA] DEFAULT (0),
[KS_A_B] [money] NULL CONSTRAINT [DF__KC__KS_A_B__24341603] DEFAULT (0),
[KS_T_B] [money] NULL CONSTRAINT [DF__KC__KS_T_B__25283A3C] DEFAULT (0),
[KS_I_B] [money] NULL CONSTRAINT [DF__KC__KS_I_B__261C5E75] DEFAULT (0),
[KS_R_B] [money] NULL CONSTRAINT [DF__KC__KS_R_B__271082AE] DEFAULT (0),
[KS_Q_S] [money] NULL CONSTRAINT [DF__KC__KS_Q_S__2804A6E7] DEFAULT (0),
[KS_A_S] [money] NULL CONSTRAINT [DF__KC__KS_A_S__28F8CB20] DEFAULT (0),
[KS_T_S] [money] NULL CONSTRAINT [DF__KC__KS_T_S__29ECEF59] DEFAULT (0),
[KS_I_S] [money] NULL CONSTRAINT [DF__KC__KS_I_S__2AE11392] DEFAULT (0),
[KS_R_S] [money] NULL CONSTRAINT [DF__KC__KS_R_S__2BD537CB] DEFAULT (0),
[KY_Q] [money] NULL CONSTRAINT [DF__KC__KY_Q__2CC95C04] DEFAULT (0),
[KY_A] [money] NULL CONSTRAINT [DF__KC__KY_A__2DBD803D] DEFAULT (0),
[KY_T] [money] NULL CONSTRAINT [DF__KC__KY_T__2EB1A476] DEFAULT (0),
[KY_I] [money] NULL CONSTRAINT [DF__KC__KY_I__2FA5C8AF] DEFAULT (0),
[KY_R] [money] NULL CONSTRAINT [DF__KC__KY_R__3099ECE8] DEFAULT (0),
[KY_Q_B] [money] NULL CONSTRAINT [DF__KC__KY_Q_B__318E1121] DEFAULT (0),
[KY_A_B] [money] NULL CONSTRAINT [DF__KC__KY_A_B__3282355A] DEFAULT (0),
[KY_T_B] [money] NULL CONSTRAINT [DF__KC__KY_T_B__33765993] DEFAULT (0),
[KY_I_B] [money] NULL CONSTRAINT [DF__KC__KY_I_B__346A7DCC] DEFAULT (0),
[KY_R_B] [money] NULL CONSTRAINT [DF__KC__KY_R_B__355EA205] DEFAULT (0),
[KY_Q_S] [money] NULL CONSTRAINT [DF__KC__KY_Q_S__3652C63E] DEFAULT (0),
[KY_A_S] [money] NULL CONSTRAINT [DF__KC__KY_A_S__3746EA77] DEFAULT (0),
[KY_T_S] [money] NULL CONSTRAINT [DF__KC__KY_T_S__383B0EB0] DEFAULT (0),
[KY_I_S] [money] NULL CONSTRAINT [DF__KC__KY_I_S__392F32E9] DEFAULT (0),
[KY_R_S] [money] NULL CONSTRAINT [DF__KC__KY_R_S__3A235722] DEFAULT (0),
[PY_Q] [money] NULL CONSTRAINT [DF__KC__PY_Q__3B177B5B] DEFAULT (0),
[PY_A] [money] NULL CONSTRAINT [DF__KC__PY_A__3C0B9F94] DEFAULT (0),
[PY_T] [money] NULL CONSTRAINT [DF__KC__PY_T__3CFFC3CD] DEFAULT (0),
[PY_I] [money] NULL CONSTRAINT [DF__KC__PY_I__3DF3E806] DEFAULT (0),
[PY_R] [money] NULL CONSTRAINT [DF__KC__PY_R__3EE80C3F] DEFAULT (0),
[PK_Q] [money] NULL CONSTRAINT [DF__KC__PK_Q__3FDC3078] DEFAULT (0),
[PK_A] [money] NULL CONSTRAINT [DF__KC__PK_A__40D054B1] DEFAULT (0),
[PK_T] [money] NULL CONSTRAINT [DF__KC__PK_T__41C478EA] DEFAULT (0),
[PK_I] [money] NULL CONSTRAINT [DF__KC__PK_I__42B89D23] DEFAULT (0),
[PK_R] [money] NULL CONSTRAINT [DF__KC__PK_R__43ACC15C] DEFAULT (0),
[ZC_Q] [money] NOT NULL CONSTRAINT [DF__KC__ZC_Q__546D390A] DEFAULT (0),
[ZC_A] [money] NOT NULL CONSTRAINT [DF__KC__ZC_A__55615D43] DEFAULT (0),
[ZC_T] [money] NOT NULL CONSTRAINT [DF__KC__ZC_T__5655817C] DEFAULT (0),
[ZC_I] [money] NOT NULL CONSTRAINT [DF__KC__ZC_I__5749A5B5] DEFAULT (0),
[ZC_R] [money] NOT NULL CONSTRAINT [DF__KC__ZC_R__583DC9EE] DEFAULT (0),
[ZR_Q] [money] NOT NULL CONSTRAINT [DF__KC__ZR_Q__5931EE27] DEFAULT (0),
[ZR_A] [money] NOT NULL CONSTRAINT [DF__KC__ZR_A__5A261260] DEFAULT (0),
[ZR_T] [money] NOT NULL CONSTRAINT [DF__KC__ZR_T__5B1A3699] DEFAULT (0),
[ZR_I] [money] NOT NULL CONSTRAINT [DF__KC__ZR_I__5C0E5AD2] DEFAULT (0),
[ZR_R] [money] NOT NULL CONSTRAINT [DF__KC__ZR_R__5D027F0B] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EKC_INS] on [dbo].[KC] for insert as
begin
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
    @store int

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('EKC_INS', 16, 1)
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
    @store = ASTORE
    from inserted

  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  declare @yno int
  select @yno = YNO from V_YM where MNO = @settleno

  -- 库存调整日报,月报,年报
  if (select
      KY_Q + KY_Q_B + KY_Q_S + (KS_Q + KS_Q_B + KS_Q_S)
      + PY_Q + PK_Q + ZC_Q + ZR_Q
      + KY_I + KY_I_B + KY_I_S + (KS_I + KS_I_B + KS_I_S)
      + PY_I + PK_I
      + TJ_I + ZC_I + ZR_I
      + KY_R + KY_R_B + KY_R_S + (KS_R + KS_R_B + KS_R_S)
      + PY_R + PK_R
      + TJ_R + ZC_R + ZR_R
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
      DQ1 = DQ1 + KY_Q + KY_Q_B + KY_Q_S - (KS_Q + KS_Q_B + KS_Q_S),
      DQ2 = DQ2 + PY_Q - PK_Q,
      DQ6 = DQ6 + ZR_Q,
      DQ7 = DQ7 + ZC_Q,
      DT6 = convert( dec(20,2), DT6 + ZR_A + ZR_T ),
      DT7 = convert( dec(20,2), DT7 + ZC_A + ZC_T ),
      DI1 = convert( dec(20,2),
            DI1 + KY_I + KY_I_B + KY_I_S - (KS_I + KS_I_B + KS_I_S) ),
      DI2 = convert( dec(20,2), DI2 + PY_I - PK_I ),
      DI3 = convert( dec(20,2), DI3 + TJ_I ),
      DI6 = convert( dec(20,2), DI6 + ZR_I ),
      DI7 = convert( dec(20,2), DI7 + ZC_I ),
      DR1 = convert( dec(20,2), DR1 + KY_R + KY_R_B + KY_R_S - (KS_R + KS_R_B + KS_R_S) ),
      DR2 = convert( dec(20,2), DR2 + PY_R - PK_R ),
      DR3 = convert( dec(20,2), DR3 + TJ_R ),
      DR6 = convert( dec(20,2), DR6 + ZR_R ),
      DR7 = convert( dec(20,2), DR7 + ZC_R ),
      LSTUPDTIME = getdate()
    from inserted
    where INVCHGDRPT.ASETTLENO = @settleno and INVCHGDRPT.ADATE = @date
    and INVCHGDRPT.BGDGID = @gdgid and INVCHGDRPT.BWRH = @wrh
    and INVCHGDRPT.ASTORE = @store
    -- 库存调整月报
    if not exists ( select * from INVCHGMRPT
    where ASETTLENO = @settleno
    and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
      insert into INVCHGMRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
      values (@settleno, @gdgid, @wrh, @store)
    end
    update INVCHGMRPT set
      DQ1 = DQ1 + KY_Q + KY_Q_B + KY_Q_S - (KS_Q + KS_Q_B + KS_Q_S),
      DQ2 = DQ2 + PY_Q - PK_Q,
      DQ6 = DQ6 + ZR_Q,
      DQ7 = DQ7 + ZC_Q,
      DT6 = convert( dec(20,2), DT6 + ZR_A + ZR_T ),
      DT7 = convert( dec(20,2), DT7 + ZC_A + ZC_T ),
      DI1 = convert( dec(20,2), DI1 + KY_I + KY_I_B + KY_I_S - (KS_I + KS_I_B + KS_I_S) ),
      DI2 = convert( dec(20,2), DI2 + PY_I - PK_I ),
      DI3 = convert( dec(20,2), DI3 + TJ_I ),
      DI6 = convert( dec(20,2), DI6 + ZR_I ),
      DI7 = convert( dec(20,2), DI7 + ZC_I ),
      DR1 = convert( dec(20,2), DR1 + KY_R + KY_R_B + KY_R_S - (KS_R + KS_R_B + KS_R_S) ),
      DR2 = convert( dec(20,2), DR2 + PY_R - PK_R ),
      DR3 = convert( dec(20,2), DR3 + TJ_R ),
      DR6 = convert( dec(20,2), DR6 + ZR_R ),
      DR7 = convert( dec(20,2), DR7 + ZC_R )
    from inserted
    where INVCHGMRPT.ASETTLENO = @settleno
    and INVCHGMRPT.BGDGID = @gdgid and INVCHGMRPT.BWRH = @wrh
    and INVCHGMRPT.ASTORE = @store
    -- 库存调整年报
    if not exists ( select * from INVCHGYRPT
    where ASETTLENO = @yno
    and BGDGID = @gdgid and BWRH = @wrh and ASTORE = @store) begin
      insert into INVCHGYRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
      values (@yno, @gdgid, @wrh, @store)
    end
    update INVCHGYRPT set
      DQ1 = DQ1 + KY_Q + KY_Q_B + KY_Q_S - (KS_Q + KS_Q_B + KS_Q_S),
      DQ2 = DQ2 + PY_Q - PK_Q,
      DQ6 = DQ6 + ZR_Q,
      DQ7 = DQ7 + ZC_Q,
      DT6 = convert( dec(20,2), DT6 + ZR_A + ZR_T ),
      DT7 = convert( dec(20,2), DT7 + ZC_A + ZC_T ),
      DI1 = convert( dec(20,2), DI1 + KY_I + KY_I_B + KY_I_S - (KS_I + KS_I_B + KS_I_S) ),
      DI2 = convert( dec(20,2), DI2 + PY_I - PK_I ),
      DI3 = convert( dec(20,2), DI3 + TJ_I ),
      DI6 = convert( dec(20,2), DI6 + ZR_I ),
      DI7 = convert( dec(20,2), DI7 + ZC_I ),
      DR1 = convert( dec(20,2), DR1 + KY_R + KY_R_B + KY_R_S - (KS_R + KS_R_B + KS_R_S) ),
      DR2 = convert( dec(20,2), DR2 + PY_R - PK_R ),
      DR3 = convert( dec(20,2), DR3 + TJ_R ),
      DR6 = convert( dec(20,2), DR6 + ZR_R ),
      DR7 = convert( dec(20,2), DR7 + ZC_R )
    from inserted
    where INVCHGYRPT.ASETTLENO = @yno
    and INVCHGYRPT.BGDGID = @gdgid and INVCHGYRPT.BWRH = @wrh
    and INVCHGYRPT.ASTORE = @store
    /*
    -- 库存报表
    execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
    update INVDRPT
      set FT = FT + TJ_R
      from inserted
      where INVDRPT.ASETTLENO = @settleno and INVDRPT.ADATE = @date
      and INVDRPT.ASTORE = @store and INVDRPT.BWRH = @wrh and INVDRPT.BGDGID = @gdgid
    update INVMRPT
      set FT = FT + TJ_R
      from inserted
      where INVMRPT.ASETTLENO = @settleno and INVMRPT.ASTORE = @store
      and INVMRPT.BWRH = @wrh and INVMRPT.BGDGID = @gdgid
    update INVYRPT
      set FT = FT + TJ_R
      from inserted
      where INVYRPT.ASETTLENO = @yno and INVYRPT.ASTORE = @store
      and INVYRPT.BWRH = @wrh and INVYRPT.BGDGID = @gdgid
    */
  end

  delete from KC
end
GO
