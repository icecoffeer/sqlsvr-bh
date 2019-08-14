CREATE TABLE [dbo].[PC]
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
[PC_Q] [money] NULL CONSTRAINT [DF__PC__PC_Q__1ADFB5F3] DEFAULT (0),
[PC_A] [money] NULL CONSTRAINT [DF__PC__PC_A__1BD3DA2C] DEFAULT (0),
[PC_T] [money] NULL CONSTRAINT [DF__PC__PC_T__1CC7FE65] DEFAULT (0),
[PC_I] [money] NULL CONSTRAINT [DF__PC__PC_I__1DBC229E] DEFAULT (0),
[PC_R] [money] NULL CONSTRAINT [DF__PC__PC_R__1EB046D7] DEFAULT (0),
[PC_Q_B] [money] NULL CONSTRAINT [DF__PC__PC_Q_B__1FA46B10] DEFAULT (0),
[PC_A_B] [money] NULL CONSTRAINT [DF__PC__PC_A_B__20988F49] DEFAULT (0),
[PC_T_B] [money] NULL CONSTRAINT [DF__PC__PC_T_B__218CB382] DEFAULT (0),
[PC_I_B] [money] NULL CONSTRAINT [DF__PC__PC_I_B__2280D7BB] DEFAULT (0),
[PC_R_B] [money] NULL CONSTRAINT [DF__PC__PC_R_B__2374FBF4] DEFAULT (0),
[PC_Q_S] [money] NULL CONSTRAINT [DF__PC__PC_Q_S__2469202D] DEFAULT (0),
[PC_A_S] [money] NULL CONSTRAINT [DF__PC__PC_A_S__255D4466] DEFAULT (0),
[PC_T_S] [money] NULL CONSTRAINT [DF__PC__PC_T_S__2651689F] DEFAULT (0),
[PC_I_S] [money] NULL CONSTRAINT [DF__PC__PC_I_S__27458CD8] DEFAULT (0),
[PC_R_S] [money] NULL CONSTRAINT [DF__PC__PC_R_S__2839B111] DEFAULT (0),
[PCT_Q] [money] NULL CONSTRAINT [DF__PC__PCT_Q__292DD54A] DEFAULT (0),
[PCT_A] [money] NULL CONSTRAINT [DF__PC__PCT_A__2A21F983] DEFAULT (0),
[PCT_T] [money] NULL CONSTRAINT [DF__PC__PCT_T__2B161DBC] DEFAULT (0),
[PCT_I] [money] NULL CONSTRAINT [DF__PC__PCT_I__2C0A41F5] DEFAULT (0),
[PCT_R] [money] NULL CONSTRAINT [DF__PC__PCT_R__2CFE662E] DEFAULT (0),
[PCT_Q_B] [money] NULL CONSTRAINT [DF__PC__PCT_Q_B__2DF28A67] DEFAULT (0),
[PCT_A_B] [money] NULL CONSTRAINT [DF__PC__PCT_A_B__2EE6AEA0] DEFAULT (0),
[PCT_T_B] [money] NULL CONSTRAINT [DF__PC__PCT_T_B__2FDAD2D9] DEFAULT (0),
[PCT_I_B] [money] NULL CONSTRAINT [DF__PC__PCT_I_B__30CEF712] DEFAULT (0),
[PCT_R_B] [money] NULL CONSTRAINT [DF__PC__PCT_R_B__31C31B4B] DEFAULT (0),
[PCT_Q_S] [money] NULL CONSTRAINT [DF__PC__PCT_Q_S__32B73F84] DEFAULT (0),
[PCT_A_S] [money] NULL CONSTRAINT [DF__PC__PCT_A_S__33AB63BD] DEFAULT (0),
[PCT_T_S] [money] NULL CONSTRAINT [DF__PC__PCT_T_S__349F87F6] DEFAULT (0),
[PCT_I_S] [money] NULL CONSTRAINT [DF__PC__PCT_I_S__3593AC2F] DEFAULT (0),
[PCT_R_S] [money] NULL CONSTRAINT [DF__PC__PCT_R_S__3687D068] DEFAULT (0),
[ZPC_Q] [money] NULL CONSTRAINT [DF__PC__ZPC_Q__377BF4A1] DEFAULT (0),
[ZPC_A] [money] NULL CONSTRAINT [DF__PC__ZPC_A__387018DA] DEFAULT (0),
[ZPC_T] [money] NULL CONSTRAINT [DF__PC__ZPC_T__39643D13] DEFAULT (0),
[ZPC_I] [money] NULL CONSTRAINT [DF__PC__ZPC_I__3A58614C] DEFAULT (0),
[ZPC_R] [money] NULL CONSTRAINT [DF__PC__ZPC_R__3B4C8585] DEFAULT (0),
[ZPC_Q_B] [money] NULL CONSTRAINT [DF__PC__ZPC_Q_B__3C40A9BE] DEFAULT (0),
[ZPC_A_B] [money] NULL CONSTRAINT [DF__PC__ZPC_A_B__3D34CDF7] DEFAULT (0),
[ZPC_T_B] [money] NULL CONSTRAINT [DF__PC__ZPC_T_B__3E28F230] DEFAULT (0),
[ZPC_I_B] [money] NULL CONSTRAINT [DF__PC__ZPC_I_B__3F1D1669] DEFAULT (0),
[ZPC_R_B] [money] NULL CONSTRAINT [DF__PC__ZPC_R_B__40113AA2] DEFAULT (0),
[ZPC_Q_S] [money] NULL CONSTRAINT [DF__PC__ZPC_Q_S__41055EDB] DEFAULT (0),
[ZPC_A_S] [money] NULL CONSTRAINT [DF__PC__ZPC_A_S__41F98314] DEFAULT (0),
[ZPC_T_S] [money] NULL CONSTRAINT [DF__PC__ZPC_T_S__42EDA74D] DEFAULT (0),
[ZPC_I_S] [money] NULL CONSTRAINT [DF__PC__ZPC_I_S__43E1CB86] DEFAULT (0),
[ZPC_R_S] [money] NULL CONSTRAINT [DF__PC__ZPC_R_S__44D5EFBF] DEFAULT (0),
[ZPCT_Q] [money] NULL CONSTRAINT [DF__PC__ZPCT_Q__45CA13F8] DEFAULT (0),
[ZPCT_A] [money] NULL CONSTRAINT [DF__PC__ZPCT_A__46BE3831] DEFAULT (0),
[ZPCT_T] [money] NULL CONSTRAINT [DF__PC__ZPCT_T__47B25C6A] DEFAULT (0),
[ZPCT_I] [money] NULL CONSTRAINT [DF__PC__ZPCT_I__48A680A3] DEFAULT (0),
[ZPCT_R] [money] NULL CONSTRAINT [DF__PC__ZPCT_R__499AA4DC] DEFAULT (0),
[ZPCT_Q_B] [money] NULL CONSTRAINT [DF__PC__ZPCT_Q_B__4A8EC915] DEFAULT (0),
[ZPCT_A_B] [money] NULL CONSTRAINT [DF__PC__ZPCT_A_B__4B82ED4E] DEFAULT (0),
[ZPCT_T_B] [money] NULL CONSTRAINT [DF__PC__ZPCT_T_B__4C771187] DEFAULT (0),
[ZPCT_I_B] [money] NULL CONSTRAINT [DF__PC__ZPCT_I_B__4D6B35C0] DEFAULT (0),
[ZPCT_R_B] [money] NULL CONSTRAINT [DF__PC__ZPCT_R_B__4E5F59F9] DEFAULT (0),
[ZPCT_Q_S] [money] NULL CONSTRAINT [DF__PC__ZPCT_Q_S__4F537E32] DEFAULT (0),
[ZPCT_A_S] [money] NULL CONSTRAINT [DF__PC__ZPCT_A_S__5047A26B] DEFAULT (0),
[ZPCT_T_S] [money] NULL CONSTRAINT [DF__PC__ZPCT_T_S__513BC6A4] DEFAULT (0),
[ZPCT_I_S] [money] NULL CONSTRAINT [DF__PC__ZPCT_I_S__522FEADD] DEFAULT (0),
[ZPCT_R_S] [money] NULL CONSTRAINT [DF__PC__ZPCT_R_S__53240F16] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[EPC_INS] ON [dbo].[PC] INSTEAD OF INSERT
as
begin
  -- 出货日报,月报,年报
  -- 供应商帐款日报,月报,年报

  declare
    @return_status int,
    @settleno int,
    @date datetime,
    @wrh int,
    @gdgid int,
    @vdrgid int,
    @cstgid int,
    @slrgid int,
    @psrgid int,
    @posno char(10),
    @store int

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('ZJ_INS', 16, 1)
    return
  end
  -- 取关键字
  select
    @date = ADATE,
    @settleno = ASETTLENO,
    @wrh = BWRH,
    @gdgid = BGDGID,
    @vdrgid = BVDRGID,
    @cstgid = BCSTGID,
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

  -- 出货日报,月报,年报
  if (select
      PC_Q + PC_Q_B + PC_Q_S + ZPC_Q + ZPC_Q_B + ZPC_Q_S
      + PCT_Q + PCT_Q_B + PCT_Q_S + ZPCT_Q + ZPCT_Q_B + ZPCT_Q_S
      + PC_A + PC_A_B + PC_A_S + ZPC_A + ZPC_A_B + ZPC_A_S
                + PC_T + PC_T_B + PC_T_S + ZPC_T + ZPC_T_B + ZPC_T_S
      + PCT_A + PCT_A_B + PCT_A_S + ZPCT_A + ZPCT_A_B + ZPCT_A_S
                + PCT_T + PCT_T_B + PCT_T_S + ZPCT_T + ZPCT_T_B + ZPCT_T_S
      + PC_I + PC_I_B + PC_I_S + ZPC_I + ZPC_I_B + ZPC_I_S
      + PCT_I + PCT_I_B + PCT_I_S + ZPCT_I + ZPCT_I_B + ZPCT_I_S
      + PC_R + PC_R_B + PC_R_S + ZPC_R + ZPC_R_B + ZPC_R_S
      + PCT_R + PCT_R_B + PCT_R_S + ZPCT_R + ZPCT_R_B + ZPCT_R_S
  from inserted) <> 0 begin
    -- 出货日报
    if not exists ( select * from OUTDRPTI
    where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
    and BCSTGID = @cstgid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTDRPTI (ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @cstgid, @wrh, @store)
    end
    if not exists ( select * from OUTDRPT
    where ASETTLENO = @settleno and ADATE = @date and BGDGID = @gdgid
    and BCSTGID = @cstgid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTDRPT (ASETTLENO, ADATE, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @date, @gdgid, @cstgid, @wrh, @store)
    end
    update OUTDRPT set
      DQ4 = DQ4 + PC_Q + PC_Q_B + PC_Q_S + ZPC_Q + ZPC_Q_B + ZPC_Q_S,
      DQ7 = DQ7 + PCT_Q + PCT_Q_B + PCT_Q_S + ZPCT_Q + ZPCT_Q_B + ZPCT_Q_S,
      DT4 = convert( dec(20,2),
            DT4 + PC_A + PC_A_B + PC_A_S + ZPC_A + ZPC_A_B + ZPC_A_S
                + PC_T + PC_T_B + PC_T_S + ZPC_T + ZPC_T_B + ZPC_T_S ),
      DT7 = convert( dec(20,2),
            DT7 + PCT_A + PCT_A_B + PCT_A_S + ZPCT_A + ZPCT_A_B + ZPCT_A_S
                + PCT_T + PCT_T_B + PCT_T_S + ZPCT_T + ZPCT_T_B + ZPCT_T_S ),
      DI4 = convert( dec(20,2),
            DI4 + PC_I + PC_I_B + PC_I_S + ZPC_I + ZPC_I_B + ZPC_I_S ),
      DI7 = convert( dec(20,2),
            DI7 + PCT_I + PCT_I_B + PCT_I_S + ZPCT_I + ZPCT_I_B + ZPCT_I_S ),
      DR4 = convert( dec(20,2),
            DR4 + PC_R + PC_R_B + PC_R_S + ZPC_R + ZPC_R_B + ZPC_R_S ),
      DR7 = convert( dec(20,2),
            DR7 + PCT_R + PCT_R_B + PCT_R_S + ZPCT_R + ZPCT_R_B + ZPCT_R_S ),
      LSTUPDTIME = getdate()
    from inserted
    where OUTDRPT.ASETTLENO = @settleno
    and OUTDRPT.ADATE = @date
    and OUTDRPT.BGDGID = @gdgid
    and OUTDRPT.BCSTGID = @cstgid
    and OUTDRPT.BWRH = @wrh
    and OUTDRPT.ASTORE = @store
    -- 出货月报
    if not exists ( select * from OUTMRPT
    where ASETTLENO = @settleno and BGDGID = @gdgid
    and BCSTGID = @cstgid and BWRH = @wrh and ASTORE = @store) begin
      insert into OUTMRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@settleno, @gdgid, @cstgid, @wrh, @store)
    end
    update OUTMRPT set
      DQ4 = DQ4 + PC_Q + PC_Q_B + PC_Q_S + ZPC_Q + ZPC_Q_B + ZPC_Q_S,
      DQ7 = DQ7 + PCT_Q + PCT_Q_B + PCT_Q_S + ZPCT_Q + ZPCT_Q_B + ZPCT_Q_S,
      DT4 = convert( dec(20,2),
            DT4 + PC_A + PC_A_B + PC_A_S + ZPC_A + ZPC_A_B + ZPC_A_S
                + PC_T + PC_T_B + PC_T_S + ZPC_T + ZPC_T_B + ZPC_T_S ),
      DT7 = convert( dec(20,2),
            DT7 + PCT_A + PCT_A_B + PCT_A_S + ZPCT_A + ZPCT_A_B + ZPCT_A_S
                + PCT_T + PCT_T_B + PCT_T_S + ZPCT_T + ZPCT_T_B + ZPCT_T_S ),
      DI4 = convert( dec(20,2),
            DI4 + PC_I + PC_I_B + PC_I_S + ZPC_I + ZPC_I_B + ZPC_I_S ),
      DI7 = convert( dec(20,2),
            DI7 + PCT_I + PCT_I_B + PCT_I_S + ZPCT_I + ZPCT_I_B + ZPCT_I_S ),
      DR4 = convert( dec(20,2),
            DR4 + PC_R + PC_R_B + PC_R_S + ZPC_R + ZPC_R_B + ZPC_R_S ),
      DR7 = convert( dec(20,2),
            DR7 + PCT_R + PCT_R_B + PCT_R_S + ZPCT_R + ZPCT_R_B + ZPCT_R_S )
    from inserted
    where OUTMRPT.ASETTLENO = @settleno
    and OUTMRPT.BGDGID = @gdgid
    and OUTMRPT.BCSTGID = @cstgid
    and OUTMRPT.BWRH = @wrh
    and OUTMRPT.ASTORE = @store
    -- 出货年报
    if not exists ( select * from OUTYRPT
    where ASETTLENO = @yno and BGDGID = @gdgid and ASTORE = @store
    and BCSTGID = @cstgid and BWRH = @wrh) begin
      insert into OUTYRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
      values (@yno, @gdgid, @cstgid, @wrh, @store)
    end
    update OUTYRPT set
      DQ4 = DQ4 + PC_Q + PC_Q_B + PC_Q_S + ZPC_Q + ZPC_Q_B + ZPC_Q_S,
      DQ7 = DQ7 + PCT_Q + PCT_Q_B + PCT_Q_S + ZPCT_Q + ZPCT_Q_B + ZPCT_Q_S,
      DT4 = convert( dec(20,2),
            DT4 + PC_A + PC_A_B + PC_A_S + ZPC_A + ZPC_A_B + ZPC_A_S
                + PC_T + PC_T_B + PC_T_S + ZPC_T + ZPC_T_B + ZPC_T_S ),
      DT7 = convert( dec(20,2),
            DT7 + PCT_A + PCT_A_B + PCT_A_S + ZPCT_A + ZPCT_A_B + ZPCT_A_S
                + PCT_T + PCT_T_B + PCT_T_S + ZPCT_T + ZPCT_T_B + ZPCT_T_S ),
      DI4 = convert( dec(20,2),
            DI4 + PC_I + PC_I_B + PC_I_S + ZPC_I + ZPC_I_B + ZPC_I_S ),
      DI7 = convert( dec(20,2),
            DI7 + PCT_I + PCT_I_B + PCT_I_S + ZPCT_I + ZPCT_I_B + ZPCT_I_S ),
      DR4 = convert( dec(20,2),
            DR4 + PC_R + PC_R_B + PC_R_S + ZPC_R + ZPC_R_B + ZPC_R_S ),
      DR7 = convert( dec(20,2),
            DR7 + PCT_R + PCT_R_B + PCT_R_S + ZPCT_R + ZPCT_R_B + ZPCT_R_S )
    from inserted
    where OUTYRPT.ASETTLENO = @yno
    and OUTYRPT.BGDGID = @gdgid and OUTYRPT.BCSTGID = @cstgid
    and OUTYRPT.BWRH = @wrh
    and OUTYRPT.ASTORE = @store
  end
end
GO
