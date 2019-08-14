CREATE TABLE [dbo].[DB]
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
[DJ_Q] [money] NULL CONSTRAINT [DF__DB__DJ_Q__550C5788] DEFAULT (0),
[DJ_A] [money] NULL CONSTRAINT [DF__DB__DJ_A__56007BC1] DEFAULT (0),
[DJ_T] [money] NULL CONSTRAINT [DF__DB__DJ_T__56F49FFA] DEFAULT (0),
[DJ_I] [money] NULL CONSTRAINT [DF__DB__DJ_I__57E8C433] DEFAULT (0),
[DJ_R] [money] NULL CONSTRAINT [DF__DB__DJ_R__58DCE86C] DEFAULT (0),
[DJ_Q_B] [money] NULL CONSTRAINT [DF__DB__DJ_Q_B__59D10CA5] DEFAULT (0),
[DJ_A_B] [money] NULL CONSTRAINT [DF__DB__DJ_A_B__5AC530DE] DEFAULT (0),
[DJ_T_B] [money] NULL CONSTRAINT [DF__DB__DJ_T_B__5BB95517] DEFAULT (0),
[DJ_I_B] [money] NULL CONSTRAINT [DF__DB__DJ_I_B__5CAD7950] DEFAULT (0),
[DJ_R_B] [money] NULL CONSTRAINT [DF__DB__DJ_R_B__5DA19D89] DEFAULT (0),
[DJ_Q_S] [money] NULL CONSTRAINT [DF__DB__DJ_Q_S__5E95C1C2] DEFAULT (0),
[DJ_A_S] [money] NULL CONSTRAINT [DF__DB__DJ_A_S__5F89E5FB] DEFAULT (0),
[DJ_T_S] [money] NULL CONSTRAINT [DF__DB__DJ_T_S__607E0A34] DEFAULT (0),
[DJ_I_S] [money] NULL CONSTRAINT [DF__DB__DJ_I_S__61722E6D] DEFAULT (0),
[DJ_R_S] [money] NULL CONSTRAINT [DF__DB__DJ_R_S__626652A6] DEFAULT (0),
[DJS_Q] [money] NULL CONSTRAINT [DF__DB__DJS_Q__635A76DF] DEFAULT (0),
[DJS_A] [money] NULL CONSTRAINT [DF__DB__DJS_A__644E9B18] DEFAULT (0),
[DJS_T] [money] NULL CONSTRAINT [DF__DB__DJS_T__6542BF51] DEFAULT (0),
[DJS_I] [money] NULL CONSTRAINT [DF__DB__DJS_I__6636E38A] DEFAULT (0),
[DJS_R] [money] NULL CONSTRAINT [DF__DB__DJS_R__672B07C3] DEFAULT (0),
[DJS_Q_B] [money] NULL CONSTRAINT [DF__DB__DJS_Q_B__681F2BFC] DEFAULT (0),
[DJS_A_B] [money] NULL CONSTRAINT [DF__DB__DJS_A_B__69135035] DEFAULT (0),
[DJS_T_B] [money] NULL CONSTRAINT [DF__DB__DJS_T_B__6A07746E] DEFAULT (0),
[DJS_I_B] [money] NULL CONSTRAINT [DF__DB__DJS_I_B__6AFB98A7] DEFAULT (0),
[DJS_R_B] [money] NULL CONSTRAINT [DF__DB__DJS_R_B__6BEFBCE0] DEFAULT (0),
[DJS_Q_S] [money] NULL CONSTRAINT [DF__DB__DJS_Q_S__6CE3E119] DEFAULT (0),
[DJS_A_S] [money] NULL CONSTRAINT [DF__DB__DJS_A_S__6DD80552] DEFAULT (0),
[DJS_T_S] [money] NULL CONSTRAINT [DF__DB__DJS_T_S__6ECC298B] DEFAULT (0),
[DJS_I_S] [money] NULL CONSTRAINT [DF__DB__DJS_I_S__6FC04DC4] DEFAULT (0),
[DJS_R_S] [money] NULL CONSTRAINT [DF__DB__DJS_R_S__70B471FD] DEFAULT (0),
[DJY_Q] [money] NULL CONSTRAINT [DF__DB__DJY_Q__71A89636] DEFAULT (0),
[DJY_A] [money] NULL CONSTRAINT [DF__DB__DJY_A__729CBA6F] DEFAULT (0),
[DJY_T] [money] NULL CONSTRAINT [DF__DB__DJY_T__7390DEA8] DEFAULT (0),
[DJY_I] [money] NULL CONSTRAINT [DF__DB__DJY_I__748502E1] DEFAULT (0),
[DJY_R] [money] NULL CONSTRAINT [DF__DB__DJY_R__7579271A] DEFAULT (0),
[DJY_Q_B] [money] NULL CONSTRAINT [DF__DB__DJY_Q_B__766D4B53] DEFAULT (0),
[DJY_A_B] [money] NULL CONSTRAINT [DF__DB__DJY_A_B__77616F8C] DEFAULT (0),
[DJY_T_B] [money] NULL CONSTRAINT [DF__DB__DJY_T_B__785593C5] DEFAULT (0),
[DJY_I_B] [money] NULL CONSTRAINT [DF__DB__DJY_I_B__7949B7FE] DEFAULT (0),
[DJY_R_B] [money] NULL CONSTRAINT [DF__DB__DJY_R_B__7A3DDC37] DEFAULT (0),
[DJY_Q_S] [money] NULL CONSTRAINT [DF__DB__DJY_Q_S__7B320070] DEFAULT (0),
[DJY_A_S] [money] NULL CONSTRAINT [DF__DB__DJY_A_S__7C2624A9] DEFAULT (0),
[DJY_T_S] [money] NULL CONSTRAINT [DF__DB__DJY_T_S__7D1A48E2] DEFAULT (0),
[DJY_I_S] [money] NULL CONSTRAINT [DF__DB__DJY_I_S__7E0E6D1B] DEFAULT (0),
[DJY_R_S] [money] NULL CONSTRAINT [DF__DB__DJY_R_S__7F029154] DEFAULT (0),
[NDJ_Q] [money] NULL CONSTRAINT [DF__DB__NDJ_Q__7FF6B58D] DEFAULT (0),
[NDJ_A] [money] NULL CONSTRAINT [DF__DB__NDJ_A__00EAD9C6] DEFAULT (0),
[NDJ_T] [money] NULL CONSTRAINT [DF__DB__NDJ_T__01DEFDFF] DEFAULT (0),
[NDJ_I] [money] NULL CONSTRAINT [DF__DB__NDJ_I__02D32238] DEFAULT (0),
[NDJ_R] [money] NULL CONSTRAINT [DF__DB__NDJ_R__03C74671] DEFAULT (0),
[DC_Q] [money] NULL CONSTRAINT [DF__DB__DC_Q__04BB6AAA] DEFAULT (0),
[DC_A] [money] NULL CONSTRAINT [DF__DB__DC_A__05AF8EE3] DEFAULT (0),
[DC_T] [money] NULL CONSTRAINT [DF__DB__DC_T__06A3B31C] DEFAULT (0),
[DC_I] [money] NULL CONSTRAINT [DF__DB__DC_I__0797D755] DEFAULT (0),
[DC_R] [money] NULL CONSTRAINT [DF__DB__DC_R__088BFB8E] DEFAULT (0),
[DC_Q_B] [money] NULL CONSTRAINT [DF__DB__DC_Q_B__09801FC7] DEFAULT (0),
[DC_A_B] [money] NULL CONSTRAINT [DF__DB__DC_A_B__0A744400] DEFAULT (0),
[DC_T_B] [money] NULL CONSTRAINT [DF__DB__DC_T_B__0B686839] DEFAULT (0),
[DC_I_B] [money] NULL CONSTRAINT [DF__DB__DC_I_B__0C5C8C72] DEFAULT (0),
[DC_R_B] [money] NULL CONSTRAINT [DF__DB__DC_R_B__0D50B0AB] DEFAULT (0),
[DC_Q_S] [money] NULL CONSTRAINT [DF__DB__DC_Q_S__0E44D4E4] DEFAULT (0),
[DC_A_S] [money] NULL CONSTRAINT [DF__DB__DC_A_S__0F38F91D] DEFAULT (0),
[DC_T_S] [money] NULL CONSTRAINT [DF__DB__DC_T_S__102D1D56] DEFAULT (0),
[DC_I_S] [money] NULL CONSTRAINT [DF__DB__DC_I_S__1121418F] DEFAULT (0),
[DC_R_S] [money] NULL CONSTRAINT [DF__DB__DC_R_S__121565C8] DEFAULT (0),
[NDC_Q] [money] NULL CONSTRAINT [DF__DB__NDC_Q__13098A01] DEFAULT (0),
[NDC_A] [money] NULL CONSTRAINT [DF__DB__NDC_A__13FDAE3A] DEFAULT (0),
[NDC_T] [money] NULL CONSTRAINT [DF__DB__NDC_T__14F1D273] DEFAULT (0),
[NDC_I] [money] NULL CONSTRAINT [DF__DB__NDC_I__15E5F6AC] DEFAULT (0),
[NDC_R] [money] NULL CONSTRAINT [DF__DB__NDC_R__16DA1AE5] DEFAULT (0),
[ACNT] [smallint] NULL CONSTRAINT [DF__DB__ACNT__17CE3F1E] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create trigger [dbo].[EDB_INS] on [dbo].[DB] instead of insert as
begin
  -- 进货日报,月报,年报
  -- 出货日报,月报,年报

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
    @acnt smallint

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('EDB_INS', 16, 1)
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
    @acnt = ACNT,
    @store = ASTORE
    from inserted

  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  declare @yno int
  select @yno = YNO from V_YM where MNO = @settleno

  if @acnt = 0 or @acnt = 2
  begin
    -- 进货日报,月报,年报
    if (select
        DJ_Q + DJ_Q_B + DJ_Q_S
        + DJ_A + DJ_A_B + DJ_A_S
                  + DJ_T + DJ_T_B
        + DJ_I + DJ_I_B + DJ_I_S
        + DJ_R + DJ_R_B + DJ_R_S
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
        DQ3 = DQ3 + DJ_Q + DJ_Q_B + DJ_Q_S,
        DT3 = convert(dec(20,2),
              DT3 + DJ_A + DJ_A_B + DJ_A_S
                  + DJ_T + DJ_T_B + DJ_T_S ),
        DI3 = convert(dec(20,2),
              DI3 + DJ_I + DJ_I_B + DJ_I_S ),
        DR3 = convert(dec(20,2),
              DR3 + DJ_R + DJ_R_B + DJ_R_S ),
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
        DQ3 = DQ3 + DJ_Q + DJ_Q_B + DJ_Q_S,
        DT3 = convert(dec(20,2),
              DT3 + DJ_A + DJ_A_B + DJ_A_S
                  + DJ_T + DJ_T_B + DJ_T_S ),
        DI3 = convert(dec(20,2),
              DI3 + DJ_I + DJ_I_B + DJ_I_S ),
        DR3 = convert(dec(20,2),
              DR3 + DJ_R + DJ_R_B + DJ_R_S )
      from inserted
      where INMRPT.ASETTLENO = @settleno and INMRPT.BGDGID = @gdgid
      and INMRPT.BVDRGID = @vdrgid and INMRPT.BWRH = @wrh
      and INMRPT.ASTORE = @store
      -- 进货年报
      if not exists ( select * from INYRPT
      where ASETTLENO = /*@settleno 2001-04-23*/@yno and BGDGID = @gdgid
      and BVDRGID = @vdrgid and BWRH = @wrh and ASTORE = @store) begin
        insert into INYRPT (ASETTLENO, BGDGID, BVDRGID, BWRH, ASTORE)
        values (@yno, @gdgid, @vdrgid, @wrh, @store)
      end
      update INYRPT set
        DQ3 = DQ3 + DJ_Q + DJ_Q_B + DJ_Q_S,
        DT3 = convert(dec(20,2),
              DT3 + DJ_A + DJ_A_B + DJ_A_S
                  + DJ_T + DJ_T_B + DJ_T_S ),
        DI3 = convert(dec(20,2),
              DI3 + DJ_I + DJ_I_B + DJ_I_S ),
        DR3 = convert(dec(20,2),
              DR3 + DJ_R + DJ_R_B + DJ_R_S )
      from inserted
      where INYRPT.ASETTLENO = @Yno and INYRPT.BGDGID = @gdgid
      and INYRPT.BVDRGID = @vdrgid and INYRPT.BWRH = @wrh
      and INYRPT.ASTORE = @store
    end
  end /* of @acnt = 0 or @acnt = 2 */

  -- 出货日报,月报,年报
  if (select
      DC_Q + DC_Q_B + DC_Q_S
      + DC_A + DC_A_B + DC_A_S
                + DC_T + DC_T_B + DC_T_S
      + DC_I + DC_I_B + DC_I_S
      + DC_R + DC_R_B + DC_R_S
  from inserted) <> 0 begin
    execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
    -- 出货日报
    if not exists ( select * from OUTDRPTI
    where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
    and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTDRPTI (ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @clngid, @wrh, @store)
    end
    if not exists ( select * from OUTDRPT
    where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
    and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTDRPT (ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @clngid, @wrh, @store)
    end
    update OUTDRPT set
      DQ3 = DQ3 + DC_Q + DC_Q_B + DC_Q_S,
      DT3 = convert(dec(20,2),
            DT3 + DC_A + DC_A_B + DC_A_S
                + DC_T + DC_T_B + DC_T_S ),
      DI3 = convert(dec(20,2),
            DI3 + DC_I + DC_I_B + DC_I_S ),
      DR3 = convert(dec(20,2),
            DR3 + DC_R + DC_R_B + DC_R_S ),
      LSTUPDTIME = getdate()
    from inserted
    where OUTDRPT.ASETTLENO = @settleno and OUTDRPT.ADATE = @date
    and OUTDRPT.BGDGID = @gdgid and OUTDRPT.BCSTGID = @clngid
    and OUTDRPT.BWRH = @wrh
    and OUTDRPT.ASTORE = @store
    -- 出货月报
    if not exists ( select * from OUTMRPT
    where ASETTLENO = @settleno and BGDGID = @gdgid
    and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTMRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @gdgid, @clngid, @wrh, @store)
    end
    update OUTMRPT set
      DQ3 = DQ3 + DC_Q + DC_Q_B + DC_Q_S,
      DT3 = convert(dec(20,2),
            DT3 + DC_A + DC_A_B + DC_A_S
                + DC_T + DC_T_B + DC_T_S ),
      DI3 = convert(dec(20,2),
            DI3 + DC_I + DC_I_B + DC_I_S ),
      DR3 = convert(dec(20,2),
            DR3 + DC_R + DC_R_B + DC_R_S )
    from inserted
    where OUTMRPT.ASETTLENO = @settleno
    and OUTMRPT.BGDGID = @gdgid and OUTMRPT.BCSTGID = @clngid
    and OUTMRPT.BWRH = @wrh
    and OUTMRPT.ASTORE = @store
    -- 出货年报
    if not exists ( select * from OUTYRPT
    where ASETTLENO = /*@settleno 2001-04-23*/@yno and BGDGID = @gdgid
    and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTYRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@yno, @gdgid, @clngid, @wrh, @store)
    end
    update OUTYRPT set
      DQ3 = DQ3 + DC_Q + DC_Q_B + DC_Q_S,
      DT3 = convert(dec(20,2),
            DT3 + DC_A + DC_A_B + DC_A_S
                + DC_T + DC_T_B + DC_T_S ),
      DI3 = convert(dec(20,2),
            DI3 + DC_I + DC_I_B + DC_I_S ),
      DR3 = convert(dec(20,2),
            DR3 + DC_R + DC_R_B + DC_R_S )
    from inserted
    where OUTYRPT.ASETTLENO = @YNO
    and OUTYRPT.BGDGID = @gdgid and OUTYRPT.BCSTGID = @clngid
    and OUTYRPT.BWRH = @wrh
    and OUTYRPT.ASTORE = @store
  end
  -- 库存调整日报,月报,年报
  if (select
      NDC_Q + NDC_A + NDC_T + NDC_I + NDC_R +
      NDJ_Q + NDJ_A + NDJ_T + NDJ_I + NDJ_R
  from inserted) <> 0 begin
    execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
    -- 库存调整日报
    if not exists (
      select *
      from INVCHGDRPTI
      where ASETTLENO = @settleno
      and ADATE = @date
      and BGDGID = @gdgid
      and BWRH = @wrh
      and ASTORE = @store
    ) begin
      insert into INVCHGDRPTI (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @wrh, @store)
    end
    if not exists (
      select *
      from INVCHGDRPT
      where ASETTLENO = @settleno
      and ADATE = @date
      and BGDGID = @gdgid
      and BWRH = @wrh
      and ASTORE = @store
    ) begin
      insert into INVCHGDRPT (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @wrh, @store)
    end
    update INVCHGDRPT set
      DQ4 = DQ4 + NDJ_Q,
      DI4 = convert( dec(20,2), DI4 + NDJ_I ),
      DR4 = convert( dec(20,2), DR4 + NDJ_R ),
      DQ5 = DQ5 + NDC_Q,
      DI5 = convert( dec(20,2), DI5 + NDC_I ),
      DR5 = convert( dec(20,2), DR5 + NDC_R ),
      LSTUPDTIME = getdate()
    from inserted
    where INVCHGDRPT.ASETTLENO = @settleno
    and INVCHGDRPT.ADATE = @date
    and INVCHGDRPT.BGDGID = @gdgid
    and INVCHGDRPT.BWRH = @wrh
    and INVCHGDRPT.ASTORE = @store
    -- 库存调整月报
    if not exists (
      select *
      from INVCHGMRPT
      where ASETTLENO = @settleno
      and BGDGID = @gdgid
      and BWRH = @wrh
      and ASTORE = @store
    ) begin
      insert into INVCHGMRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
      values (@settleno, @gdgid, @wrh, @store)
    end
    update INVCHGMRPT set
      DQ4 = DQ4 + NDJ_Q,
      DI4 = convert( dec(20,2), DI4 + NDJ_I ),
      DR4 = convert( dec(20,2), DR4 + NDJ_R ),
      DQ5 = DQ5 + NDC_Q,
      DI5 = convert( dec(20,2), DI5 + NDC_I ),
      DR5 = convert( dec(20,2), DR5 + NDC_R )
    from inserted
    where INVCHGMRPT.ASETTLENO = @settleno
    and INVCHGMRPT.BGDGID = @gdgid
    and INVCHGMRPT.BWRH = @wrh
    and INVCHGMRPT.ASTORE = @store
    -- 库存调整年报
    if not exists (
      select *
      from INVCHGYRPT
      where ASETTLENO = @yno
      and BGDGID = @gdgid
      and BWRH = @wrh
      and ASTORE = @store
    ) begin
      insert into INVCHGYRPT (ASETTLENO, BGDGID, BWRH, ASTORE)
      values (@yno, @gdgid, @wrh, @store)
    end
    update INVCHGYRPT set
      DQ4 = DQ4 + NDJ_Q,
      DI4 = convert( dec(20,2), DI4 + NDJ_I ),
      DR4 = convert( dec(20,2), DR4 + NDJ_R ),
      DQ5 = DQ5 + NDC_Q,
      DI5 = convert( dec(20,2), DI5 + NDC_I ),
      DR5 = convert( dec(20,2), DR5 + NDC_R )
    from inserted
    where INVCHGYRPT.ASETTLENO = @yno
    and INVCHGYRPT.BGDGID = @gdgid
    and INVCHGYRPT.BWRH = @wrh
    and INVCHGYRPT.ASTORE = @store
  end

  --delete from DB
end
GO
