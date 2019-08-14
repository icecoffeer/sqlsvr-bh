CREATE TABLE [dbo].[XS]
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
[WC_Q] [money] NULL CONSTRAINT [DF__XS__WC_Q__581DCE5D] DEFAULT (0),
[WC_A] [money] NULL CONSTRAINT [DF__XS__WC_A__5911F296] DEFAULT (0),
[WC_T] [money] NULL CONSTRAINT [DF__XS__WC_T__5A0616CF] DEFAULT (0),
[WC_I] [money] NULL CONSTRAINT [DF__XS__WC_I__5AFA3B08] DEFAULT (0),
[WC_R] [money] NULL CONSTRAINT [DF__XS__WC_R__5BEE5F41] DEFAULT (0),
[WC_Q_B] [money] NULL CONSTRAINT [DF__XS__WC_Q_B__5CE2837A] DEFAULT (0),
[WC_A_B] [money] NULL CONSTRAINT [DF__XS__WC_A_B__5DD6A7B3] DEFAULT (0),
[WC_T_B] [money] NULL CONSTRAINT [DF__XS__WC_T_B__5ECACBEC] DEFAULT (0),
[WC_I_B] [money] NULL CONSTRAINT [DF__XS__WC_I_B__5FBEF025] DEFAULT (0),
[WC_R_B] [money] NULL CONSTRAINT [DF__XS__WC_R_B__60B3145E] DEFAULT (0),
[WC_Q_S] [money] NULL CONSTRAINT [DF__XS__WC_Q_S__61A73897] DEFAULT (0),
[WC_A_S] [money] NULL CONSTRAINT [DF__XS__WC_A_S__629B5CD0] DEFAULT (0),
[WC_T_S] [money] NULL CONSTRAINT [DF__XS__WC_T_S__638F8109] DEFAULT (0),
[WC_I_S] [money] NULL CONSTRAINT [DF__XS__WC_I_S__6483A542] DEFAULT (0),
[WC_R_S] [money] NULL CONSTRAINT [DF__XS__WC_R_S__6577C97B] DEFAULT (0),
[WCT_Q] [money] NULL CONSTRAINT [DF__XS__WCT_Q__666BEDB4] DEFAULT (0),
[WCT_A] [money] NULL CONSTRAINT [DF__XS__WCT_A__676011ED] DEFAULT (0),
[WCT_T] [money] NULL CONSTRAINT [DF__XS__WCT_T__68543626] DEFAULT (0),
[WCT_I] [money] NULL CONSTRAINT [DF__XS__WCT_I__69485A5F] DEFAULT (0),
[WCT_R] [money] NULL CONSTRAINT [DF__XS__WCT_R__6A3C7E98] DEFAULT (0),
[WCT_Q_B] [money] NULL CONSTRAINT [DF__XS__WCT_Q_B__6B30A2D1] DEFAULT (0),
[WCT_A_B] [money] NULL CONSTRAINT [DF__XS__WCT_A_B__6C24C70A] DEFAULT (0),
[WCT_T_B] [money] NULL CONSTRAINT [DF__XS__WCT_T_B__6D18EB43] DEFAULT (0),
[WCT_I_B] [money] NULL CONSTRAINT [DF__XS__WCT_I_B__6E0D0F7C] DEFAULT (0),
[WCT_R_B] [money] NULL CONSTRAINT [DF__XS__WCT_R_B__6F0133B5] DEFAULT (0),
[WCT_Q_S] [money] NULL CONSTRAINT [DF__XS__WCT_Q_S__6FF557EE] DEFAULT (0),
[WCT_A_S] [money] NULL CONSTRAINT [DF__XS__WCT_A_S__70E97C27] DEFAULT (0),
[WCT_T_S] [money] NULL CONSTRAINT [DF__XS__WCT_T_S__71DDA060] DEFAULT (0),
[WCT_I_S] [money] NULL CONSTRAINT [DF__XS__WCT_I_S__72D1C499] DEFAULT (0),
[WCT_R_S] [money] NULL CONSTRAINT [DF__XS__WCT_R_S__73C5E8D2] DEFAULT (0),
[LS_Q] [money] NULL CONSTRAINT [DF__XS__LS_Q__74BA0D0B] DEFAULT (0),
[LS_A] [money] NULL CONSTRAINT [DF__XS__LS_A__75AE3144] DEFAULT (0),
[LS_T] [money] NULL CONSTRAINT [DF__XS__LS_T__76A2557D] DEFAULT (0),
[LS_I] [money] NULL CONSTRAINT [DF__XS__LS_I__779679B6] DEFAULT (0),
[LS_R] [money] NULL CONSTRAINT [DF__XS__LS_R__788A9DEF] DEFAULT (0),
[LS_Q_B] [money] NULL CONSTRAINT [DF__XS__LS_Q_B__797EC228] DEFAULT (0),
[LS_A_B] [money] NULL CONSTRAINT [DF__XS__LS_A_B__7A72E661] DEFAULT (0),
[LS_T_B] [money] NULL CONSTRAINT [DF__XS__LS_T_B__7B670A9A] DEFAULT (0),
[LS_I_B] [money] NULL CONSTRAINT [DF__XS__LS_I_B__7C5B2ED3] DEFAULT (0),
[LS_R_B] [money] NULL CONSTRAINT [DF__XS__LS_R_B__7D4F530C] DEFAULT (0),
[LS_Q_S] [money] NULL CONSTRAINT [DF__XS__LS_Q_S__7E437745] DEFAULT (0),
[LS_A_S] [money] NULL CONSTRAINT [DF__XS__LS_A_S__7F379B7E] DEFAULT (0),
[LS_T_S] [money] NULL CONSTRAINT [DF__XS__LS_T_S__002BBFB7] DEFAULT (0),
[LS_I_S] [money] NULL CONSTRAINT [DF__XS__LS_I_S__011FE3F0] DEFAULT (0),
[LS_R_S] [money] NULL CONSTRAINT [DF__XS__LS_R_S__02140829] DEFAULT (0),
[LST_Q] [money] NULL CONSTRAINT [DF__XS__LST_Q__03082C62] DEFAULT (0),
[LST_A] [money] NULL CONSTRAINT [DF__XS__LST_A__03FC509B] DEFAULT (0),
[LST_T] [money] NULL CONSTRAINT [DF__XS__LST_T__04F074D4] DEFAULT (0),
[LST_I] [money] NULL CONSTRAINT [DF__XS__LST_I__05E4990D] DEFAULT (0),
[LST_R] [money] NULL CONSTRAINT [DF__XS__LST_R__06D8BD46] DEFAULT (0),
[LST_Q_B] [money] NULL CONSTRAINT [DF__XS__LST_Q_B__07CCE17F] DEFAULT (0),
[LST_A_B] [money] NULL CONSTRAINT [DF__XS__LST_A_B__08C105B8] DEFAULT (0),
[LST_T_B] [money] NULL CONSTRAINT [DF__XS__LST_T_B__09B529F1] DEFAULT (0),
[LST_I_B] [money] NULL CONSTRAINT [DF__XS__LST_I_B__0AA94E2A] DEFAULT (0),
[LST_R_B] [money] NULL CONSTRAINT [DF__XS__LST_R_B__0B9D7263] DEFAULT (0),
[LST_Q_S] [money] NULL CONSTRAINT [DF__XS__LST_Q_S__0C91969C] DEFAULT (0),
[LST_A_S] [money] NULL CONSTRAINT [DF__XS__LST_A_S__0D85BAD5] DEFAULT (0),
[LST_T_S] [money] NULL CONSTRAINT [DF__XS__LST_T_S__0E79DF0E] DEFAULT (0),
[LST_I_S] [money] NULL CONSTRAINT [DF__XS__LST_I_S__0F6E0347] DEFAULT (0),
[LST_R_S] [money] NULL CONSTRAINT [DF__XS__LST_R_S__10622780] DEFAULT (0),
[LS1_Q] [money] NULL CONSTRAINT [DF__XS__LS1_Q__11564BB9] DEFAULT (0),
[LS1_A] [money] NULL CONSTRAINT [DF__XS__LS1_A__124A6FF2] DEFAULT (0),
[LS1_T] [money] NULL CONSTRAINT [DF__XS__LS1_T__133E942B] DEFAULT (0),
[LS2_Q] [money] NULL CONSTRAINT [DF__XS__LS2_Q__1432B864] DEFAULT (0),
[LS2_A] [money] NULL CONSTRAINT [DF__XS__LS2_A__1526DC9D] DEFAULT (0),
[LS2_T] [money] NULL CONSTRAINT [DF__XS__LS2_T__161B00D6] DEFAULT (0),
[LS3_Q] [money] NULL CONSTRAINT [DF__XS__LS3_Q__170F250F] DEFAULT (0),
[LS3_A] [money] NULL CONSTRAINT [DF__XS__LS3_A__18034948] DEFAULT (0),
[LS3_T] [money] NULL CONSTRAINT [DF__XS__LS3_T__18F76D81] DEFAULT (0),
[PARAM] [smallint] NULL CONSTRAINT [DF__XS__PARAM__64CE895C] DEFAULT (11),
[ACNT] [smallint] NOT NULL CONSTRAINT [DF__XS__ACNT__7A6B26C5] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
99-11-29
param action
00    OUTXRPT(CSTGID=1,每天每个商品)
01    OUTXRPT(CSTGID=1,每天每个商品),CSTXRPT(CSTGID=X,每天每个商品)
10    OUTXRPT(CSTGID=X,每天每个商品)
11    OUTXRPT(CSTGID=X,每天每个商品),CSTXRPT(CSTGID=X,每天每个商品)
2002.08.04  add by cyb
  2002072249052:代销结算库存控制——服务端
