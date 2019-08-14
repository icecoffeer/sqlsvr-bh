CREATE TABLE [dbo].[FV]
(
[ID] [int] NOT NULL IDENTITY(1, 1),
[BWRH] [int] NULL,
[BGDGID] [int] NULL,
[BVDRGID] [int] NULL,
[ASTORE] [int] NULL,
[ADATE] [datetime] NULL,
[ASETTLENO] [int] NULL,
[FV_P] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__FV__FV_P__604CF8BD] DEFAULT (0),
[FV_L] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__FV__FV_L__61411CF6] DEFAULT (0),
[FV_A] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__FV__FV_A__6235412F] DEFAULT (0),
[PROMCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PROMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PROMLINE] [int] NULL,
[MODE] [smallint] NOT NULL CONSTRAINT [DF__FV__MODE__63296568] DEFAULT (0),
[BCSTGID] [int] NULL
) ON [PRIMARY]
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE TRIGGER [dbo].[EFV_INS] ON [dbo].[FV] INSTEAD OF INSERT
as
begin
  -- 优惠日报, 供应商帐款报表, OSBAL
  declare
    @return_status int,
    @BWRH int,
    @BGDGID int,
    @BVDRGID int,
    @ASTORE int,
    @ADATE datetime,
    @ASETTLENO int,
    @FV_P varchar(4),
    @FV_L money,
    @FV_A money,
    @PROMCLS char(10),
    @PROMNUM char(14),
    @PROMLINE int,
    @MODE int,
    @SALE int,
    @PAYRATE money,
    @FAVPAY money,
    @option_FAVADDVDR int,
    @BCSTGID INT

  -- 保证只插入一条记录
  if @@rowcount <> 1 begin
    raiserror('EFV_INS', 16, 1)
    return
  end
  -- 取关键字
  select
    @BWRH = BWRH,
    @BGDGID = BGDGID,
    @BVDRGID = BVDRGID,
    @ASTORE = ASTORE,
    @ADATE = ADATE,
    @ASETTLENO = ASETTLENO,
    @FV_P = FV_P,
    @FV_L = FV_L,
    @FV_A = FV_A,
    @PROMCLS = PROMCLS,
    @PROMNUM = PROMNUM,
    @PROMLINE = PROMLINE,
    @MODE = MODE,
    @BCSTGID = BCSTGID
    from inserted


  select @SALE = SALE, @PAYRATE = PAYRATE from GOODSH(nolock) where GID = @BGDGID
  exec OptReadInt 0, 'FAVADDVDR', 1, @option_FAVADDVDR output

  -- 优惠日报
   --振华定制.FAVDRPT增加FAVTYPE主键 ADD BY WUDIPING 20100927
  if not exists ( select * from FAVDRPT(nolock)
    where ASETTLENO = @ASETTLENO and BGDGID = @BGDGID AND ASTORE = @ASTORE
      and ADATE = @ADATE and BWRH = @BWRH AND BVDRGID = @BVDRGID AND BCSTGID = @BCSTGID AND FAVTYPE = @FV_P)
  begin
    insert into FAVDRPT(ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID, FAVTYPE, FAVRATE,
      FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID)
    values (@ASTORE, @ASETTLENO, @ADATE, @BVDRGID, @BWRH, @BGDGID, @FV_P, @FV_L,
      0, 0, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID)
  end

  update FAVDRPT set
    --FAVTYPE = @FV_P,
    FAVRATE = @FV_L,
    FAVAMOUNT = FAVAMOUNT + CONVERT(DEC(20, 2), @FV_A),
    PROMCLS = @PROMCLS,
    PROMNUM = @PROMNUM,
    PROMLINE = @PROMLINE,
    LSTUPDTIME = getdate()
  where FAVDRPT.ASETTLENO = @ASETTLENO and FAVDRPT.BGDGID = @BGDGID
    AND FAVDRPT.ASTORE = @ASTORE and FAVDRPT.ADATE = @ADATE
    and FAVDRPT.BWRH = @BWRH AND FAVDRPT.BVDRGID = @BVDRGID
    AND FAVDRPT.BCSTGID = @BCSTGID
    and FAVDRPT.FAVTYPE = @FV_P

  if @SALE = 3
  begin
    set @FAVPAY = @FV_A * @PAYRATE * @FV_L / 100
    update FAVDRPT set
      FAVPAY = FAVPAY + CONVERT(DEC(20, 2), @FAVPAY),
      LSTUPDTIME = getdate()
    where FAVDRPT.ASETTLENO = @ASETTLENO and FAVDRPT.BGDGID = @BGDGID
      AND FAVDRPT.ASTORE = @ASTORE and FAVDRPT.ADATE = @ADATE
      and FAVDRPT.BWRH = @BWRH AND FAVDRPT.BVDRGID = @BVDRGID
      AND FAVDRPT.BCSTGID = @BCSTGID
      and FAVDRPT.FAVTYPE = @FV_P
  end

  if (@MODE & 1 = 1) and (@SALE = 3) and (@option_FAVADDVDR = 1)
  begin
    execute AppUpdVdrDrpt @ASTORE, @ASETTLENO, @ADATE, @BVDRGID, @BWRH, @BGDGID,
      0, 0, 0, 0, 0, 0, 0, 0, @FAVPAY, 0, 0, 0, 0, 0
    if not exists (select * from osbal (nolock)
      where store = @ASTORE and settleno = @ASETTLENO and date = @ADATE
        and wrh = @BWRH and gdgid = @BGDGID and vdrgid = @BVDRGID)
      insert into osbal(store, settleno, date, vdrgid, wrh, gdgid)
          values(@ASTORE, @ASETTLENO, @ADATE, @BVDRGID, @BWRH, @BGDGID)
      update osbal set dt2 = dt2 + isnull(@FAVPAY, 0) --应结额
      where store = @ASTORE and settleno = @ASETTLENO and date = @ADATE
        and wrh = @BWRH and gdgid = @BGDGID and vdrgid = @BVDRGID
  end
end
GO
