SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[RcvFavDrpt] as
begin
  declare
    @id int,           @astore int,       @asettleno int,     @adate datetime,
    @bvdrgid int,      @bgdgid int,       @bwrh int,          @FAVTYPE varchar(4),
    @FAVRATE money,    @FAVAMOUNT money,  @FAVPAY money,      @PROMCLS CHAR(10),
    @PROMNUM CHAR(14), @PROMLINE int,     @MSD int,           @option_ISZBPAY int,
    @SALE int,         @PAYRATE money,    @billto int,        @ZBGID int,
    @option_FAVADDVDR int, @BCSTGID int

  exec OptReadInt 0, 'ISZBPAY', 0, @option_ISZBPAY output
  exec OptReadInt 0, 'FAVADDVDR', 1, @option_FAVADDVDR output
  select @ZBGID = ZBGID from system(nolock)

  /* 处理网络报表 */
  declare c_favdrpt cursor for
    select ID, ASTORE, ASETTLENO, ADATE, BVDRGID, BGDGID, BWRH,
    FAVTYPE, FAVRATE, FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID
    from NFAVDRPT(NOLOCK) where type = 1
  open c_favdrpt
  fetch next from c_favdrpt into
    @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
    @FAVTYPE, @FAVRATE, @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID
  while @@fetch_status = 0
  begin
    /* 检查本地是否有商品 */
    select @bgdgid = (select LGID from GDXLATE(NOLOCK) where NGID = @bgdgid)
    if @bgdgid is null
    begin
      update NFAVDRPT set NSTAT = 1, NNOTE = '商品不存在'
      where NFAVDRPT.ID = @id
      fetch next from c_favdrpt into
         @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
         @FAVTYPE, @FAVRATE, @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID
      continue
    end
    /* 检查本地是否有供应商 */
    select @bvdrgid = (select LGID from VDRXLATE(NOLOCK) where NGID = @bvdrgid)
    if @bvdrgid is null
    begin
      update NFAVDRPT set NSTAT = 1, NNOTE = '供应商不存在'
         where NFAVDRPT.ID = @id
      fetch next from c_favdrpt into
         @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
         @FAVTYPE, @FAVRATE, @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID
      continue
    end
    /* 取商品信息 */
    select @MSD = isNull(MSD, 0) from store(nolock) where gid = @astore
    select @asettleno = @aSettleno + @MSD

    begin transaction
    if @option_ISZBPAY = 0
    begin
      if exists (select * from FAVDRPT(NOLOCK)
                 where ASETTLENO = @ASETTLENO and BGDGID = @BGDGID AND ASTORE = @ASTORE
                   and ADATE = @ADATE and BWRH = @BWRH AND BVDRGID = @BVDRGID and BCSTGID = @BCSTGID)
      begin
        DELETE FROM FAVDRPT
          where ASETTLENO = @ASETTLENO and BGDGID = @BGDGID AND ASTORE = @ASTORE
            and ADATE = @ADATE and BWRH=@BWRH AND BVDRGID = @BVDRGID and BCSTGID = @BCSTGID
      end
      insert into FAVDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID, FAVTYPE, FAVRATE,
        FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID, LSTUPDTIME)
      VALUES (@ASTORE, @ASETTLENO, @ADATE, @BVDRGID, @BWRH, @BGDGID, @FAVTYPE, @FAVRATE,
        @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID, getdate())

      delete from NFAVDRPT where ID = @ID
    end else if @option_ISZBPAY = 1
    begin
      select @SALE = SALE, @PAYRATE = PAYRATE, @BILLTO = BILLTO from GOODSH(nolock) where GID = @BGDGID
      if exists (select * from FAVDRPT(NOLOCK)
                 where ASETTLENO = @ASETTLENO and BGDGID = @BGDGID AND ASTORE = @ASTORE
                   and ADATE = @ADATE and BWRH = @BWRH AND BVDRGID = @BVDRGID and BCSTGID = @BCSTGID)
      begin
        DELETE FROM FAVDRPT
          where ASETTLENO = @ASETTLENO and BGDGID = @BGDGID AND ASTORE = @ASTORE
            and ADATE = @ADATE and BWRH = @BWRH and BCSTGID = @BCSTGID --AND BVDRGID = @BVDRGID
      end
      set @FAVPAY = 0
      if @SALE = 3 set @FAVPAY = CONVERT(DEC(20, 2), @FAVAMOUNT * @PAYRATE * 1 / 100)
      insert into FAVDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID, FAVTYPE, FAVRATE, --供应商
        FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID, LSTUPDTIME)
      VALUES (@ASTORE, @ASETTLENO, @ADATE, @BILLTO, @BWRH, @BGDGID, @FAVTYPE, 1,
        @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID, getdate())

      if @option_FAVADDVDR = 1
      begin
        execute AppUpdVdrDrpt @ZBGID, @ASETTLENO, @ADATE, @BILLTO, @BWRH, @BGDGID,
          0, 0, 0, 0, 0, 0, 0, 0, @FAVPAY, 0, 0, 0, 0, 0
        if not exists (select * from osbal (nolock)
          where store = @ZBGID and settleno = @ASETTLENO and date = @ADATE
            and wrh = @BWRH and gdgid = @BGDGID and vdrgid = @BILLTO)
          insert into osbal(store, settleno, date, vdrgid, wrh, gdgid)
        values(@ZBGID, @ASETTLENO, @ADATE, @BILLTO, @BWRH, @BGDGID)

      update osbal set dt2 = dt2 + isnull(@FAVPAY, 0) --应结额
      where store = @ZBGID and settleno = @ASETTLENO and date = @ADATE
          and wrh = @BWRH and gdgid = @BGDGID and vdrgid = @BILLTO
      end

      if @SALE = 3 set @FAVPAY = 0
      insert into FAVDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID, FAVTYPE, FAVRATE, --总部
        FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID, LSTUPDTIME)
      VALUES (@ASTORE, @ASETTLENO, @ADATE, @BVDRGID, @BWRH, @BGDGID, @FAVTYPE, 0,
        @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID, getdate())
      insert into FAVDRPT (ASTORE, ASETTLENO, ADATE, BVDRGID, BWRH, BGDGID, FAVTYPE, FAVRATE, --门店
        FAVAMOUNT, FAVPAY, PROMCLS, PROMNUM, PROMLINE, BCSTGID, LSTUPDTIME)
      VALUES (@ASTORE, @ASETTLENO, @ADATE, @ASTORE, @BWRH, @BGDGID, @FAVTYPE, 0,
        @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID, getdate())

      delete from NFAVDRPT where ID = @ID
    end
    commit transaction
    /* 下一条记录 */
    fetch next from c_favdrpt into
      @id, @astore, @asettleno, @adate, @bvdrgid, @bgdgid, @bwrh,
      @FAVTYPE, @FAVRATE, @FAVAMOUNT, @FAVPAY, @PROMCLS, @PROMNUM, @PROMLINE, @BCSTGID
  end
  close c_favdrpt
  deallocate c_favdrpt
end
GO
