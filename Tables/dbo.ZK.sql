CREATE TABLE [dbo].[ZK]
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
[FK_Q] [money] NULL CONSTRAINT [DF__ZK__FK_Q__459509CE] DEFAULT (0),
[FK_A] [money] NULL CONSTRAINT [DF__ZK__FK_A__46892E07] DEFAULT (0),
[FK_T] [money] NULL CONSTRAINT [DF__ZK__FK_T__477D5240] DEFAULT (0),
[FK_I] [money] NULL CONSTRAINT [DF__ZK__FK_I__48717679] DEFAULT (0),
[FK_R] [money] NULL CONSTRAINT [DF__ZK__FK_R__49659AB2] DEFAULT (0),
[FK_Q_B] [money] NULL CONSTRAINT [DF__ZK__FK_Q_B__4A59BEEB] DEFAULT (0),
[FK_A_B] [money] NULL CONSTRAINT [DF__ZK__FK_A_B__4B4DE324] DEFAULT (0),
[FK_T_B] [money] NULL CONSTRAINT [DF__ZK__FK_T_B__4C42075D] DEFAULT (0),
[FK_I_B] [money] NULL CONSTRAINT [DF__ZK__FK_I_B__4D362B96] DEFAULT (0),
[FK_R_B] [money] NULL CONSTRAINT [DF__ZK__FK_R_B__4E2A4FCF] DEFAULT (0),
[FK_Q_S] [money] NULL CONSTRAINT [DF__ZK__FK_Q_S__4F1E7408] DEFAULT (0),
[FK_A_S] [money] NULL CONSTRAINT [DF__ZK__FK_A_S__50129841] DEFAULT (0),
[FK_T_S] [money] NULL CONSTRAINT [DF__ZK__FK_T_S__5106BC7A] DEFAULT (0),
[FK_I_S] [money] NULL CONSTRAINT [DF__ZK__FK_I_S__51FAE0B3] DEFAULT (0),
[FK_R_S] [money] NULL CONSTRAINT [DF__ZK__FK_R_S__52EF04EC] DEFAULT (0),
[FX_Q] [money] NULL CONSTRAINT [DF__ZK__FX_Q__53E32925] DEFAULT (0),
[FX_A] [money] NULL CONSTRAINT [DF__ZK__FX_A__54D74D5E] DEFAULT (0),
[FX_T] [money] NULL CONSTRAINT [DF__ZK__FX_T__55CB7197] DEFAULT (0),
[FX_I] [money] NULL CONSTRAINT [DF__ZK__FX_I__56BF95D0] DEFAULT (0),
[FX_R] [money] NULL CONSTRAINT [DF__ZK__FX_R__57B3BA09] DEFAULT (0),
[FX_Q_B] [money] NULL CONSTRAINT [DF__ZK__FX_Q_B__58A7DE42] DEFAULT (0),
[FX_A_B] [money] NULL CONSTRAINT [DF__ZK__FX_A_B__599C027B] DEFAULT (0),
[FX_T_B] [money] NULL CONSTRAINT [DF__ZK__FX_T_B__5A9026B4] DEFAULT (0),
[FX_I_B] [money] NULL CONSTRAINT [DF__ZK__FX_I_B__5B844AED] DEFAULT (0),
[FX_R_B] [money] NULL CONSTRAINT [DF__ZK__FX_R_B__5C786F26] DEFAULT (0),
[FX_Q_S] [money] NULL CONSTRAINT [DF__ZK__FX_Q_S__5D6C935F] DEFAULT (0),
[FX_A_S] [money] NULL CONSTRAINT [DF__ZK__FX_A_S__5E60B798] DEFAULT (0),
[FX_T_S] [money] NULL CONSTRAINT [DF__ZK__FX_T_S__5F54DBD1] DEFAULT (0),
[FX_I_S] [money] NULL CONSTRAINT [DF__ZK__FX_I_S__6049000A] DEFAULT (0),
[FX_R_S] [money] NULL CONSTRAINT [DF__ZK__FX_R_S__613D2443] DEFAULT (0),
[YFKT_Q] [money] NULL CONSTRAINT [DF__ZK__YFKT_Q__6231487C] DEFAULT (0),
[YFKT_A] [money] NULL CONSTRAINT [DF__ZK__YFKT_A__63256CB5] DEFAULT (0),
[YFKT_T] [money] NULL CONSTRAINT [DF__ZK__YFKT_T__641990EE] DEFAULT (0),
[YFKT_I] [money] NULL CONSTRAINT [DF__ZK__YFKT_I__650DB527] DEFAULT (0),
[YFKT_R] [money] NULL CONSTRAINT [DF__ZK__YFKT_R__6601D960] DEFAULT (0),
[YFXT_Q] [money] NULL CONSTRAINT [DF__ZK__YFXT_Q__66F5FD99] DEFAULT (0),
[YFXT_A] [money] NULL CONSTRAINT [DF__ZK__YFXT_A__67EA21D2] DEFAULT (0),
[YFXT_T] [money] NULL CONSTRAINT [DF__ZK__YFXT_T__68DE460B] DEFAULT (0),
[YFXT_I] [money] NULL CONSTRAINT [DF__ZK__YFXT_I__69D26A44] DEFAULT (0),
[YFXT_R] [money] NULL CONSTRAINT [DF__ZK__YFXT_R__6AC68E7D] DEFAULT (0),
[GX_Q] [money] NULL CONSTRAINT [DF__ZK__GX_Q__6BBAB2B6] DEFAULT (0),
[GX_A] [money] NULL CONSTRAINT [DF__ZK__GX_A__6CAED6EF] DEFAULT (0),
[GX_T] [money] NULL CONSTRAINT [DF__ZK__GX_T__6DA2FB28] DEFAULT (0),
[GX_I] [money] NULL CONSTRAINT [DF__ZK__GX_I__6E971F61] DEFAULT (0),
[GX_R] [money] NULL CONSTRAINT [DF__ZK__GX_R__6F8B439A] DEFAULT (0),
[SK_Q] [money] NULL CONSTRAINT [DF__ZK__SK_Q__707F67D3] DEFAULT (0),
[SK_A] [money] NULL CONSTRAINT [DF__ZK__SK_A__71738C0C] DEFAULT (0),
[SK_T] [money] NULL CONSTRAINT [DF__ZK__SK_T__7267B045] DEFAULT (0),
[SK_I] [money] NULL CONSTRAINT [DF__ZK__SK_I__735BD47E] DEFAULT (0),
[SK_R] [money] NULL CONSTRAINT [DF__ZK__SK_R__744FF8B7] DEFAULT (0),
[SK_Q_B] [money] NULL CONSTRAINT [DF__ZK__SK_Q_B__75441CF0] DEFAULT (0),
[SK_A_B] [money] NULL CONSTRAINT [DF__ZK__SK_A_B__76384129] DEFAULT (0),
[SK_T_B] [money] NULL CONSTRAINT [DF__ZK__SK_T_B__772C6562] DEFAULT (0),
[SK_I_B] [money] NULL CONSTRAINT [DF__ZK__SK_I_B__7820899B] DEFAULT (0),
[SK_R_B] [money] NULL CONSTRAINT [DF__ZK__SK_R_B__7914ADD4] DEFAULT (0),
[SK_Q_S] [money] NULL CONSTRAINT [DF__ZK__SK_Q_S__7A08D20D] DEFAULT (0),
[SK_A_S] [money] NULL CONSTRAINT [DF__ZK__SK_A_S__7AFCF646] DEFAULT (0),
[SK_T_S] [money] NULL CONSTRAINT [DF__ZK__SK_T_S__7BF11A7F] DEFAULT (0),
[SK_I_S] [money] NULL CONSTRAINT [DF__ZK__SK_I_S__7CE53EB8] DEFAULT (0),
[SK_R_S] [money] NULL CONSTRAINT [DF__ZK__SK_R_S__7DD962F1] DEFAULT (0),
[YSKT_Q] [money] NULL CONSTRAINT [DF__ZK__YSKT_Q__7ECD872A] DEFAULT (0),
[YSKT_A] [money] NULL CONSTRAINT [DF__ZK__YSKT_A__7FC1AB63] DEFAULT (0),
[YSKT_T] [money] NULL CONSTRAINT [DF__ZK__YSKT_T__00B5CF9C] DEFAULT (0),
[YSKT_I] [money] NULL CONSTRAINT [DF__ZK__YSKT_I__01A9F3D5] DEFAULT (0),
[YSKT_R] [money] NULL CONSTRAINT [DF__ZK__YSKT_R__029E180E] DEFAULT (0)
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
/*
99-6-9: 1. 将select @cur_year = max(ASETTLENO) from OUTYRPT改成
             select @cur_year = YNO from V_YM where MNO = @cur_month
        2. 将if @settleno < @cur_year begin 改成
             if @yno < @cur_year begin
        3. select @dxprc = FDXPRC, @payrate = FPAYRATE from INVDRPT
           的条件中增加ASTORE = (select USERGID from SYSTEM)
2000-3-15:  L176,227: DQ3,DT3 -> @DQ3, @DT3
2002.08.05  add by cyb
  2002072249052:代销结算库存控制——服务端
2002-09-26  姚力
  2002092647996:代销结算单服务端要判断hdoption
2002.11.15 张雁波
  2002111538991：联销商品按门店结算
*/
create trigger [dbo].[EZK_INS] on [dbo].[ZK] instead of insert as
begin
  -- 供应商帐款日报,月报,年报
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

    @DQ3 money,
    @DT3 money,
    @DQ4 money,
    @DT4 money,
    @DQ5 money,
    @DT5 money,
    @DQ6 money,
    @DT6 money,
    @DT7 money,
    @yno int,
    @sale smallint, @dxprc money, @payrate money,
    @cur_date datetime, @cur_month int, @cur_year int,
    @optvalue int/*2002-09-26*/

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
  select @yno = YNO from V_YM where MNO = @settleno

  select @cur_date = convert(datetime, convert(char, getdate(), 102))
  select @cur_month = max(NO) from MONTHSETTLE
  select @cur_year = YNO from V_YM where MNO = @cur_month

  -- 供应商帐款日报,月报,年报
  if (select
        FK_Q + FK_Q_B + FK_Q_S
        + GX_Q
        + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S
        + FX_A + FX_A_B + FX_A_S + FX_T + FX_T_B + FX_T_S
        + GX_A + GX_T
        + YFKT_Q + YFKT_A + YFKT_T + YFXT_A
  from inserted) <> 0 begin
    select @sale = SALE from GOODSH where GID = @gdgid

    if @date = @cur_date begin
      select @dxprc = DXPRC, @payrate = PAYRATE from GOODSH
      where GID = @gdgid
    end else begin
      select @dxprc = FDXPRC, @payrate = FPAYRATE from INVDRPT
      where ASETTLENO = @settleno and ADATE = @date
      and ASTORE = (select USERGID from SYSTEM)
    end

    exec OPTREADINT 0, 'SVICTRL', -1, @optvalue output  /*2002-09-26*/

    -- 增加日报记录
    if not exists ( select * from VDRDRPTI
    where ASETTLENO = @settleno and BVDRGID = @vdrgid and ADATE = @date
    and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
      insert into VDRDRPTI (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE, ADATE)
      values (@settleno, @vdrgid, @wrh, @gdgid, @store, @date)
    end

    if not exists ( select * from VDRDRPT
    where ASETTLENO = @settleno and BVDRGID = @vdrgid and ADATE = @date
    and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store)
    begin
      insert into VDRDRPT (ASETTLENO, BVDRGID, BWRH, BGDGID, ASTORE, ADATE)
      values (@settleno, @vdrgid, @wrh, @gdgid, @store, @date)

      if ((@optvalue <> -1) and exists (select * from goodsh (nolock) where gid = @gdgid and sale = 2))
        or exists(select 1 from goodsh(nolock) where gid = @gdgid and sale = 3)
    begin
          if not exists (select * from osbal
                where settleno = @settleno and vdrgid = @vdrgid and date = @date
                     and wrh = @wrh and gdgid = @gdgid and store = @store)
          begin
              insert into osbal (settleno ,vdrgid,wrh,gdgid,store,date)
             values (@settleno,@vdrgid,@wrh,@gdgid,@store,@date)
        end
      end
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
    -- 记录变化值,为改变以后的期初值做准备
    select
      @DQ4 = FK_Q + FK_Q_B + FK_Q_S,
      @DT4 = convert( dec(20,2), FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
      @DQ5 = GX_Q,
      @DT5 = convert( dec(20,2), GX_A + GX_T ),
      @DQ6 = YFKT_Q,
      @DT6 = convert( dec(20,2), YFKT_A + YFKT_T ),
      @DT7 = convert( dec(20,2), FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
    from inserted
    if @sale = 1 begin
      --经销
      select
        @DQ3 = 0,
        @DT3 = 0
      -- 供应商帐款日报
      update VDRDRPT set
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A ),
        LSTUPDTIME = getdate()
      from inserted
      where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
      and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
      and VDRDRPT.ASTORE = @store and VDRDRPT.ADATE = @date
      -- 供应商帐款月报
      update VDRMRPT set
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
      and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
      and VDRMRPT.ASTORE = @store
      -- 供应商帐款年报
      update VDRYRPT set
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
      and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
      and VDRYRPT.ASTORE = @store
    end else if @sale = 2 begin
      -- 代销
      select
        /*2000-3-15 DQ3*/@DQ3 = GX_Q,
        /*2000-3-15 DT3*/@DT3 = GX_Q * @dxprc
      from inserted
      -- 供应商帐款日报
      update VDRDRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + GX_Q * @dxprc ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A ),
        LSTUPDTIME = getdate()
      from inserted
      where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
      and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
      and VDRDRPT.ASTORE = @store and VDRDRPT.ADATE = @date

      if @optvalue <> -1 /*2002-09-26*/
      --代销结算 add by cyb 2002-08-05
      update OSBAL set
   DT2 = convert( dec(20,2), DT2 + YFKT_A + YFKT_T) --更改应结额
      FROM INSERTED
      WHERE OSBAL.SETTLENO = @SETTLENO AND OSBAL.VDRGID = @VDRGID
  AND OSBAL.WRH = @WRH AND OSBAL.GDGID = @GDGID
  AND OSBAL.STORE = @STORE AND OSBAL.DATE = @DATE

      -- 供应商帐款月报
      update VDRMRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + GX_Q * @dxprc ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
      and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
      and VDRMRPT.ASTORE = @store
      -- 供应商帐款年报
      update VDRYRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + GX_Q * @dxprc ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
      and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
      and VDRYRPT.ASTORE = @store
    end else if @sale = 3 begin
      -- 联销
      select
        /*2000-3-15 DQ3*/@DQ3 = GX_Q,
        /*2000-3-15 DT3*/@DT3 = (GX_A + GX_T) * @payrate / 100
      from inserted
      -- 供应商帐款日报
      update VDRDRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + (GX_A + GX_T) * @payrate / 100 ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A ),
        LSTUPDTIME = getdate()
      from inserted
      where VDRDRPT.ASETTLENO = @settleno and VDRDRPT.BVDRGID = @vdrgid
      and VDRDRPT.BWRH = @wrh and VDRDRPT.BGDGID = @gdgid
      and VDRDRPT.ASTORE = @store and VDRDRPT.ADATE = @date

      if @optvalue <> -1
        update OSBAL set
    DT2 = convert(dec(20,2), DT2 + YFKT_A + YFKT_T ) --更改应结额
        FROM INSERTED
        WHERE OSBAL.SETTLENO = @SETTLENO AND OSBAL.VDRGID = @VDRGID
    AND OSBAL.WRH = @WRH AND OSBAL.GDGID = @GDGID
    AND OSBAL.STORE = @STORE AND OSBAL.DATE = @DATE

      -- 供应商帐款月报
      update VDRMRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + (GX_A + GX_T) * @payrate / 100 ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRMRPT.ASETTLENO = @settleno and VDRMRPT.BVDRGID = @vdrgid
      and VDRMRPT.BWRH = @wrh and VDRMRPT.BGDGID = @gdgid
      and VDRMRPT.ASTORE = @store
      -- 供应商帐款年报
      update VDRYRPT set
        DQ3 = DQ3 + GX_Q,
        DT3 = convert( dec(20,2), DT3 + (GX_A + GX_T) * @payrate / 100 ),
        DQ4 = DQ4 + FK_Q + FK_Q_B + FK_Q_S,
        DT4 = convert( dec(20,2), DT4 + FK_A + FK_A_B + FK_A_S + FK_T + FK_T_B + FK_T_S ),
        DQ5 = DQ5 + GX_Q,
        DT5 = convert( dec(20,2), DT5 + GX_A + GX_T ),
        DQ6 = DQ6 + YFKT_Q,
        DT6 = convert( dec(20,2), DT6 + YFKT_A + YFKT_T ),
        DT7 = convert( dec(20,2), DT7 + FX_A + FX_A_S + FX_A_B + FX_T + FX_T_S + FX_T_B + YFXT_A )
      from inserted
      where VDRYRPT.ASETTLENO = @yno and VDRYRPT.BVDRGID = @vdrgid
      and VDRYRPT.BWRH = @wrh and VDRYRPT.BGDGID = @gdgid
      and VDRYRPT.ASTORE = @store
    end
    -- 销售分配调整可以不是本日的,依次改变以后每天/月/年的期初值
    if (select GX_Q + GX_A from inserted) <> 0 begin
      if @date < @cur_date begin
        update VDRDRPTI set
          CQ3 = CQ3 + @DQ3,
          CQ4 = CQ4 + @DQ4,
          CQ5 = CQ5 + @DQ5,
          CQ6 = CQ6 + @DQ6,
          CT3 = convert( dec(20,2),  CT3 + @DT3 ),
          CT4 = convert( dec(20,2),  CT4 + @DT4 ),
          CT5 = convert( dec(20,2),  CT5 + @DT5 ),
          CT6 = convert( dec(20,2),  CT6 + @DT6 ),
          CT7 = convert( dec(20,2),  CT7 + @DT7 )
        where VDRDRPTI.ASETTLENO = @settleno
        and VDRDRPTI.ADATE > @date
        and VDRDRPTI.ASTORE = @store
        and VDRDRPTI.BVDRGID = @vdrgid
        and VDRDRPTI.BWRH = @wrh
        and VDRDRPTI.BGDGID = @gdgid
      end
      if @settleno < @cur_month begin
        update VDRMRPT set
          CQ3 = CQ3 + @DQ3,
          CQ4 = CQ4 + @DQ4,
          CQ5 = CQ5 + @DQ5,
          CQ6 = CQ6 + @DQ6,
          CT3 = convert( dec(20,2),  CT3 + @DT3 ),
          CT4 = convert( dec(20,2),  CT4 + @DT4 ),
          CT5 = convert( dec(20,2),  CT5 + @DT5 ),
          CT6 = convert( dec(20,2),  CT6 + @DT6 ),
          CT7 = convert( dec(20,2),  CT7 + @DT7 )
        where VDRMRPT.ASETTLENO > @settleno
        and VDRMRPT.ASTORE = @store
        and VDRMRPT.BVDRGID = @vdrgid
        and VDRMRPT.BWRH = @wrh
        and VDRMRPT.BGDGID = @gdgid
      end
      if @yno < @cur_year begin
        update VDRYRPT set
          CQ3 = CQ3 + @DQ3,
          CQ4 = CQ4 + @DQ4,
          CQ5 = CQ5 + @DQ5,
          CQ6 = CQ6 + @DQ6,
          CT3 = convert( dec(20,2),  CT3 + @DT3 ),
          CT4 = convert( dec(20,2),  CT4 + @DT4 ),
          CT5 = convert( dec(20,2),  CT5 + @DT5 ),
          CT6 = convert( dec(20,2),  CT6 + @DT6 ),
          CT7 = convert( dec(20,2),  CT7 + @DT7 )
        where VDRYRPT.ASETTLENO > @yno
        and VDRYRPT.ASTORE = @store
        and VDRYRPT.BVDRGID = @vdrgid
        and VDRYRPT.BWRH = @wrh
        and VDRYRPT.BGDGID = @gdgid
      end
    end
  end

  -- 客户帐款月报,年报
  if ( select
      SK_Q + SK_Q_B + SK_Q_S + YSKT_Q
      + SK_A + SK_A_B + SK_A_S + SK_T + SK_T_B + SK_T_S
            + YSKT_A + YSKT_T
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
      DQ1 = DQ1 + SK_Q + SK_Q_B + SK_Q_S,
      DQ3 = DQ3 + YSKT_Q,
      DT1 = convert( dec(20,2), DT1 + SK_A + SK_A_B + SK_A_S + SK_T + SK_T_B + SK_T_S ),
      DT3 = convert( dec(20,2), DT3 + YSKT_A + YSKT_T )
    from inserted
    where CSTDRPT.ASETTLENO = @settleno
    and CSTDRPT.ADATE = @date
    and CSTDRPT.BCSTGID = @clngid
    and CSTDRPT.BWRH = @wrh
    and CSTDRPT.BGDGID = @gdgid
    and CSTDRPT.ASTORE = @store
    -- 客户帐款月报
    if not exists ( select * from CSTMRPT
    where ASETTLENO = @settleno and BCSTGID = @clngid
    and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
      insert into CSTMRPT (ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE)
      values (@settleno, @clngid, @wrh, @gdgid, @store)
    end
    update CSTMRPT set
      DQ1 = DQ1 + SK_Q + SK_Q_B + SK_Q_S,
      DQ3 = DQ3 + YSKT_Q,
      DT1 = convert( dec(20,2),  DT1 + SK_A + SK_A_B + SK_A_S + SK_T + SK_T_B + SK_T_S ),
      DT3 = convert( dec(20,2),  DT3 + YSKT_A + YSKT_T )
    from inserted
    where CSTMRPT.ASETTLENO = @settleno and CSTMRPT.BCSTGID = @clngid
    and CSTMRPT.BWRH = @wrh and CSTMRPT.BGDGID = @gdgid
    and CSTMRPT.ASTORE = @store
    -- 客户帐款年报
    if not exists ( select * from CSTYRPT
    where ASETTLENO = @yno and BCSTGID = @clngid
    and BWRH = @wrh and BGDGID = @gdgid and ASTORE = @store) begin
      insert into CSTYRPT (ASETTLENO, BCSTGID, BWRH, BGDGID, ASTORE)
      values (@yno, @clngid, @wrh, @gdgid, @store)
    end
    update CSTYRPT set
      DQ1 = DQ1 + SK_Q + SK_Q_B + SK_Q_S,
      DQ3 = DQ3 + YSKT_Q,
      DT1 = convert( dec(20,2),  DT1 + SK_A + SK_A_B + SK_A_S + SK_T + SK_T_B + SK_T_S ),
      DT3 = convert( dec(20,2),  DT3 + YSKT_A + YSKT_T )
    from inserted
    where CSTYRPT.ASETTLENO = @yno and CSTYRPT.BCSTGID = @clngid
    and CSTYRPT.BWRH = @wrh and CSTYRPT.BGDGID = @gdgid
    and CSTYRPT.ASTORE = @store
  end
  --DELETE FROM ZK
end
GO
