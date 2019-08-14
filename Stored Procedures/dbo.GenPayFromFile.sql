SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

CREATE PROCEDURE [dbo].[GenPayFromFile] (
  @piOperGid INT,
  @piSplit INT,
  @piAutoChk INT,
  @poErrMsg VARCHAR(255) OUTPUT    --出错信息
  )
   AS
  begin
    declare @NCount INT,
            @BATCHFLAG INT,
            @nSelf INT,
            @VRtn INT,
            @opt INT

    set @VRtn = 0
    select @NCount = count(*) from #PayImp
    if @NCount = 0
    begin
      set @poErrMsg = '没有数据'
      return 0
    end
    select @nSelf = USERGID from SYSTEM
    select @BATCHFLAG = BATCHFLAG from system
    if @BATCHFLAG is NULL
      set @BATCHFLAG = 0
    if object_id('TEMPDB..#PayImpDtl') is null
      create table #PayImpDtl(VDRGID INT not NULL,
                              BNUM varchar(14) NULL,
                              GDGID INT not NULL,
                              SALE INT NULL,
                              TAXRATE MONEY NULL,
                              QTY MONEY NULL,
                              NPQTY MONEY NULL,
                              TOTAL MONEY NULL,
                              NPTOTAL MONEY NULL,
                              STOTAL MONEY NULL,
                              NPSTOTAL MONEY NULL,
                              INPRC MONEY NULL,
                              RTLPRC MONEY NULL,
                              FromNUM VARCHAR(14) NULL,
                              FromLINE INT NULL,
                              FromCLS VARCHAR(14) NULL,
                              FromPayDate DATETIME NULL,
                              GDWRH INT NULL,
                              GDF1 VARCHAR(13) NULL,
                              SETTLEDEPT VARCHAR(10))
    else
      delete from #PayImpDtl

    update #PayImp set SRCGID = B.GID from #PayImp A, Store B
      where A.SRC = B.CODE


    insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
      SELECT s.BillTo VDRGID,SD.BNUM, G.GID GDGID,
      G.SALE, G.TAXRATE,
   SD.QTY - SD.BCKQTY - SD.PAYQTY QTY,
   SD.QTY - SD.BCKQTY - SD.PAYQTY NPQTY,
   SD.TOTAL - SD.BCKAMT - SD.PAYAMT TOTAL,
   SD.TOTAL - SD.BCKAMT - SD.PAYAMT NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   SD.NUM FromNUM, SD.LINE FromLINE,
   '自营进' FromCLS, s.chkdate  FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
   FROM  GOODSH G(NOLOCK), STKINDTL SD(NOLOCK), STKIN S(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = SD.GDGID
   AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND SD.CLS = '自营'
   AND SD.CLS = S.CLS
   AND SD.NUM = S.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND S.STAT = 6
     AND (SD.QTY <> SD.BCKQTY + SD.PAYQTY)
     AND S.NUM IN (select NUM from #PayImp where CLS = '自营进' and SRCGID = @nSelf)

   insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
      SELECT s.BillTo VDRGID,SD.BNUM, G.GID GDGID,
      G.SALE, G.TAXRATE,
   SD.QTY - SD.BCKQTY - SD.PAYQTY QTY,
   SD.QTY - SD.BCKQTY - SD.PAYQTY NPQTY,
   SD.TOTAL - SD.BCKAMT - SD.PAYAMT TOTAL,
   SD.TOTAL - SD.BCKAMT - SD.PAYAMT NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   SD.NUM FromNUM, SD.LINE FromLINE,
   '自营进' FromCLS, s.chkdate  FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
   FROM  GOODSH G(NOLOCK), STKINDTL SD(NOLOCK), STKIN S(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = SD.GDGID
   AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND SD.CLS = '自营'
   AND SD.CLS = S.CLS
   AND SD.NUM = S.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND S.STAT = 6
     AND (SD.QTY <> SD.BCKQTY + SD.PAYQTY)
     AND S.SRCNUM = T.NUM AND T.CLS = '自营进' and T.SRCGID <> @nSelf
     AND S.SRC = T.SRCGID

   insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
      SELECT s.billto VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   -(SD.QTY - SD.PAYQTY) QTY,
   -(SD.QTY - SD.PAYQTY) NPQTY,
   -(SD.TOTAL - SD.PAYAMT) TOTAL,
   -(SD.TOTAL - SD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   SD.NUM FromNUM, SD.LINE FromLINE,
  '自营进退' FromCLS, s.chkdate  FromPayDate, G.WRH GDWRH , G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), STKINBCKDTL SD(NOLOCK), STKINBCK S(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = SD.GDGID
   AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND SD.CLS = '自营'
   AND SD.CLS = S.CLS
   AND SD.NUM = S.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND S.STAT = 6
   AND (SD.QTY <> SD.PAYQTY)
   AND S.NUM IN (select NUM from #PayImp where CLS = '自营进退' and SRCGID = @nSelf)

 insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
      SELECT s.billto VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   -(SD.QTY - SD.PAYQTY) QTY,
   -(SD.QTY - SD.PAYQTY) NPQTY,
   -(SD.TOTAL - SD.PAYAMT) TOTAL,
   -(SD.TOTAL - SD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   SD.NUM FromNUM, SD.LINE FromLINE,
  '自营进退' FromCLS, s.chkdate  FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), STKINBCKDTL SD(NOLOCK), STKINBCK S(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = SD.GDGID
   AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND SD.CLS = '自营'
   AND SD.CLS = S.CLS
   AND SD.NUM = S.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND S.STAT = 6
   AND (SD.QTY <> SD.PAYQTY)
   AND S.SRCNUM = T.NUM AND T.CLS = '自营进退' and T.SRCGID <> @nSelf
     AND S.SRC = T.SRCGID

   insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
    SELECT d.vendor VDRGID,DD.BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   DD.QTY - DD.BCKQTY - DD.PAYQTY QTY,
   DD.QTY - DD.BCKQTY - DD.PAYQTY NPQTY,
   DD.TOTAL - DD.BCKAMT - DD.PAYAMT TOTAL,
   DD.TOTAL - DD.BCKAMT - DD.PAYAMT NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   d.cls   FromCLS, D.chkdate FromPayDate, G.WRH GDWRH , G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), DIRALCDTL DD(NOLOCK), DIRALC D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = DD.GDGID
     AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND DD.CLS = D.CLS
    AND D.CLS in ('直配出','直销')
   AND D.STAT = 6
   AND (DD.QTY <> DD.BCKQTY + DD.PAYQTY)
   AND D.NUM IN (select NUM from #PayImp where CLS in ('直配出', '直销') and SRCGID = @nSelf)

  insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
    SELECT d.vendor VDRGID,DD.BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   DD.QTY - DD.BCKQTY - DD.PAYQTY QTY,
   DD.QTY - DD.BCKQTY - DD.PAYQTY NPQTY,
   DD.TOTAL - DD.BCKAMT - DD.PAYAMT TOTAL,
   DD.TOTAL - DD.BCKAMT - DD.PAYAMT NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   d.cls   FromCLS, D.chkdate FromPayDate, G.WRH GDWRH , G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), DIRALCDTL DD(NOLOCK), DIRALC D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = DD.GDGID
     AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND DD.CLS = D.CLS
    AND D.CLS in ('直配出','直销')
   AND D.STAT = 6
   AND (DD.QTY <> DD.BCKQTY + DD.PAYQTY)
   AND D.SRCNUM = T.NUM AND T.CLS in ('直配出', '直销') and T.SRCGID <> @nSelf
     AND D.SRC = T.SRCGID

    insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
    SELECT d.vendor VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   -(DD.QTY - DD.PAYQTY) QTY,
   -(DD.QTY - DD.PAYQTY) NPQTY,
   -(DD.TOTAL - DD.PAYAMT) TOTAL,
   -(DD.TOTAL - DD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   d.cls FromCLS, d.chkdate FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), DIRALCDTL DD(NOLOCK), DIRALC D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = DD.GDGID
     AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
    AND DD.CLS = D.CLS
   AND D.CLS in ('直配出退','直销退')
   AND D.STAT =6
    AND (DD.QTY <> DD.PAYQTY)
    AND D.NUM IN (select NUM from #PayImp where CLS in ('直配出退', '直销退') and SRCGID = @nSelf)

  insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
    SELECT d.vendor VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   -(DD.QTY - DD.PAYQTY) QTY,
   -(DD.QTY - DD.PAYQTY) NPQTY,
   -(DD.TOTAL - DD.PAYAMT) TOTAL,
   -(DD.TOTAL - DD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   d.cls FromCLS, d.chkdate FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), DIRALCDTL DD(NOLOCK), DIRALC D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = DD.GDGID
     AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
    AND DD.CLS = D.CLS
   AND D.CLS in ('直配出退','直销退')
   AND D.STAT =6
    AND (DD.QTY <> DD.PAYQTY)
    AND D.SRCNUM = T.NUM AND T.CLS in ('直配出退', '直销退') and T.SRCGID <> @nSelf
     AND D.SRC = T.SRCGID

   if @BATCHFLAG = 2
    insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
      SELECT d.vendor VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   0 QTY,  0 NPQTY,
   -(DD.ADJCOST - DD.PAYAMT) TOTAL,
   -(DD.ADJCOST - DD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.SUBWRH FromLINE,
   CASE DD.CLS WHEN '批次' THEN '批次调整' ELSE '成本调整' END FromCLS,
   d.VRFDATE FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
    FROM GOODSH G(NOLOCK), IPA2SWDTL DD(NOLOCK), IPA2 D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK)
   WHERE G.SALE = 1
   AND G.GID = DD.GDGID
     AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND DD.CLS = D.CLS
   AND D.STAT = 2 AND D.FINISHED = 0
   AND (DD.PAYAMT < DD.ADJCOST)
     AND DD.INCLS <> '直销退'
     AND D.NUM IN (select NUM from #PayImp where CLS in ('批次调整', '成本调整'))

     EXEC OPTREADINT 649, 'PAYCOLUMN', 0, @opt OUTPUT
     if @opt = 0
       insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
         STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
       SELECT d.VENDOR VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   (DD.QTY - DD.PAYQTY) QTY,
   (DD.QTY - DD.PAYQTY) NPQTY,
   (DD.AMT - DD.PAYAMT) TOTAL,
   (DD.AMT - DD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   '供应商返利' FromCLS, d.SUBTIME FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
       FROM GOODSH G(NOLOCK), INPRCADJNOTIFYBCKDTL DD(NOLOCK), INPRCADJNOTIFY D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
    WHERE G.SALE = 1
   AND G.GID = DD.GDGID
         AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND D.STAT = 300
      AND (DD.QTY <> DD.PAYQTY)
      AND D.NUM = T.NUM AND T.CLS in ('供应商返利')-- and T.SRCGID = @nSelf
         AND D.SRCSTORE = isnull(T.SRCGID, D.SRCSTORE)
     else
       insert into #PayImpDtl (VDRGID, BNUM, GDGID, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
         STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDWRH, GDF1, SETTLEDEPT)
       SELECT d.VENDOR VDRGID,NULL BNUM, G.GID GDGID,
   G.SALE, G.TAXRATE,
   (DD.QTY - DD.PAYQTY) QTY,
   (DD.QTY - DD.PAYQTY) NPQTY,
   (DD.CNTAMT - DD.PAYAMT) TOTAL,
   (DD.CNTAMT - DD.PAYAMT) NPTOTAL,
   0 STOTAL, 0 NPSTOTAL, G.INPRC, G.RTLPRC,
   DD.NUM FromNUM, DD.LINE FromLINE,
   '供应商返利' FromCLS, d.SUBTIME FromPayDate, G.WRH GDWRH, G.F1 GDF1, SDD.CODE SETTLEDEPT
       FROM GOODSH G(NOLOCK), INPRCADJNOTIFYBCKDTL DD(NOLOCK), INPRCADJNOTIFY D(NOLOCK), SETTLEDEPTDEPT SDD(NOLOCK), #PayImp T(NOLOCK)
    WHERE G.SALE = 1
   AND G.GID = DD.GDGID
         AND (G.KEEPTYPE & 1 <> 1 or G.NCANPAY = 1 or G.NENDTIME < getdate())
   AND DD.NUM = D.NUM
   AND G.F1 *= SDD.DEPTCODE
   AND D.STAT = 300
      AND (DD.QTY <> DD.PAYQTY)
      AND D.NUM = T.NUM AND T.CLS in ('供应商返利')-- and T.SRCGID = @nSelf
         AND D.SRCSTORE = isnull(T.SRCGID, D.SRCSTORE) --zz 090402

   --经销商品没有dtldtl数据
   select @NCount = count(*) from #PayImpDtl
    if @NCount = 0
    begin
      set @poErrMsg = '没有要处理的数据.'
      return 0
    end

    declare @VDRGID INT,
            @GDWRH INT,
            @GDF1 varchar(13),
            @FSETTLEDEPT varchar(10),
            @GDGID INT,
            @BNUM VARCHAR(14),
            @SALE INT,
            @TAXRATE MONEY,
            @QTY MONEY,
            @NPQTY MONEY,
            @TOTAL MONEY,
            @NPTOTAL MONEY,
            @STOTAL MONEY,
            @NPSTOTAL MONEY,
            @INPRC MONEY,
            @RTLPRC MONEY,
            @FromNUM VARCHAR(14),
            @FromLINE INT,
            @FromCLS VARCHAR(14),
            @FromPayDate DATETIME,

            @LVDRGID INT,
            @LGDWRH INT,
            @LGDF1 Varchar(13),
            @LSETTLEDEPT Varchar(10),
            @LGDTaxRate Money,
            @LINE INT,
            @SAMT MONEY,
            @Settle INT,
            @NUM VARCHAR(14),
            @TAX decimal(24,2),
            @WRH INT,
            @NF1 VARCHAR(13),
            @SD VARCHAR(10),
            @NTAXRATE MONEY,
            --zz 090402
            @SettleDeptLimit int,
            @AutoGetSettleDeptMethod int,
            @CleCent int,
            @SettleDept VARCHAR(13)

    select @Settle = MAX(NO) from monthsettle
    --zz 090402
    EXEC OPTREADINT 0, 'SettleDeptLimit', 0, @SettleDeptLimit OUTPUT
    EXEC OPTREADINT 0, 'AutoGetSettleDeptMethod', 0, @AutoGetSettleDeptMethod OUTPUT

    declare C_BatchPay cursor for
      select VDRGID, GDWRH, GDGID, BNUM, SALE, TAXRATE, QTY, NPQTY, TOTAL, NPTOTAL,
        STOTAL, NPSTOTAL, INPRC, RTLPRC, FromNUM, FromLINE, FromCLS, FromPayDate, GDF1, SETTLEDEPT
          from #PayImpDtl where TOTAL <> 0
            order by VDRGID, GDWRH, GDF1, TAXRATE  --edited by jinlei
    Open C_BatchPay
    Fetch next from C_BatchPay into @VDRGID, @GDWRH, @GDGID, @BNUM, @SALE, @TAXRATE, @QTY,
            @NPQTY, @TOTAL, @NPTOTAL, @STOTAL, @NPSTOTAL, @INPRC, @RTLPRC,
            @FromNUM, @FromLINE, @FromCLS, @FromPayDate, @GDF1, @FSETTLEDEPT
    if @@fetch_Status = 0
    begin
      set @LVDRGID = @VDRGID
      set @LGDWRH = @GDWRH
      set @LGDF1 = @GDF1
      set @LSETTLEDEPT = @FSETTLEDEPT
      set @LGDTaxRate = @TaxRate
      set @SAMT = 0
      set @LINE = 0
      select @NUM = Max(NUM) from Pay
      if @NUM is NULL
        set @NUM = '0000000001'
      else
          EXEC NEXTBN @NUM, @NUM OUTPUT
    end
    while @@fetch_Status = 0
    begin
      if @LVDRGID <> @VDRGID
        or (@piSplit & 1 = 1 and @LGDWRH <> @GDWRH) --分单
        or (@piSplit & 2 = 2 and @LGDF1 <> @GDF1)
        or (@piSplit & 4 = 4 and @LGDTaxRate <> @TaxRate)
      begin
        if @piSplit & 1 = 1
          set @WRH = @LGDWRH
        else
          set @WRH = 1
        if @piSplit & 2 = 2
          set @NF1 = @LGDF1
        else
          set @NF1 = ''
        if @piSplit & 4 = 4
          set @NTAXRATE = @LGDTAXRATE
        else
          set @NTAXRATE = -1
        if @piSplit & 8 = 8
          set @SD = @LSETTLEDEPT
        else
          set @SD = ''  
        --zz 090402
        if @SettleDeptLimit = 1
        begin
          if @AutoGetSettleDeptMethod = 1
            Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTDEPT D(nolock)
              where S.Code = D.Code and D.DeptCode = @NF1
          else if @AutoGetSettleDeptMethod = 2
            Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTVDR V(nolock)
              where S.Code = V.Code and VDRGID = @LVDRGID
          else if @AutoGetSettleDeptMethod = 3
            Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTWRH W(nolock)
              where S.Code = W.Code and WrhGid = @WRH

          if @SettleDept <> ''
            Select @CleCent = CASHCENTER from CNCASHCENTER(nolock)
              where STORE = @nSelf and DEPT = @SettleDept and VENDOR = @LVDRGID
          else
            set @CleCent = NULL
        end
        --end 090402

        insert into Pay(Num,SettleNo,Fildate,Filler,
            Checker, wrh, BillTo, Amt, Stat, Note, Dept, TaxRateLmt, CLECENT, SRC, SettleDept) values --zz 090402
          (@NUM, @Settle, GETDATE(), @piOperGid,
            1, @WRH, @LVDRGID, @SAMT, 0, '手工或文件导入', @NF1, @NTAXRATE, @CLECENT, @nSelf, @SD) --zz 090402
        if @piAutoChk = 1
        begin
          EXEC @VRtn = PAYCHK @NUM, @poErrMsg output
          if @VRtn <> 0
          begin
            set @poErrMsg = '审核单据失败:' + @poErrMsg
            break
          end
        end
        insert into #PayNum (NUM, AMT) VALUES (@NUM, @SAMT)
        set @LVDRGID = @VDRGID
        set @LGDWRH = @GDWRH
        set @LGDF1 = @GDF1
        set @LGDTAXRATE = @TAXRATE
        set @SAMT = 0
        set @LINE = 0
        select @NUM = Max(NUM) from Pay
        if @NUM is NULL
          set @NUM = '0000000001'
        else
          EXEC NEXTBN @NUM, @NUM OUTPUT
      end
      set @LINE = @LINE + 1
      set @TAX =  ((@TOTAL*(1-1 /(1 + @TAXRATE / 100)))*100 + 0.5) / 100
      set @SAMT  = @SAMT + @TOTAL
      --2005.02.02
      if exists(select 1 from Pay where num = @num)
        raiserror('[%s]已经存在汇总单据记录，单号被占用，请重新生成！', 16, 1, @num)
      insert into paydtl(Num,Line,SettleNo,GDGID,NpQty,NpTotal,NpSTotal,Qty,Total,Tax,sTotal,
                INPrc,RtlPrc,bNum,FromCls,FromNum,FromLine,FromPayDate) values
          (@NUM, @LINE, @Settle, @GDGID, @NPQTY, @NPTOTAL, @NPSTOTAL, @QTY, @TOTAL, @TAX, @STOTAL,
                @INPRC, @RTLPRC, @BNUM, @FromCLS, @FromNUM, @FromLINE, @FromPayDate)
      Fetch next from C_BatchPay into @VDRGID, @GDWRH, @GDGID, @BNUM, @SALE, @TAXRATE, @QTY,
            @NPQTY, @TOTAL, @NPTOTAL, @STOTAL, @NPSTOTAL, @INPRC, @RTLPRC,
            @FromNUM, @FromLINE, @FromCLS, @FromPayDate, @GDF1
    end
    CLOSE C_BatchPay
    DEALLOCATE C_BatchPay
    if @VRtn <> 0
      return -1
    if @VDRGID is not NULL
    begin
      if @piSplit & 1 = 1
        set @WRH = @GDWRH
      else
        set @WRH = 1
      if @piSplit & 2 = 2
        set @NF1 = @LGDF1
      else
        set @NF1 = ''
      if @piSplit & 4 = 4
        set @NTAXRATE = @LGDTAXRATE
      else
        set @NTAXRATE = -1
      if @piSplit & 8 = 8
          set @SD = @LSETTLEDEPT
        else
          set @SD = ''
      --zz 090402
      if @SettleDeptLimit = 1
      begin
        if @AutoGetSettleDeptMethod = 1
          Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTDEPT D(nolock)
            where S.Code = D.Code and D.DeptCode = @NF1
        else if @AutoGetSettleDeptMethod = 2
          Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTVDR V(nolock)
            where S.Code = V.Code and VDRGID = @LVDRGID
        else if @AutoGetSettleDeptMethod = 3
          Select @SettleDept = ISNULL(S.CODE, '') from SETTLEDEPT S(nolock), SETTLEDEPTWRH W(nolock)
            where S.Code = W.Code and WrhGid = @WRH

        if @SettleDept <> ''
          Select @CleCent = CASHCENTER from CNCASHCENTER(nolock)
            where STORE = @nSelf and DEPT = @SettleDept and VENDOR = @LVDRGID
        else
          set @CleCent = NULL
      end
      --end 090402

      insert into Pay(Num,SettleNo,Fildate,Filler,
            Checker,wrh,BillTo,Amt,Stat,Note, Dept, TaxRateLmt, CLECENT, SRC, SETTLEDEPT) values --zz 090402
          (@NUM, @Settle, GETDATE(), @piOperGid,
            1, @WRH, @VDRGID, @SAMT, 0, '手工或文件导入', @NF1, @NTAXRATE, @CLECENT, @nSelf, @SD) --zz 090402
      if @piAutoChk = 1
      begin
        EXEC @VRtn = PAYCHK @NUM, @poErrMsg output
        if @VRtn <> 0
        begin
          set @poErrMsg = '审核单据失败:' + @poErrMsg
          return -1
        end
      end
      insert into #PayNum (NUM, AMT) VALUES (@NUM, @SAMT)
    end
    if @VRtn <> 0
      return -1
    else
    begin
      select @NCount = Count(*) from #PayNum
      return @NCount
    end
  end
GO
