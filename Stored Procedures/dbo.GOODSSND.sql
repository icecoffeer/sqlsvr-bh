SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[GOODSSND] (  
  @gdgid int,  
  @rcv int,  
  @frcupd int,  
  @sendInputCode int,  
  @sendVendor int  
)  
as  
begin  
  declare @sndflag varchar(100)  
  declare @teamid int  
  declare @sqlstring varchar(2000)  
  declare @usergid int  
  
  select @usergid = usergid from system(nolock)  
  select @sndflag = isnull(sndflag, '') from store(nolock) where gid = @rcv  
  exec @teamid = SeqNextValue 'NGoods_TeamID'  
  set @sqlstring = 'insert into ngoods(teamid,gid,code,name,'  
  if substring(@sndflag, 2, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'spec,'  
  if substring(@sndflag, 3, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'sort,'  
  if substring(@sndflag, 4, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'rtlprc, '  
  if substring(@sndflag, 5, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'inprc, '  
  if substring(@sndflag, 6, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'taxrate, '  
  if substring(@sndflag, 7, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'promote, '  
  if substring(@sndflag, 8, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'prctype, '  
  if substring(@sndflag, 9, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'sale, '  
  if substring(@sndflag, 10, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lstinprc, '  
  if substring(@sndflag, 11, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'invprc, '  
  if substring(@sndflag, 12, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'oldinvprc, '  
  if substring(@sndflag, 13, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lwtrtlprc, '  
  if substring(@sndflag, 14, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'whsprc, '  
  set @sqlstring = @sqlstring + 'wrh, '  
  if substring(@sndflag, 15, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'acnt, '  
  if substring(@sndflag, 16, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'paytodtl, '  
  if substring(@sndflag, 17, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'payrate, '  
  if substring(@sndflag, 18, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'munit, '  
  set @sqlstring = @sqlstring + 'ispkg, isbind, '  
  if substring(@sndflag, 19, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'gft, '  
  if substring(@sndflag, 20, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'qpc, '  
  if substring(@sndflag, 21, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'tm, '  
  if substring(@sndflag, 22, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'manufactor, '  
  if substring(@sndflag, 23, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'mcode, '  
  if substring(@sndflag, 24, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'gpr, '  
  if substring(@sndflag, 25, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lowinv, '  
  if substring(@sndflag, 26, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'highinv, '  
  if substring(@sndflag, 27, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'validperiod, '  
  set @sqlstring = @sqlstring + 'createdate, '  
  if substring(@sndflag, 28, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'memo, '  
  if substring(@sndflag, 29, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'chkvd, '  
  if substring(@sndflag, 30, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'dxprc, '  
  if substring(@sndflag, 31, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'billto, '  
  set @sqlstring = @sqlstring + 'src, sndtime, rcv, rcvtime, frcupd, type, nstat, nnote, '  
  if substring(@sndflag, 32, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'origin, '  
  if substring(@sndflag, 33, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'grade, '  
  if substring(@sndflag, 34, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'mbrprc, '  
  if substring(@sndflag, 35, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'saletax, '  
  if substring(@sndflag, 36, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alc, '  
  if substring(@sndflag, 37, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'code2, '  
  if substring(@sndflag, 38, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'brand, '  
  if substring(@sndflag, 39, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'psr, '  
  if substring(@sndflag, 40, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'cntinprc, '  
  if substring(@sndflag, 41, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'f1, '  
  if substring(@sndflag, 42, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'isltd, '  
  if substring(@sndflag, 43, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'bqtyprc, '  
  if substring(@sndflag, 44, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alcqty, '  
  if substring(@sndflag, 45, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'keeptype, '  
  if substring(@sndflag, 46, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'autoord, '  
  if substring(@sndflag, 47, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'nendtime, '  
  if substring(@sndflag, 48, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ncanpay, '  
  if substring(@sndflag, 49, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ssstart, '  
  if substring(@sndflag, 50, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ssend, '  
  if substring(@sndflag, 51, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'season, '  
  if substring(@sndflag, 52, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'hqcontrol, '  
  if substring(@sndflag, 53, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ordcycle, '  
  if substring(@sndflag, 54, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alcctr, '  
  if substring(@sndflag, 55, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'isdisp,'  
  if substring(@sndflag, 56, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'TopRtlPrc,'  
  if substring(@sndflag, 57, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'MKTINPRC,'  
  if substring(@sndflag, 58, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'UPCTRL,'  
  if substring(@sndflag, 59, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ORDERQTY,'  --2006.4.18, ShenMin, Q6540, 商品增加定货单位  
  if substring(@sndflag, 60, 1) in ('0', '')  -- 2006.5.16, ShenMin, Q6714, 发送商品资料时没有发送交货方式(SubmitType)字段  
    set @sqlstring = @sqlstring + 'SubmitType,'  --2006.5.16, ShenMin, Q6714, 发送商品资料时没有发送交货方式(SubmitType)字段  
  if substring(@sndflag, 61, 1) in ('0', '')  -- 2006.5.16, ShenMin, Q6714, 发送商品资料时没有发送交货方式(SubmitType)字段  
    set @sqlstring = @sqlstring + 'EliReason,' --Shenmin  
  if substring(@sndflag, 62, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'NOAUTOORDREASON,' --2007.2.26, ShenMin  
  if substring(@sndflag, 63, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'SALCQTY,' --08.01.02, ZZ  
  if substring(@sndflag, 64, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'SALCQSTART,' --08.01.02, ZZ  
  if substring(@sndflag, 69, 1) in ('0', '') --zz 090424  
    set @sqlstring = @sqlstring + 'TJCODE,'  
  set @sqlstring = @sqlstring + 'TAXSORT,'  
  
  set @sqlstring = rtrim(@sqlstring)  
  if substring(@sqlstring, len(@sqlstring), 1) = ','  
    set @sqlstring = substring(@sqlstring, 1, len(@sqlstring)-1) + ')'  
  set @sqlstring = @sqlstring + ' select ' + convert(char, @teamid) + ',gid,code,'  
  if substring(@sndflag, 1, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'name,'  
  else  
    set @sqlstring = @sqlstring + '''''' + ','  
  if substring(@sndflag, 2, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'spec,'  
  if substring(@sndflag, 3, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'sort,'  
  if substring(@sndflag, 4, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'rtlprc, '  
  if substring(@sndflag, 5, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'inprc, '  
  if substring(@sndflag, 6, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'taxrate, '  
  if substring(@sndflag, 7, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'promote, '  
  if substring(@sndflag, 8, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'prctype, '  
  if substring(@sndflag, 9, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'sale, '  
  if substring(@sndflag, 10, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lstinprc, '  
  if substring(@sndflag, 11, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'invprc, '  
  if substring(@sndflag, 12, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'oldinvprc, '  
  if substring(@sndflag, 13, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lwtrtlprc, '  
  if substring(@sndflag, 14, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'whsprc, '  
  set @sqlstring = @sqlstring + 'wrh, '  
  if substring(@sndflag, 15, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'acnt, '  
  if substring(@sndflag, 16, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'paytodtl, '  
  if substring(@sndflag, 17, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'payrate, '  
  if substring(@sndflag, 18, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'munit, '  
  set @sqlstring = @sqlstring + 'ispkg, isbind, '  
  if substring(@sndflag, 19, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'gft, '  
  if substring(@sndflag, 20, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'qpc, '  
  if substring(@sndflag, 21, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'tm, '  
  if substring(@sndflag, 22, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'manufactor, '  
  if substring(@sndflag, 23, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'mcode, '  
  if substring(@sndflag, 24, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'gpr, '  
  if substring(@sndflag, 25, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'lowinv, '  
  if substring(@sndflag, 26, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'highinv, '  
  if substring(@sndflag, 27, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'validperiod, '  
  set @sqlstring = @sqlstring + 'createdate, '  
  if substring(@sndflag, 28, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'memo, '  
  if substring(@sndflag, 29, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'chkvd, '  
  if substring(@sndflag, 30, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'dxprc, '  
  if substring(@sndflag, 31, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'billto, '  
  set @sqlstring = @sqlstring + convert(char, @usergid) + ',getdate(),'  
  set @sqlstring = @sqlstring + convert(char, @rcv) + ',null,' + convert(char, @frcupd) + ',0,0,null,'  
  if substring(@sndflag, 32, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'origin, '  
  if substring(@sndflag, 33, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'grade, '  
  if substring(@sndflag, 34, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'mbrprc, '  
  if substring(@sndflag, 35, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'saletax, '  
  if substring(@sndflag, 36, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alc, '  
  if substring(@sndflag, 37, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'code2, '  
  if substring(@sndflag, 38, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'brand, '  
  if substring(@sndflag, 39, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'psr, '  
  if substring(@sndflag, 40, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'cntinprc, '  
  if substring(@sndflag, 41, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'f1, '  
  if substring(@sndflag, 42, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'isltd, '  
  if substring(@sndflag, 43, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'bqtyprc, '  
  if substring(@sndflag, 44, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alcqty, '  
  if substring(@sndflag, 45, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'keeptype, '  
  if substring(@sndflag, 46, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'autoord, '  
  if substring(@sndflag, 47, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'nendtime, '  
  if substring(@sndflag, 48, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ncanpay, '  
  if substring(@sndflag, 49, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ssstart, '  
  if substring(@sndflag, 50, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ssend, '  
  if substring(@sndflag, 51, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'season, '  
  if substring(@sndflag, 52, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'hqcontrol, '  
  if substring(@sndflag, 53, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ordcycle, '  
  if substring(@sndflag, 54, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'alcctr, '  
  if substring(@sndflag, 55, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'isdisp,'  
  if substring(@sndflag, 56, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'TopRtlPrc,'  
  if substring(@sndflag, 57, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'MKTINPRC,'  
  if substring(@sndflag, 58, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'UPCTRL,'  
  if substring(@sndflag, 59, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'ORDERQTY,'  --2006.4.18, ShenMin, Q6540, 商品增加定货单位  
  if substring(@sndflag, 60, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'SubmitType,'  --2006.4.18, Zhourong  
  if substring(@sndflag, 61, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'EliReason,'  
  if substring(@sndflag, 62, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'NOAUTOORDREASON,' --2007.2.26, ShenMin  
  if substring(@sndflag, 63, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'SALCQTY,' --08.01.02, ZZ  
  if substring(@sndflag, 64, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'SALCQSTART,' --08.01.02, ZZ  
  if substring(@sndflag, 69, 1) in ('0', '')  
    set @sqlstring = @sqlstring + 'TJCODE,' --zz 090424 
  set @sqlstring = @sqlstring + 'TAXSORT,'      
  set @sqlstring = rtrim(@sqlstring)  
  if substring(@sqlstring, len(@sqlstring), 1) = ','  
    set @sqlstring = substring(@sqlstring, 1, len(@sqlstring)-1)  
  set @sqlstring = @sqlstring + ' from goods where gid = ' + convert(char, @gdgid)  
  
  exec(@sqlstring)  
  if @@error <> 0 return @@error  
  
  if substring(@sndflag, 9, 1) in ('0', '')  
    or substring(@sndflag, 25, 1) in ('0', '')  
    or substring(@sndflag, 26, 1) in ('0', '')  
    or substring(@sndflag, 31, 1) in ('0', '')  
    or substring(@sndflag, 36, 1) in ('0', '')  
    or substring(@sndflag, 42, 1) in ('0', '')  
    or substring(@sndflag, 43, 1) in ('0', '')  
  
 --2005.7.25 Edited by ShenMin, Q4527, 增加各店商品表的配货单位  
    or substring(@sndflag, 44, 1) in ('0', '')  
    or substring(@sndflag, 54, 1) in ('0', '')  
    or substring(@sndflag, 63, 1) in ('0', '')--zz  
    or substring(@sndflag, 64, 1) in ('0', '')--zz  
  
  begin  
    set @sqlstring = 'update ngoods set '  
    if substring(@sndflag, 9, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'sale=gdstore.sale,'  
    if substring(@sndflag, 25, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'lowinv=gdstore.lowinv,'  
    if substring(@sndflag, 26, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'highinv=gdstore.highinv,'  
    if substring(@sndflag, 31, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'billto=gdstore.billto,'  
    if substring(@sndflag, 36, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'alc=gdstore.alc,'  
    if substring(@sndflag, 42, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'isltd=gdstore.isltd,'  
    if substring(@sndflag, 43, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'bqtyprc=gdstore.bqtyprc,'  
  
  --2005.7.25 Edited by ShenMin, Q4527, 增加各店商品表的配货单位  
    declare @alcqty money  --2005.12.26, Edited by ShenMin, Q5601  
    exec GetGdValue @rcv, @gdgid,  'ALCQTY', @alcqty OUTPUT  
    if substring(@sndflag, 44, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'AlcQty = ' + convert(char, @alcqty) + ', '  
    if substring(@sndflag, 54, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'ALCCTR = isnull(gdstore.alcctr, ngoods.AlcCtr), '  
    if substring(@sndflag, 63, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'SALCQTY = isnull(gdstore.SALCQTY, ngoods.SALCQTY), ' --zz  
    if substring(@sndflag, 64, 1) in ('0', '')  
      set @sqlstring = @sqlstring + 'SALCQSTART = isnull(gdstore.SALCQSTART, ngoods.SALCQSTART), ' --zz  
    set @sqlstring = rtrim(@sqlstring)  
    if substring(@sqlstring, len(@sqlstring), 1) = ','  
      set @sqlstring = substring(@sqlstring, 1, len(@sqlstring)-1)  
    set @sqlstring = @sqlstring + ' from gdstore where gdstore.gdgid = ngoods.gid '  
      + 'and gdstore.storegid = ' + convert(char, @rcv) + ' and ngoods.id = @@identity and ngoods.src = ' + convert(char, @usergid)  
  
    exec(@sqlstring)  
    if @@error <> 0 return @@error  
  end  
  
  /*发送PKG*/  
  insert into npkg(teamid, pgid, egid, qty, src, rcv, rcvtime, frcupd, type, nstat, nnote)  
  select @teamid, pgid, egid, qty, @usergid, @rcv, null, @frcupd, 0, 0, null  
  from pkg where pgid = @gdgid  
  
  update goods set sndtime = getdate() where gid = @gdgid  
  
  /*发送BIND*/  
  insert into ngdbind(teamid, bindgid, egid, qty, eqpcstr, src, rcv, rcvtime, frcupd, type, nstat, nnote) --ShenMin  
  select @teamid, bindgid, egid, qty, eqpcstr, @usergid, @rcv, null, @frcupd, 0, 0, null  --ShenMin  
  from gdbind where bindgid = @gdgid  
  
  /*附带发送输入码*/  
  if @sendInputCode = 1  
    insert into ngdinput(teamid, src, code, codetype, gid, qpc, qpcstr, rcv, rcvtime, frcupd, type, nstat, nnote) --ShenMin  
    select @teamid, @usergid, code, codetype, gid, qpc, qpcstr, @rcv, null, @frcupd, 0, 0, null  --ShenMin  
    from gdinput where gid = @gdgid  
  
  /*附带发送供应商*/  
  if @sendVendor = 1  
  begin  
    if exists(select 1 from vdrgd2 where storegid = @rcv and gdgid = @gdgid)  
      insert into nvdrgd2(src, storegid, gdgid, vdrgid, rcv, rcvtime, type, nstat, nnote)  
      select @usergid, storegid, gdgid, vdrgid, @rcv, null, 0, 0, null  
      from vdrgd2 where storegid = @rcv and gdgid = @gdgid  
    else  
      insert into nvdrgd2(src, storegid, gdgid, vdrgid, rcv, rcvtime, type, nstat, nnote)  
      select @usergid, @rcv, gdgid, vdrgid, @rcv, null, 0, 0, null  
      from vdrgd2 where storegid = @usergid and gdgid = @gdgid  
    insert into nvendor(gid, code, name, shortname, address, taxno, accountno, fax, zip, tele,  
      createdate, property, settleaccount, payterm, memo, src, sndtime, rcv, rcvtime, frcupd,  
      type, nstat, lawrep, contactor, ctrphone, ctrbp, taxtype, nnote, days, keepamt, cdtrate, invcode,  
      PAYLIMITED,ADFEE, PRMFEE, EMAILADR, WWWADR, PAYCLS,  MVDR, ISUSETOKEN, SAFEAMT, SENDAREA, PAYTYPE,  
      UpCtrl, SendType, UPay, SendLocation)  
    select gid, code, name, shortname, address, taxno, accountno, fax, zip, tele, createdate, property,  
      settleaccount, payterm, memo, @usergid, getdate(), @rcv, null, @frcupd, 0, 0, lawrep, contactor,  
      ctrphone, ctrbp, taxtype, null, days, keepamt, cdtrate, invcode,  
      PAYLIMITED,ADFEE, PRMFEE, EMAILADR, WWWADR, PAYCLS,  MVDR, ISUSETOKEN, SAFEAMT, SENDAREA, PAYTYPE,  
      UpCtrl, SendType, UPay, SendLocation  
    from vendor, vdrgd2 where vendor.gid = vdrgd2.vdrgid and vdrgd2.storegid = @usergid and vdrgd2.gdgid = @gdgid and vdrgd2.vdrgid<>@usergid  
  end  
  
  /*附带发送商品规格表 ShenMin*/  
    insert into ngdqpc(teamid, src, gid, qpcstr, qpc, MUNIT, VOL, WEIGHT, ISDU, ISPU, ISWU, ISRU,  
                       RTLPRC, WHSPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE, rcv, rcvtime, frcupd, type, nstat, nnote)  
    select @teamid, @usergid, gid, qpcstr, qpc, MUNIT, VOL, WEIGHT, ISDU, ISPU, ISWU, ISRU,  
                       RTLPRC, WHSPRC, MBRPRC, LWTRTLPRC, TOPRTLPRC, BQTYPRC, PROMOTE, @rcv, null, @frcupd, 0, 0, null  
    from gdqpc where gid = @gdgid  
  
    if (select count(*) from gdqpcstore where gdgid = @gdgid and storegid = @rcv) > 0  
      begin  
        delete from ngdqpc where rcv = @rcv and gid = @gdgid and qpcstr not in  
          (select qpcstr from gdqpcstore where gdgid = @gdgid and gdqpcstore.storegid = @rcv)  
        if @sendInputCode = 1  
          delete from ngdinput where rcv = @rcv and gid = @gdgid and qpcstr not in  
            (select qpcstr from gdqpcstore where gdgid = @gdgid and gdqpcstore.storegid = @rcv)  
      end  
  
  /*附带发送商品不自动补货原因表 ShenMin*/  
    delete from NNOAUTOORDERREASON where SRC = @usergid and RCV = @rcv  
    insert into NNOAUTOORDERREASON(REASONCODE, REASONNAME, SRC, RCV, RCVTIME, TYPE, NSTAT, NNOTE, TEAMID)  
    select REASONCODE, REASONNAME, @usergid, @rcv, null, 0, 0, null, @teamid  
    from NOAUTOORDERREASON  
  
  return 0  
end;
GO