2002-09-26  姚力
  2002092647996:代销结算单服务端要判断hdoption
2002.11.15 张雁波
  2002111538991：联销商品按门店结算
2003.08.28 Modified by wang xin
 912 出货月报数据过大改进
*/

CREATE TRIGGER [dbo].[EXS_INS] ON [dbo].[XS] INSTEAD OF INSERT
as
begin
  -- 出货日报,月报,年报
  -- 供应商帐款月报,年报
  -- 客户帐款月报,年报

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
    @yno int,
    @cur_date datetime,
    @temp_date datetime,
    @cur_settleno int,
    @cur_yno int,
    @di2 money,
    @oriclngid int,
    @param int,
    @optvalue int,/*2002-09-26*/
    @mode smallint /*add by jinlei 3692*/

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('XS_INS', 16, 1)
    return
  end
  set @mode = 0;/*默认值为计账款 add by jinlei 3692*/
  -- 取关键字
  select
    @date = ADATE,
    @settleno = ASETTLENO,
    @wrh = BWRH,
    @gdgid = BGDGID,
    @vdrgid = BVDRGID,
    @oriclngid = BCSTGID,
    @slrgid = BSLRGID,
    @psrgid = BPSRGID,
    @posno = BPOSNO,
    @store = ASTORE,
    @param = PARAM,
    @mode = ACNT /*add by jinlei 3692*/
    from inserted

  select @store = null
  select @store = GID from STORE where GID = @wrh
  if @store is null select @store = USERGID from SYSTEM
  else select @wrh = 1

  select @yno = YNO from V_YM where MNO = @settleno
  select @cur_date = convert(datetime, convert(char, getdate(),102))
  if @cur_date <> @date
  begin
    select @cur_settleno = MAX(NO) from MONTHSETTLE
    select @cur_yno = MAX(NO) from YEARSETTLE
  end
  if @mode in (0, 1)
  begin
      -- 出货日报,月报,年报
      if (select
          LS_Q + LS_Q_B + LS_Q_S
          + WC_Q + WC_Q_B + WC_Q_S
          + LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S
          + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S
          + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S
          + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S
                + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S
          + LS_I + LS_I_B + LS_I_S
          + WC_I + WC_I_B + WC_I_S
          + LST_I + LST_I_B + LST_I_S + WCT_I + WCT_I_B + WCT_I_S
          + LS_R + LS_R_B + LS_R_S
          + WC_R + WC_R_B + WC_R_S
          + LST_R + LST_R_B + LST_R_S + WCT_R + WCT_R_B + WCT_R_S
          + LS1_A + LS1_T + LS2_A + LS2_T + LS3_A + LS3_T
      from inserted) <> 0 begin
        execute CRTINVRPT @store, @settleno, @date, @wrh, @gdgid
        /* 99-11-29 */
        if @param in (10,11) select @clngid = @oriclngid
        else /* if @param in (0,1) */ select @clngid = 1
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
          DQ1 = DQ1 + LS_Q + LS_Q_B + LS_Q_S,
          DQ2 = DQ2 + WC_Q + WC_Q_B + WC_Q_S,
          DQ5 = DQ5 + LST_Q + LST_Q_B + LST_Q_S,
          DQ6 = DQ6 + WCT_Q + WCT_Q_B + WCT_Q_S,
          DT1 = DT1 + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S,
          DT2 = DT2 + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S,
          DT5 = DT5 + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S,
          DT6 = DT6 + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S,
          DT91 = DT91 + LS1_A + LS1_T,
          DT92 = DT92 + LS2_A + LS2_T + LS3_A + LS3_T,
          DI1 = convert( dec(20,2), DI1 + LS_I + LS_I_B + LS_I_S ),
          DI2 = convert( dec(20,2), DI2 + WC_I + WC_I_B + WC_I_S ),
          DI5 = convert( dec(20,2), DI5 + LST_I + LST_I_B + LST_I_S ),
          DI6 = convert( dec(20,2), DI6 + WCT_I + WCT_I_B + WCT_I_S ),
          DR1 = convert( dec(20,2), DR1 + LS_R + LS_R_B + LS_R_S ),
          DR2 = convert( dec(20,2), DR2 + WC_R + WC_R_B + WC_R_S ),
          DR5 = convert( dec(20,2), DR5 + LST_R + LST_R_B + LST_R_S ),
          DR6 = convert( dec(20,2), DR6 + WCT_R + WCT_R_B + WCT_R_S ),
          LSTUPDTIME = getdate()
        from inserted
        where OUTDRPT.ASETTLENO = @settleno and OUTDRPT.ADATE = @date
        and OUTDRPT.BGDGID = @gdgid and OUTDRPT.BCSTGID = @clngid
        and OUTDRPT.BWRH = @wrh
        and OUTDRPT.ASTORE = @store
        if @cur_date <> @date
        begin
          select @temp_date = dateadd(day, 1, @date)
          while @temp_date <= @cur_date
          begin
            if not exists (select * from INVDRPT
            where ASETTLENO = @settleno and ADATE = @temp_date and BGDGID = @gdgid
            and BWRH = @wrh and ASTORE = @store)
              insert into INVDRPT (ASETTLENO, ADATE, BGDGID, BWRH, ASTORE)
                values (@settleno, @temp_date, @gdgid, @wrh, @store)
            select @temp_date = dateadd(day, 1, @temp_date)
          end
          update INVDRPT set
            CQ = CQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S),
            LSTUPDTIME = getdate()
          from inserted
          where INVDRPT.ASETTLENO = @settleno and INVDRPT.ADATE > @date
          and INVDRPT.ADATE <= @cur_date
          and INVDRPT.BGDGID = @gdgid
          and INVDRPT.BWRH = @wrh
          and INVDRPT.ASTORE = @store
          update INVDRPT set
            FQ = FQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S),
            LSTUPDTIME = getdate()
          from inserted
          where INVDRPT.ASETTLENO = @settleno and INVDRPT.ADATE >= @date
          and INVDRPT.ADATE < @cur_date
          and INVDRPT.BGDGID = @gdgid
          and INVDRPT.BWRH = @wrh
          and INVDRPT.ASTORE = @store
        end
        -- 出货月报
        if not exists ( select * from OUTMRPT
        where ASETTLENO = @settleno and BGDGID = @gdgid
        and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
          insert into OUTMRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
          values (@settleno, @gdgid, @clngid, @wrh, @store)
        end
        update OUTMRPT set
          DQ1 = DQ1 + LS_Q + LS_Q_B + LS_Q_S,
          DQ2 = DQ2 + WC_Q + WC_Q_B + WC_Q_S,
          DQ5 = DQ5 + LST_Q + LST_Q_B + LST_Q_S,
          DQ6 = DQ6 + WCT_Q + WCT_Q_B + WCT_Q_S,
          DT1 = DT1 + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S,
          DT2 = DT2 + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S,
          DT5 = DT5 + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S,
          DT6 = DT6 + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S,
          DT91 = DT91 + LS1_A + LS1_T,
          DT92 = DT92 + LS2_A + LS2_T + LS3_A + LS3_T,
          DI1 = convert( dec(20,2), DI1 + LS_I + LS_I_B + LS_I_S ),
          DI2 = convert( dec(20,2), DI2 + WC_I + WC_I_B + WC_I_S ),
          DI5 = convert( dec(20,2), DI5 + LST_I + LST_I_B + LST_I_S ),
          DI6 = convert( dec(20,2), DI6 + WCT_I + WCT_I_B + WCT_I_S ),
          DR1 = convert( dec(20,2), DR1 + LS_R + LS_R_B + LS_R_S ),
          DR2 = convert( dec(20,2), DR2 + WC_R + WC_R_B + WC_R_S ),
          DR5 = convert( dec(20,2), DR5 + LST_R + LST_R_B + LST_R_S ),
DR6 = convert( dec(20,2), DR6 + WCT_R + WCT_R_B + WCT_R_S )
        from inserted
        where OUTMRPT.ASETTLENO = @settleno
        and OUTMRPT.BGDGID = @gdgid and OUTMRPT.BCSTGID = @clngid
        and OUTMRPT.BWRH = @wrh
        and OUTMRPT.ASTORE = @store
        if @cur_settleno <> @settleno
        begin
          /*update OUTMRPT set
            CQ1 = CQ1 + LS_Q + LS_Q_B + LS_Q_S,
            CQ2 = CQ2 + WC_Q + WC_Q_B + WC_Q_S,
            CQ5 = CQ5 + LST_Q + LST_Q_B + LST_Q_S,
            CQ6 = CQ6 + WCT_Q + WCT_Q_B + WCT_Q_S,
            CT1 = CT1 + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S,
            CT2 = CT2 + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S,
            CT5 = CT5 + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S,
            CT6 = CT6 + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S,
            CT91 = CT91 + LS1_A + LS1_T,
            CT92 = CT92 + LS2_A + LS2_T + LS3_A + LS3_T,
            CI1 = convert( dec(20,2), CI1 + LS_I + LS_I_B + LS_I_S ),
            CI2 = convert( dec(20,2), CI2 + WC_I + WC_I_B + WC_I_S ),
            CI5 = convert( dec(20,2), CI5 + LST_I + LST_I_B + LST_I_S ),
            CI6 = convert( dec(20,2),  CI6 + WCT_I + WCT_I_B + WCT_I_S ),
            CR1 = convert( dec(20,2),  CR1 + LS_R + LS_R_B + LS_R_S ),
            CR2 = convert( dec(20,2),  CR2 + WC_R + WC_R_B + WC_R_S ),
            CR5 = convert( dec(20,2),  CR5 + LST_R + LST_R_B + LST_R_S ),
            CR6 = convert( dec(20,2),  CR6 + WCT_R + WCT_R_B + WCT_R_S )
          from inserted
          where OUTMRPT.ASETTLENO > @settleno
          and OUTMRPT.ASETTLENO <= @cur_settleno
          and OUTMRPT.BGDGID = @gdgid and OUTMRPT.BCSTGID = @clngid
          and OUTMRPT.BWRH = @wrh
          and OUTMRPT.ASTORE = @store*/
          update INVMRPT set
            CQ = CQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S)
          from inserted
          where INVMRPT.ASETTLENO > @settleno
          and INVMRPT.ASETTLENO <= @cur_settleno
   and INVMRPT.BGDGID = @gdgid
          and INVMRPT.BWRH = @wrh
          and INVMRPT.ASTORE = @store
          update INVMRPT set
            FQ = FQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S)
          from inserted
          where INVMRPT.ASETTLENO >= @settleno
          and INVMRPT.ASETTLENO < @cur_settleno
        and INVMRPT.BGDGID = @gdgid
          and INVMRPT.BWRH = @wrh
          and INVMRPT.ASTORE = @store
        end
        -- 出货年报
        if not exists ( select * from OUTYRPT
        where ASETTLENO = @yno and BGDGID = @gdgid
        and BCSTGID = @clngid and BWRH = @wrh and ASTORE = @store) begin
          insert into OUTYRPT (ASETTLENO, BGDGID, BCSTGID, BWRH, ASTORE)
          values (@yno, @gdgid, @clngid, @wrh, @store)
  end
        update OUTYRPT set
          DQ1 = DQ1 + LS_Q + LS_Q_B + LS_Q_S,
          DQ2 = DQ2 + WC_Q + WC_Q_B + WC_Q_S,
          DQ5 = DQ5 + LST_Q + LST_Q_B + LST_Q_S,
          DQ6 = DQ6 + WCT_Q + WCT_Q_B + WCT_Q_S,
          DT1 = DT1 + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S,
          DT2 = DT2 + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S,
          DT5 = DT5 + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S,
          DT6 = DT6 + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S,
          DT91 = DT91 + LS1_A + LS1_T,
          DT92 = DT92 + LS2_A + LS2_T + LS3_A + LS3_T,
          DI1 = convert( dec(20,2),  DI1 + LS_I + LS_I_B + LS_I_S ),
          DI2 = convert( dec(20,2),  DI2 + WC_I + WC_I_B + WC_I_S ),
          DI5 = convert( dec(20,2),  DI5 + LST_I + LST_I_B + LST_I_S ),
          DI6 = convert( dec(20,2),  DI6 + WCT_I + WCT_I_B + WCT_I_S ),
          DR1 = convert( dec(20,2),  DR1 + LS_R + LS_R_B + LS_R_S ),
          DR2 = convert( dec(20,2),  DR2 + WC_R + WC_R_B + WC_R_S ),
          DR5 = convert( dec(20,2),  DR5 + LST_R + LST_R_B + LST_R_S ),
          DR6 = convert( dec(20,2),  DR6 + WCT_R + WCT_R_B + WCT_R_S )
        from inserted
        where OUTYRPT.ASETTLENO = @yno
        and OUTYRPT.BGDGID = @gdgid and OUTYRPT.BCSTGID = @clngid
        and OUTYRPT.BWRH = @wrh
        and OUTYRPT.ASTORE = @store
        if @cur_yno <> @yno
        begin
          /*update OUTYRPT set
            CQ1 = CQ1 + LS_Q + LS_Q_B + LS_Q_S,
            CQ2 = CQ2 + WC_Q + WC_Q_B + WC_Q_S,
            CQ5 = CQ5 + LST_Q + LST_Q_B + LST_Q_S,
            CQ6 = CQ6 + WCT_Q + WCT_Q_B + WCT_Q_S,
            CT1 = CT1 + LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S,
            CT2 = CT2 + WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S,
            CT5 = CT5 + LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S,
            CT6 = CT6 + WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S,
            CT91 = CT91 + LS1_A + LS1_T,
            CT92 = CT92 + LS2_A + LS2_T + LS3_A + LS3_T,
            CI1 = convert( dec(20,2),  CI1 + LS_I + LS_I_B + LS_I_S ),
            CI2 = convert( dec(20,2),  CI2 + WC_I + WC_I_B + WC_I_S ),
            CI5 = convert( dec(20,2),  CI5 + LST_I + LST_I_B + LST_I_S ),
            CI6 = convert( dec(20,2),  CI6 + WCT_I + WCT_I_B + WCT_I_S ),
            CR1 = convert( dec(20,2),  CR1 + LS_R + LS_R_B + LS_R_S ),
            CR2 = convert( dec(20,2),  CR2 + WC_R + WC_R_B + WC_R_S ),
            CR5 = convert( dec(20,2),  CR5 + LST_R + LST_R_B + LST_R_S ),
            CR6 = convert( dec(20,2),  CR6 + WCT_R + WCT_R_B + WCT_R_S )
          from inserted
          where OUTYRPT.ASETTLENO > @yno
          and OUTYRPT.ASETTLENO <= @cur_yno
          and OUTYRPT.BGDGID = @gdgid and OUTYRPT.BCSTGID = @clngid
          and OUTYRPT.BWRH = @wrh
          and OUTYRPT.ASTORE = @store*/
          update INVYRPT set
            CQ = CQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S)
          from inserted
          where INVYRPT.ASETTLENO > @yno
          and INVYRPT.ASETTLENO <= @cur_yno
          and INVYRPT.BGDGID = @gdgid
          and INVYRPT.BWRH = @wrh
          and INVYRPT.ASTORE = @store
          update INVYRPT set
            FQ = FQ - (LS_Q + LS_Q_B + LS_Q_S) - (WC_Q + WC_Q_B + WC_Q_S)
                    + (LST_Q + LST_Q_B + LST_Q_S) + (WCT_Q + WCT_Q_B + WCT_Q_S)
          from inserted
          where INVYRPT.ASETTLENO >= @yno
          and INVYRPT.ASETTLENO < @cur_yno
          and INVYRPT.BGDGID = @gdgid
          and INVYRPT.BWRH = @wrh
          and INVYRPT.ASTORE = @store
        end
      end
 end --if mode in(0,1)

 if @mode in (0,2) begin /*Add by jinlei 3962*/
  -- 供应商帐款日报,月报,年报
  if (select
        (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
        + (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S)
        --+ ((LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)      del by jzhu 20140327 BUG会导致不记账款日报
        --+ (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S))
        + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
        + (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
        + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
        + (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S)
  from inserted) <> 0 begin
    declare @sale smallint, @dxprc money, @payrate money
    declare @dq2 money, @dt2 money, @dt3 money, @dq3 money
    select @sale = SALE, @dxprc = DXPRC, @payrate = PAYRATE
      from GOODSH where GID = @gdgid --2002-07-25
    select
        @DQ2 = (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
              - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        @DT2 = convert( dec(20,2),
               (LS_A + LS_A_B + LS_A_S + WC_A + WC_A_B + WC_A_S)
              + (LS_T + LS_T_B + LS_T_S + WC_T + WC_T_B + WC_T_S)
              - (LST_A + LST_A_B + LST_A_S + WCT_A + WCT_A_B + WCT_A_S)
              - (LST_T + LST_T_B + LST_T_S + WCT_T + WCT_T_B + WCT_T_S) ),
        @Di2 = convert( dec(20,2),
               ((LS_I + LS_I_B + LS_I_S + WC_I + WC_I_B + WC_I_S)
              - (LST_I + LST_I_B + LST_I_S + WCT_I + WCT_I_B + WCT_I_S)) )
    from inserted
    --2002-07-25
    if @sale = 2
      select @dq3 = @dq2, @dt3 = @di2 --原先的写法 @dt3 = @dq2 * @dxprc，有可能因为精度问题不平
    else if @sale = 3
      select @dq3 = @dq2, @dt3 = @di2 --原先的写法 @dt3 = @dt2 * @payrate / 100，有可能因为精度问题不平
    else
      select @dq3 = 0, @dt3 = 0
    execute AppUpdVdrDrpt @store, @settleno, @date, @vdrgid, @wrh, @gdgid,
      0, @dq2, @dq3, 0, 0, 0,
      0, @dt2, @dt3, 0, 0, 0, 0,
      @di2

    exec OPTREADINT 0, 'SVICTRL', -1, @optvalue output  /*2002-09-26*/
    if ((@optvalue <> -1) and exists(select * from goodsh (nolock) where gid = @gdgid and sale = 2))
  or exists(select * from goodsh(nolock) where gid = @gdgid and sale = 3)
 begin
        if not exists (select * from osbal (nolock)
              where store = @store and settleno =@settleno and date = @date
                 and wrh = @wrh and gdgid = @gdgid and vdrgid = @vdrgid)
        begin
            insert into osbal (store,settleno,date,vdrgid,wrh,gdgid)
             values(@store,@settleno,@date,@vdrgid,@wrh,@gdgid)
        end
  update osbal
        set qty = qty + isnull(@dq2,0),
     dt1 = dt1 + isnull(@dt2,0),
     dt2 = dt2 + isnull(@dt3,0) --应结额
       where  store = @store and settleno = @settleno and date = @date
     and wrh = @wrh and gdgid = @gdgid and vdrgid = @vdrgid
 end
  end

-- 客户帐款日报,月报,年报
  /* 99-11-29 */
  /* if ( select BCSTGID from inserted ) <> 1 */
  if @param in (1,11)
  begin
    select @clngid = @oriclngid
    if ( select
        (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
        + (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S)
        + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
        + (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
        + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
        + (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S)
    from inserted ) <> 0 begin
      -- 客户帐款日报
      if not exists (select * from CSTDRPTI
      where ASETTLENO = @settleno and BCSTGID = @clngid and ADATE = @date
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into CSTDRPTI (ASETTLENO, ADATE, BCSTGID, BWRH, BGDGID, ASTORE)
        values (@settleno, @date, @clngid, @wrh, @gdgid, @store)
      end
      if not exists (select * from CSTDRPT
      where ASETTLENO = @settleno and BCSTGID = @clngid and ADATE = @date
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into CSTDRPT (ASETTLENO, ADATE, BCSTGID, BWRH, BGDGID, ASTORE)
        values (@settleno, @date, @clngid, @wrh, @gdgid, @store)
      end
      update CSTDRPT set
        DQ2 = DQ2 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
                  - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT2 = convert( dec(20,2),
              DT2 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) ),
        DQ3 = DQ3 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
                  - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT3 = convert( dec(20,2),
              DT3 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) )
      from inserted
      where CSTDRPT.ASETTLENO = @settleno
     and CSTDRPT.ADATE = @date
      and CSTDRPT.BCSTGID = @clngid
      and CSTDRPT.BWRH = @wrh
      and CSTDRPT.BGDGID = @gdgid
      and CSTDRPT.ASTORE = @store
      -- 客户帐款月报
      if not exists (select * from CSTMRPT
      where ASETTLENO = @settleno and BCSTGID = @clngid
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into CSTMRPT (ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE)
        values (@settleno, @clngid, @wrh, @gdgid, @store)
      end
      update CSTMRPT set
        DQ2 = DQ2 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
                  - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT2 = convert( dec(20,2),
              DT2 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) ),
        DQ3 = DQ3 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
                  - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT3 = convert( dec(20,2),
              DT3 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) )
      from inserted
      where CSTMRPT.ASETTLENO = @settleno
      and CSTMRPT.BCSTGID = @clngid
      and CSTMRPT.BWRH = @wrh
      and CSTMRPT.BGDGID = @gdgid
      and CSTMRPT.ASTORE = @store
      -- 客户帐款年报
      if not exists (select * from CSTYRPT
      where ASETTLENO = @yno and BCSTGID = @clngid
      and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
        insert into CSTYRPT (ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE)
        values (@yno, @clngid, @wrh, @gdgid, @store)
      end
      update CSTYRPT set
        DQ2 = DQ2 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
            - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT2 = convert( dec(20,2),
              DT2 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) ),
        DQ3 = DQ3 + (LS_Q + LS_Q_B + LS_Q_S + WC_Q + WC_Q_B + WC_Q_S)
                  - (LST_Q + LST_Q_B + LST_Q_S + WCT_Q + WCT_Q_B + WCT_Q_S),
        DT3 = convert( dec(20,2),
              DT3 + (LS_A + LS_A_B + LS_A_S + LS_T + LS_T_B + LS_T_S)
                  - (LST_A + LST_A_B + LST_A_S + LST_T + LST_T_B + LST_T_S)
                  + (WC_A + WC_A_B + WC_A_S + WC_T + WC_T_B + WC_T_S)
                  - (WCT_A + WCT_A_B + WCT_A_S + WCT_T + WCT_T_B + WCT_T_S) )
      from inserted
      where CSTYRPT.ASETTLENO = @yno
      and CSTYRPT.BCSTGID = @clngid
      and CSTYRPT.BWRH = @wrh
      and CSTYRPT.BGDGID = @gdgid
      and CSTYRPT.ASTORE = @store
    end
  end
 end
end
GO
