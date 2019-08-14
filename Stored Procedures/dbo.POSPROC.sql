SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
CREATE procedure [dbo].[POSPROC](
  @buypool varchar(30),
  @posno varchar(10)
) --with encryption
as
begin
  declare
    @processed smallint,
    @flowno char(12),
    @settleno int,
    @date datetime,
    @itemno smallint,
    @gdgid int,
    @qty money,
    @inprc money,
    @rtlprc money,
    @realamt money,
    @favamt money, @favamt_saved money,
    @wrh int,
    @wrh1 int,
    @wrh2 int,
    @slrgid int,
    @amt money,
    @g_inprc money,
    @g_rtlprc money,
    @return_status int,
    @flag int  /*2005-11-22 zengyun 任务单5596*/
  declare
    @txtsettleno varchar(10),
    @temp1 smallint,
    @temp2 money,
    @temp3 money,
    @dxprc money,
    @payrate money,
    @vdrgid int,
    @guest int, /* 卡的GID */
    @cstgid int, /* 客户的GID */
    @fildate datetime,
    @msg varchar(100),
    @existsbuy int,
    @existscashieroperate int,
    @total_favamt money,
    @total_gdcnt money
  declare
    @temp money,
    @buy1_total money, @buy2_total money, @g_payrate money
  declare
    @param int, @credit smallint, @detaillevel smallint
  declare @score money -- 增加积分计算
  declare @outcost money  --2002-06-13
  declare @cardcode char(20) --增加卡号的回写

  -------取促销联销率
  declare @curtime datetime,
          @store int,
          @PoMsg varchar(255)  --ShenMin 错误信息
  -------end 取促销联销率
  declare @WSDISCOUNT MONEY,--交易折扣,用以计算折扣联销率

  --联网退货时取原零售单信息
    @OriPosNo varchar(10), @OriFlowNo varchar(12), @OriItemNo int,
    @OriInPrc decimal(24,4), @OriCost decimal(24,4), @RealCost decimal(24,4)  --联网退货时，成本应取原零售单成本
  ------------------------------------
  declare @sql nvarchar(4000)

    /* 99-6-11 dsp */
  declare
    @max_dsp_num char(10),
    @dsp_num char(10),
    @invnum char(13),
    @filler int,
    @opener int,
    @sale smallint,
    @reccnt int,
    @option_ISZBPAY int,
    @option_FAVADDVDR int --振华定制
  declare @ProcessICCARD char(1) --added by hxs 2003.09.05
  select @ProcessICCard = isnull(optionvalue,'0') from hdoption(nolock)
    where moduleno = 0 and optioncaption = 'PROCESSICCARD'
  exec OptReadInt 0, 'ISZBPAY', 0, @option_ISZBPAY output
  exec OptReadInt 0, 'FAVADDVDR', 0, @option_FAVADDVDR output

  /* check if there are unprocessed buy1 record */
  select @processed = 0
  select @settleno = max(NO) from MONTHSETTLE(nolock)
  select @txtsettleno = rtrim(convert(char, @settleno))
  select @date = convert(datetime, convert(char, getdate(), 102))
  select @existsbuy = object_id(@buypool + '..BUY1_' + @posno)
  select @existscashieroperate = object_id(@buypool + '..CASHIEROPERATE_' + @posno)

  /*2005-11-22 zengyun 任务单5596*/
  /*对应的POSNO的BUYPOOL表存在时再处理 ADD BY WUDIPING 20091202*/
  if @existsbuy is not null begin
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''dealer'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY1_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY1_' + @posno +
   '    add dealer int null'                )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''dealer'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY2_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY2_' + @posno +
   '    add dealer int null'
   )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''flag'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY1_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY1_' + @posno +
   '    add Flag int null'
   )
   /*2006-6-11 zengyun 任务单6886*/
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''iqty'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY2_' + @posno + '''))' +


   '  alter table ' + @buypool + '..BUY2_' + @posno +
   '    add iqty decimal(24,2) null'
   )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''gdcode'' and id = (' +
   '    select id from ' + @buypool + '..sysobjects where name = ''BUY2_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY2_' + @posno +
   '    add gdcode varchar(20) null'
   )
   /*2006-10-27 zengyun 任务单8075*/
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''favtype'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add favtype varchar(4) null'
   )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''favamt'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add favamt decimal(24,4) null'
   )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''parvalue'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add parvalue decimal(24,4) null'
   )
   /*2006-12-27 zengyun 任务单8675*/
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''CurrencyType'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add CurrencyType varchar(10) null'
   )
   execute(
   'if not exists(' +
   '  select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''OriginalAmt'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add OriginalAmt decimal(24,4) null'
   )
   execute(
   'if not exists(' +
   ' select 1 from ' + @buypool + '..syscolumns ' +
   '    where name = ''Parities'' and id = (' +
   '      select id from ' + @buypool + '..sysobjects where name = ''BUY11_' + @posno + '''))' +
   '  alter table ' + @buypool + '..BUY11_' + @posno +
   '    add Parities decimal(24,4) null'
   )
  end

  /*收银员缴款单缓冲表*/
  if object_id(@buypool + '..CheckIn_' + @posno) is not null
  begin
    begin transaction
    --先删除再插入；080227 ADD BY WUDIPING; 隔日修改的单据后台不再进行处理
    execute(
      ' delete from ' + @buypool + '..CheckInDtl_' + @posno +' where num in ' +
      ' (select Num from ' + @buypool + '..CheckIn_' + @posno + ' where ' +
         ' ( left(Num,6) <> convert(char(6),convert(datetime,Fildate,102),12) and len(num)=10 )  or  '+
         ' ( left(Num,8) <> convert(char(8),convert(datetime,Fildate,102),112) and len(num)=12 ) )')
       if @@error <> 0
        begin
         rollback transaction
         return 1
        end

    execute(
      ' delete from ' + @buypool + '..CheckIn_' + @posno + ' where ' +
         ' ( left(Num,6) <> convert(char(6),convert(datetime,Fildate,102),12) and len(num)=10 )  or  '+
         ' ( left(Num,8) <> convert(char(8),convert(datetime,Fildate,102),112) and len(num)=12 ) ')

       if @@error <> 0
        begin
         rollback transaction
         return 1
        end

    execute(
      ' delete  CASHCLTPOOL  from ' + @buypool + '..CheckIn_' + @posno + ' m  where  CASHCLTPOOL .num = m.num   and   CASHCLTPOOL .POSNO = ''' + @posno + '''')
    if @@error <> 0 begin
      rollback transaction
      return 1
    end
    execute(
      ' delete  CASHCLTDTLPOOL  from ' + @buypool + '..CheckInDtl_' + @posno + ' d   where  CASHCLTDTLPOOL.num = d.num   and   CASHCLTDTLPOOL .POSNO = ''' + @posno + '''')
    if @@error <> 0 begin
      rollback transaction
      return 1
    end
    execute(
      ' insert into CASHCLTPOOL (NUM, FILLTIME, OPERATOR, CASHIER, POSNO, BDATE, EDATE, ' +
      ' AMOUNT, REALAMOUNT, BILLCOUNT, LSTUPDTIME) ' +
      ' select m.Num, max(m.Fildate), max(m.Filler), max(m.Cashier), ''' + @posno + ''', max(m.BeginTime), max(m.EndTime), ' +
      ' sum(d.PayAmt), sum(d.RealAmt), max(m.BillCount), getdate() ' +
      ' from ' + @buypool + '..CheckIn_' + @posno + ' m, ' + @buypool + '..CheckInDtl_' + @posno + ' d ' +
         ' where not exists (select 1 from CASHCLTPOOL c(nolock) where c.num=m.num  and c.posno='+''''+ @posno +''''+'  ) and m.num = d.num group by m.num' )

    if @@error <> 0 begin
      rollback transaction
      return 1
    end
    execute(
      ' insert into CASHCLTDTLPOOL (NUM, POSNO, LINE, CURRENCY, AMOUNT, REALAMOUNT) ' +
      ' select Num, ''' + @posno + ''', Line, Currency, PayAmt, RealAmt ' +
         ' from ' + @buypool + '..CheckInDtl_' + @posno +' m where not exists (select 1 from CASHCLTDTLPOOL c where c.num=m.num and c.posno='+''''+  @posno  +''''+') ' )
    if @@error <> 0 begin
      rollback transaction
      return 1
    end

    set @sql=' delete a from ' + @buypool + '..CheckIn_' + @posno + ' a where  exists (select 1 from CASHCLTPOOL b where a.num=b.num and posno='''
      +rtrim(@posno)+'''' +') ' +
      ' delete a from ' + @buypool + '..CheckInDtl_' + @posno + ' a where  exists (select 1 from CASHCLTPOOL b where a.num=b.num and posno='''
      +rtrim(@posno)+'''' +')'
    execute(@sql)
    if @@error <> 0 begin
      rollback transaction
      return 1
    end
    commit transaction
  end

  if @existsbuy is not null begin
    execute(
    'declare c_rtl cursor for ' +
    '  select min(FLOWNO) ' +
    '  from ' + @buypool + '..BUY1_' + @posno +
    ' where POSNO = ''' + @posno + ''' and TAG = 0')
    open c_rtl
    fetch next from c_rtl into @flowno
    if @flowno is not null select @processed = 1
    close c_rtl
    deallocate c_rtl
  end else begin
    select @processed = 0
  end

  /* processing buyXX record */
  if @processed = 1 begin
    begin transaction
    /* copy from buypool to database */
    execute (
    ' insert into BUY1(FLOWNO, POSNO, SETTLENO, FILDATE, CASHIER, ' +
    ' TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, WRH, ASSISTANT, INVNO, SCORE, CardCode, DEALER, FLAG, SCOREINFO) ' +
    ' select FLOWNO, POSNO, ' + @txtsettleno + ', FILDATE, ' +
    ' CASHIER, TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, WRH, ASSISTANT, INVNO ' +
    /* 2000-12-8 */ ', SCORE ' +
    /*2001-09-21 by hxs */',CardCode, DEALER' +
    /*2005-11-22 zengyun 任务单5596*/', ISNULL(FLAG,0), SCOREINFO' +
    ' from ' + @buypool + '..BUY1_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''' )
    if @@error <> 0 begin
      /* 99-12-21: delete buyx with log if duplicate */
      /* 是否重复? 如果是,则删除 */
      execute('declare c_rtl cursor for select fildate from ' + @buypool + '..BUY1_' + @posno +
              ' where POSNO = ''' + @posno + '''' + ' and FLOWNO = ''' + @flowno + '''' )
      open c_rtl
      fetch next from c_rtl into @fildate
      close c_rtl
      deallocate c_rtl
      if exists (select 1 from buy1(nolock) where flowno = @flowno and posno = @posno and fildate = @fildate)
      begin
        /* delete from buypool */
        execute(' delete from ' + @buypool + '..BUY1_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
        if @@error <> 0 begin
          rollback transaction
          execute RTLERROR @buypool, @posno, @flowno, 19, '删除BUY1错误'
          return 1
        end
        execute(' delete from ' + @buypool + '..BUY11_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
        if @@error <> 0 begin
          rollback transaction
          execute RTLERROR @buypool, @posno, @flowno, 20, '删除BUY11错误'
          return 1
        end
        execute(' delete from ' + @buypool + '..BUY2_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
        if @@error <> 0 begin
          rollback transaction
          execute RTLERROR @buypool, @posno, @flowno, 21, '删除BUY2错误'
          return 1
        end
        execute(' delete from ' + @buypool + '..BUY21_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
        if @@error <> 0 begin
          rollback transaction
          execute RTLERROR @buypool, @posno, @flowno, 22, '删除BUY21错误'
          return 1
        end
        insert into log(TIME, MONTHSETTLENO, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values(getdate(), @settleno, '零售加工', '服务器', '零售加工', 303, '删除重复的零售数据' + rtrim(@posno) + ' ' + rtrim(@flowno) + ' ' + rtrim(convert(char,@fildate,109)))
        commit transaction
        return 1
      end else
      begin
        rollback transaction
        execute RTLERROR @buypool, @posno, @flowno, 11, 'COPY BUY1'
        return 1
      end
    end
 /* 99-9-17: 增加字段CARDCODE CHAR(128) */
    execute (
    /*2006-10-27 zengyun 任务单8075，增加字段FAVTYPE, FAVAMT, PARVALUE*/
    ' insert into BUY11 (FLOWNO, POSNO, ITEMNO, SETTLENO, CURRENCY, AMOUNT, CARDCODE, FAVTYPE, FAVAMT, PARVALUE' +
    /*2006-12-27 zengyun 任务单8675*/
    ', CURRENCYTYPE, ORIGINALAMT, PARITIES' +
    ' ) ' +
    ' select FLOWNO, POSNO, ITEMNO, ' + @txtsettleno + ', CURRENCY, AMOUNT, CARDCODE, FAVTYPE, isnull(FAVAMT,0), isnull(PARVALUE,0) ' +
    /*2006-12-27 zengyun 任务单8675*/
    ', CURRENCYTYPE, ORIGINALAMT, PARITIES' +
    ' from ' + @buypool + '..BUY11_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''')
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 12, 'COPY BUY11'
      return 1
    end
    execute(
    ' insert into BUY2 (FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, ' +
    ' PRICE, REALAMT, FAVAMT, QPCGID, PRMTAG, INVNO, ASSISTANT, WRH, DEALER, IQTY, GDCODE, SCORE, SCOREINFO) ' + --Fanduoyi 2006-02-07
    ' select FLOWNO, POSNO, ITEMNO, ' + @txtsettleno + ', GID, QTY, INPRC, ' +
    ' PRICE, REALAMT, FAVAMT, QPCGID, PRMTAG, INVNO, ASSISTANT, WRH, DEALER, IQTY, GDCODE, SCORE, SCOREINFO ' +
    ' from ' + @buypool + '..BUY2_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''')
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 13, 'COPY BUY2'
      return 1
    end
    execute(
    ' insert into BUY21 (FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT) ' +
    ' select FLOWNO, POSNO, ITEMNO, FAVTYPE, ' + @txtsettleno + ', FAVAMT '+
    ' from ' + @buypool + '..BUY21_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''')
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 14, 'COPY BUY21'
      return 1
    end

    /* test buy1<->buy11 */
    /*2006.07.28 任务单7227: 增加对不找零付款方式的支持*/
    if
      abs((select PREVAMT from BUY1(nolock)
      where POSNO = @posno and FLOWNO = @flowno)
      -
      (select sum(CONVERT(DECIMAL(20,4),AMOUNT)) from BUY11(nolock)
      where POSNO = @posno and FLOWNO = @flowno and CURRENCY <> -1 and CURRENCY <> -2)) > 0.01
    or
      abs((select RealAmt from BUY1(nolock) where POSNO = @posno and FLOWNO = @flowno)
      -
      ((select sum(CONVERT(DECIMAL(20,4),AMOUNT)) from BUY11(nolock)
      where POSNO = @posno and FLOWNO = @flowno and CURRENCY <> -1 and CURRENCY <> -2)
      -
      (select isnull(sum(CONVERT(DECIMAL(20,4),AMOUNT)),0) from BUY11(nolock)
      where POSNO = @posno and FLOWNO = @flowno and CURRENCY in (-1, -2)))) > 0.01
    or
      not exists (select 1 from BUY11(nolock) where POSNO = @posno and FLOWNO = @flowno)
    begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 15, 'BUY1和BUY11不平'
      return 1
    end

    /* test buy1<->buy2 */
    /* 99-7-27: */
    select @buy1_total = TOTAL
      from BUY1(nolock) where POSNO = @posno and FLOWNO = @flowno
    select @buy2_total = sum(QTY * PRICE)
      from BUY2(nolock) where POSNO = @posno and FLOWNO = @flowno
    if abs(@buy1_total - @buy2_total) <= 0.01
      update BUY1 set TOTAL = @buy2_total
      where POSNO = @posno and FLOWNO = @flowno
    else
    begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 16, 'BUY1和BUY2不平(TOTAL)'
      return 1
    end

    if abs(
    (select REALAMT from BUY1(nolock) where POSNO = @posno and FLOWNO = @flowno)
    -
    (select sum(CONVERT(DECIMAL(20,4),REALAMT))
    from BUY2(nolock) where POSNO = @posno and FLOWNO = @flowno)) > 0.001
    or
    not exists (select 1 from BUY2(nolock) where POSNO = @posno and FLOWNO = @flowno)
    begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 17, 'BUY1和BUY2不平'
      return 1
    end
    /* test buy2<->buy21 */
    /*
    declare c_temp cursor for
      select BUY2.ITEMNO, BUY2.FAVAMT, SUM(CONVERT(DECIMAL(20,4),BUY21.FAVAMT))
      from BUY2(nolock), BUY21(nolock)
      where BUY2.POSNO = @posno and BUY2.FLOWNO = @flowno
      and BUY21.POSNO = @posno and BUY21.FLOWNO = @flowno
      and BUY2.ITEMNO = BUY21.ITEMNO
      group by BUY2.ITEMNO, BUY2.FAVAMT
      having BUY2.FAVAMT <> SUM(CONVERT(DECIMAL(20,4),BUY21.FAVAMT))
    open c_temp
    fetch next from c_temp into @temp1, @temp2, @temp3
    close c_temp
    deallocate c_temp
    if @@fetch_status = 0
    */
    /* 99-6-11 */
    if exists (
      select 1
      from BUY2(nolock), BUY21(nolock)
      where BUY2.POSNO = @posno and BUY2.FLOWNO = @flowno
      and BUY21.POSNO = @posno and BUY21.FLOWNO = @flowno
      and BUY2.ITEMNO = BUY21.ITEMNO
      group by BUY2.ITEMNO, BUY2.FAVAMT
      having abs(BUY2.FAVAMT - SUM(CONVERT(DECIMAL(20,4),BUY21.FAVAMT))) > 0.01
    )
    begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 18, 'BUY2和BUY21不平'
      return 1
    end

    /* delete from buypool */
    execute(
    ' delete from ' + @buypool + '..BUY1_' + @posno +
    ' where FLOWNO = ''' + @flowno + '''' +
    ' and POSNO = ''' + @posno + ''''
    )
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 19, '删除BUY1错误'
      return 1
    end
    execute(
    ' delete from ' + @buypool + '..BUY11_' + @posno +
    ' where FLOWNO = ''' + @flowno + '''' +
    ' and POSNO = ''' + @posno + ''''
    )
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 20, '删除BUY11错误'
      return 1
    end
    execute(
    ' delete from ' + @buypool + '..BUY2_' + @posno +
    ' where FLOWNO = ''' + @flowno + '''' +
    ' and POSNO = ''' + @posno + ''''
    )
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 21, '删除BUY2错误'
      return 1
    end
    execute(
    ' delete from ' + @buypool + '..BUY21_' + @posno +
    ' where FLOWNO = ''' + @flowno + '''' +
    ' and POSNO = ''' + @posno + ''''
    )
    if @@error <> 0 begin
      rollback transaction
      execute RTLERROR @buypool, @posno, @flowno, 22, '删除BUY21错误'
      return 1
    end

    /* processing */
    select
      @fildate = convert(datetime, convert(char,FILDATE,102)),
      --sunya 2007.4.19 解决联销率促销单时间参数的取值问题
      @curtime = FILDATE,
      @wrh1 = WRH,
      @slrgid = ASSISTANT,
      @guest = GUEST,
      @invnum = INVNO,
      @realamt = REALAMT,
      @reccnt = RECCNT,
      @filler = CASHIER,
      @opener = ASSISTANT,
      @score = SCORE, --积分计算 2001-02-26
      @cardcode = CARDCODE --卡号计算 2004-01-06
      /*2005-11-22 zengyun 任务单5596*/,@flag = FLAG
      from BUY1(nolock) where POSNO = @posno and FLOWNO = @flowno
    if @guest = -1
    begin --卡号计算 2004-01-06
      if @cardcode is null or @cardcode = ''  --2006-04.24 任务单6586
        select @guest = 1
      else
      begin
        select @guest = (select CSTGID from CARD(nolock) where code = @cardcode)
        update buy1 set guest = @guest where POSNO = @posno and FLOWNO = @flowno
      end
    end

    /* sz ADD 报表重发判断逻辑 */
    IF convert(datetime, convert(CHAR, @fildate, 102)) <> convert(datetime, convert(CHAR, getdate(), 102))
      EXEC RTLADDRESEND @fildate

    /* 99-12-24 -dsp- */
    declare @dsp_wrh int, @dsp_invnum char(10), @dsp_opener int,
            @dsp_realamt money, @dsp_reccnt money, @dsp_firstbuy2 smallint
    if (select dsp from system) & 8 <> 0
      select @dsp_wrh = @wrh1, @dsp_invnum = @invnum, @dsp_opener = @opener,
             @dsp_realamt = 0, @dsp_reccnt = 0, @dsp_firstbuy2 = 1

    /* 99-6-1: 如果不是赊购卡,不记客户报表(EXS_INS中BCSTGID=1),记消费卡表
      否则,使用该卡对应的客户号记客户报表,同时记消费卡表 */
    /* select @cstgid = isnull( (select cstgid from card where gid = @guest), 1 ) */
    /* 99-11-29: 查询记帐级别和赊购形成PARAM调用EXS_INS */
    select @cstgid = (select cstgid from card(nolock) where gid = @guest)
    if @cstgid is null
    begin
      select @cstgid = 1, @detaillevel = 0, @credit = 0
    end else
    begin
      select @credit = null, @detaillevel = null
      select @credit = credit, @detaillevel = detaillevel from client where gid = @cstgid
      if @detaillevel is null select @detaillevel = 0
      if @credit is null select @credit = 0
    end
    select @param = @detaillevel * 10 + @credit
    if (@param in (1,11)) and (@cstgid = 1)
    begin
      rollback transaction
     execute RTLERROR @buypool, @posno, @flowno, 31, '未知客户不能赊购'
      return 1
    end

    select @store = usergid from system(nolock);

    ----增加记录积分金额明细  by jzhu20101215
    exec zhps_calcbuyscoredtl @posno, @flowno

    if @slrgid is null select @slrgid = 1
    select @amt = 0, @total_favamt = 0, @total_gdcnt = 0
    declare c_buy2 cursor for
      select ITEMNO, GID, QTY, INPRC, PRICE, REALAMT, FAVAMT,
             /* 99-12-24 */ ASSISTANT, WRH, INVNO
      from BUY2(nolock)
      where POSNO = @posno and FLOWNO = @flowno
      order by INVNO, ASSISTANT, WRH
      for update
    open c_buy2
    fetch next from c_buy2 into
      @itemno, @gdgid, @qty, @inprc, @rtlprc, @realamt, @favamt,
      /* 99-12-24 */ @opener, @wrh2, @invnum
    while @@fetch_status = 0 begin
      /* 99-12-24 */
      if @wrh2 is null or @wrh2 in (0,1) select @wrh2 = @wrh1

      select @sale = null
      select @sale = SALE,
        @g_inprc = INPRC, @g_rtlprc = RTLPRC, @g_payrate = PAYRATE
        from GOODS(nolock) where GID = @gdgid

      /* 99-8-31 */
      if @sale is null
      begin
        rollback transaction
        select @msg = '第' + rtrim(convert(char,@itemno)) +
                      '行的商品不存在(GID=' +
                      rtrim(convert(char,@gdgid)) + ')'
        execute RTLERROR @buypool, @posno, @flowno, 23, @msg
        select @processed = 0
        goto endloop
      end

      ---单独区分1503优惠  add by jzhu 20101012
      declare  @favamt_1503 money

      select @favamt_1503 = isnull(sum(FAVAMT),0) from BUY21
        where POSNO = @posno and FLOWNO = @flowno
         and ITEMNO = @itemno and FAVTYPE = '1503' --2009.10.30, ShenMin

      --判断是否是联网退货
      select @OriPosNo = null, @OriFlowNo = null, @OriItemNo = null, @OriInPrc = null, @OriCost = null;
      select @OriPosNo = ORIPOSNO, @OriFlowNo = ORIFLOWNO, @OriItemNo = ORIITEMNO
      from BuyRtnControl(nolock)
      where BCKPOSNO = @posno   and STAT=1
        and BCKFLOWNO = @flowno
        and BCKITEMNO = @itemno;

      --如果是联网退货，取原单信息
      if @OriPosNo is not null
      begin
        select @OriInPrc = INPRC, @OriCost = COST,@wrh2 = wrh
        from BUY2(nolock)
        where FLOWNO = @OriFlowNo
          and POSNO = @OriPosNo
          and ITEMNO = @OriItemNo;
      end
      else
      begin
        /* 99-7-27 */
        if @sale = 3
        begin
          ----振华定制:返券优惠金额也参与成本计算. WUDIPING 20090831
          ----将积分卡优惠始终参于成本计算 by jzhu 20100616
          declare @favamt_2405 money ,@realamtbase money,@favamt_1515 money

          set @realamtbase=@realamt

          select @favamt_2405 = isnull(sum(FAVAMT),0) from BUY21
           where POSNO = @posno and FLOWNO = @flowno
             and ITEMNO = @itemno and (FAVTYPE = '2405' or FAVTYPE like '15%') --2009.10.30, ShenMin

          select @favamt_1515 = isnull(sum(FAVAMT),0) from BUY21
            where POSNO = @posno and FLOWNO = @flowno
              and ITEMNO = @itemno and (FAVTYPE = '1515')

          if @option_FAVADDVDR = 2
            set @realamtbase=@realamtbase+@favamt_2405
          else
          if @option_FAVADDVDR = 3
            set @realamtbase=@realamtbase+@favamt_2405-@favamt_1515
          else
            set @realamtbase=@realamtbase+@favamt_1503


       --交易折扣,用以计算折扣联销率
          IF @RTLPRC<>0  --考虑零售价为0的情况 add by jzhu20101018
            SELECT @WSDISCOUNT = ROUND(@realamtbase * 100/ (@qty * @rtlprc), 2)  ---考虑券优惠以及退货的情况
          ELSE
            SELECT @WSDISCOUNT=0

        --2006.6.23, ShenMin, Q6923, 取促销联销率
          execute @return_status = GetGoodsPrmPayRate @store, @gdgid, @curtime, '1*1', @WSDISCOUNT, @g_payrate output, @poMsg output

          if @favamt_2405 is not null and @favamt_2405 <> 0 and @option_FAVADDVDR = 2
            select @RealCost = (@realamt + @favamt_2405) * @g_payrate / 100
          else   if @favamt_2405 is not null and @favamt_2405 <> 0 and @option_FAVADDVDR = 3
            select @RealCost = (@realamt + @favamt_2405-@favamt_1515) * @g_payrate / 100
          else
            select @RealCost = (@realamt + @favamt_1503) * @g_payrate / 100

          select @inprc = @RealCost/@qty
          ----定制结束
        end
        else
          select @inprc=@g_inprc
      end

      /* 库存 */
      if @wrh2 is null or @wrh2 = 1
        select @wrh = WRH from GOODS(nolock) where GID = @gdgid
      else
        select @wrh = @wrh2

      /* 库存价 */
      --2002-06-13
      if @sale <> 0 and @OriPosNo is null
      begin
        if @sale = 1
        begin
          select @inprc = @g_inprc
        end
        select @temp = @qty * @inprc
        execute UPDINVPRC '零售', @gdgid, @qty, @temp, @wrh, @outcost output /*2002.08.18*/
        if @sale = 1  --2004-08-12
            select @RealCost = @outcost;
        else if @sale=2
            select @RealCost = @temp;
        else
            select @RealCost = @RealCost;
      end


      if @OriInPrc is not null
      begin
        select @inprc = @OriInPrc;
        select @temp = -1*@OriCost;
        if @sale=1
           begin
           execute UPDINVPRC '零售', @gdgid, @qty, @temp, @wrh, @outcost output
           select @RealCost = @outcost
           end
        else
          select @RealCost = @temp
      end;

      if @RealCost<0 and @qty>0
      insert into zht_chkposproc(posno,flowno,oriposno,oriflowno,cost,realamt,payrate,oricost)
      select @posno,@flowno,@OriPosNo,@OriFlowNo,@RealCost,@realamt,@g_payrate,@OriInPrc

      update BUY2
        set INPRC = @inprc, COST = @RealCost
      where POSNO = @posno and FLOWNO = @flowno and ITEMNO = @itemno;

      if @qty > 0 begin
          select @temp2 = @qty
          execute @return_status = UNLOAD @wrh, @gdgid, @temp2, @g_rtlprc, null
      end else begin
          select @temp2 = -@qty
          execute @return_status = LOADIN @wrh, @gdgid, @temp2, @g_rtlprc, null
      end
      if @return_status <> 0 begin
          rollback transaction
          select @msg = ' 不允许负库存或实行到效期管理的仓位库存不足:' +
            rtrim(convert(char,@wrh)) + ';' +
            rtrim(convert(char,@gdgid)) + ';' +
            ltrim(convert(char, @qty)) + ';' +
            ltrim(convert(char,@rtlprc))
          execute RTLERROR @buypool, @posno, @flowno, 24, @msg
          select @processed = 0
          break
      end

      /* 销售报表 */
      select @vdrgid = BILLTO from GOODSH(nolock) where GID = @gdgid

      if @realamt > 0 begin
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
        BVDRGID, BCSTGID,
        LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
        values (@settleno, @fildate, @wrh, @gdgid, @posno, 1, @vdrgid, @cstgid,
        @qty, @realamt, 0, @RealCost, @qty * @rtlprc, @param)
      end else if @realamt < 0 begin
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
        BVDRGID, BCSTGID,
        LST_Q, LST_A, LST_T, LST_I, LST_R, PARAM)
        values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
        @vdrgid, @cstgid,
        -@qty, -@realamt, 0, -@RealCost, -@qty * @rtlprc, @param)
      end else begin
        insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
        BVDRGID, BCSTGID,
        LS_Q, LS_A, LS_T, LS_I, LS_R, PARAM)
        values (@settleno, @fildate, @wrh, @gdgid, @posno, 1,
        @vdrgid, @cstgid,
        @qty, @realamt, 0, @RealCost, @qty * @rtlprc, @param)
      end


      if @@error <> 0 begin
        rollback transaction
        select @msg = 'XS:' +
          rtrim(convert(char,@settleno)) + ';' +
          rtrim(convert(char,@fildate,2)) + ';' +
          rtrim(convert(char,@wrh)) + ';' +
          rtrim(convert(char,@gdgid)) + ';' +
          rtrim(convert(char, @posno)) + ';' +
          rtrim(convert(char,@slrgid)) + ';' +
          rtrim(convert(char,@vdrgid)) + ';' +
          rtrim(convert(char,@guest)) + ';' +
          rtrim(convert(char,@qty)) + ';' +
          rtrim(convert(char,@realamt)) + ';' +
          rtrim(convert(char,0)) + ';' +
          rtrim(convert(char,@qty * @inprc)) + ';' +
          rtrim(convert(char,@qty * @rtlprc))
        execute RTLERROR @buypool, @posno, @flowno, 25, @msg
        select @processed = 0
        break
      end
      /* 优惠报表 */

      /* 2000-4-11 */
      select @favamt_saved = @favamt

      /*add by jzhu 解决因高敲导致的出货日报优惠错误*/
      declare @fav_count int

      if @favamt <> 0 begin
        /* LS1: 后台优惠 */
        select @favamt = isnull(sum(FAVAMT),0), @fav_count = isnull(count(1),0) from BUY21(nolock)
          where POSNO = @posno and FLOWNO = @flowno
          and ITEMNO = @itemno and FAVTYPE in ('00', '01','03','04','05','07','08', '11', '19', '20', '21', '25')   --Add By Wang xin 2002-05-06  --2002-07-19
          /* 99-12-6: +'00' */
        if @favamt is not null and @fav_count is not null and @fav_count <> 0
        begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
            BVDRGID, BCSTGID,
            LS1_Q, LS1_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
            @vdrgid,  @cstgid,
            @qty, @favamt, @param)
          if @@error <> 0
          begin
            rollback transaction
            select @msg = 'XS:LS1:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char, @posno)) + ';' +
              rtrim(convert(char,@slrgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@guest)) + ';' +
              rtrim(convert(char,@qty)) + ';' +
              rtrim(convert(char,@favamt))
            execute RTLERROR @buypool, @posno, @flowno, 26, @msg
            select @processed = 0
            break
          end
        end
          /* LS2：前台优惠 */
        select @favamt = isnull(sum(FAVAMT),0), @fav_count = isnull(count(1),0) from BUY21(nolock)
          where POSNO = @posno and FLOWNO = @flowno
            and ITEMNO = @itemno and (FAVTYPE in ('09','10','12','13')
            or FAVTYPE like '16__' or FAVTYPE like '24%' or FAVTYPE like '15%')
        if @favamt is not null and @fav_count is not null and @fav_count <> 0
        begin  --and @favamt <> 0 del by jzhu 20100616
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
            BVDRGID, BCSTGID,LS2_Q, LS2_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
            @vdrgid, @cstgid,
            @qty, @favamt, @PARAM)
          if @@error <> 0 begin
            rollback transaction
            select @msg = 'XS:LS2:' +
                rtrim(convert(char,@settleno)) + ';' +
                rtrim(convert(char,@fildate,2)) + ';' +
                rtrim(convert(char,@wrh)) + ';' +
                rtrim(convert(char,@gdgid)) + ';' +
                rtrim(convert(char, @posno)) + ';' +
                rtrim(convert(char,@slrgid)) + ';' +
                rtrim(convert(char,@vdrgid)) + ';' +
                rtrim(convert(char,@guest)) + ';' +
                rtrim(convert(char,@qty)) + ';' +
                rtrim(convert(char,@favamt))
            execute RTLERROR @buypool, @posno, @flowno, 27, @msg
            select @processed = 0
            break
          end

          declare @favamt_24 money, @FAVTYPE_24 varchar(4)
          select @favamt_24 = isnull(sum(FAVAMT),0), @FAVTYPE_24 = max(FAVTYPE) from BUY21
            where POSNO = @posno and FLOWNO = @flowno
              and ITEMNO = @itemno and (FAVTYPE like '24%'  or favtype='1505')

          if @favamt_24 is not null and @favamt_24 <> 0
          begin
            declare @_usergid int, @_zbgid int
            select @_usergid = usergid, @_zbgid = zbgid from system(nolock)
            if @option_ISZBPAY = 0
            begin
              --供应商
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @vdrgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_24, 1, @favamt_24, 1, @cstgid)
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_24, 0, @favamt_24, 0, @cstgid)
              --门店
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_usergid, @_usergid, @fildate, @settleno,
                @FAVTYPE_24, 0, @favamt_24, 0, @cstgid)
            end else if @option_ISZBPAY = 1
            begin
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_24, 0, @favamt_24, 0, @cstgid)
            end
            if @@error <> 0
            begin
                rollback transaction
                select @msg = 'FV:' +
                rtrim(convert(char,@settleno)) + ';' +
                rtrim(convert(char,@fildate,2)) + ';' +
                rtrim(convert(char,@wrh)) + ';' +
                rtrim(convert(char,@gdgid)) + ';' +
                rtrim(convert(char,@vdrgid)) + ';' +
                rtrim(convert(char,@_zbgid)) + ';' +
                rtrim(convert(char,@_usergid)) + ';' +
                rtrim(convert(char,@FAVTYPE_24)) + ';' +
                rtrim(convert(char,@favamt_24))
                execute RTLERROR @buypool, @posno, @flowno, 32, @msg
                select @processed = 0
                break
            end
          end

          declare @favamt_15 money, @FAVTYPE_15 varchar(4)
          select @favamt_15 = isnull(sum(FAVAMT),0), @FAVTYPE_15 = max(FAVTYPE) from BUY21(nolock)
          where POSNO = @posno and FLOWNO = @flowno
            and ITEMNO = @itemno and FAVTYPE ='1515'

          if @favamt_15 is not null and @favamt_15 <> 0
          begin
            --declare @_usergid int, @_zbgid int
            select @_usergid = usergid, @_zbgid = zbgid from system(nolock)
            if @option_ISZBPAY = 0
            begin
              --供应商
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @vdrgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_15, 1, @favamt_15, 1, @cstgid)
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_15, 0, @favamt_15, 0, @cstgid)
              --门店
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_usergid, @_usergid, @fildate, @settleno,
                @FAVTYPE_15, 0, @favamt_15, 0, @cstgid)
            end else if @option_ISZBPAY = 1
            begin
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_15, 0, @favamt_15, 0, @cstgid)
            end
            if @@error <> 0
            begin
              rollback transaction
              select @msg = 'FV:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@_zbgid)) + ';' +
              rtrim(convert(char,@_usergid)) + ';' +
              rtrim(convert(char,@FAVTYPE_15)) + ';' +
              rtrim(convert(char,@favamt_15))
              execute RTLERROR @buypool, @posno, @flowno, 32, @msg
              select @processed = 0
              break
            end
          end

          declare @favamt_1522 money, @FAVTYPE_1522 varchar(4)
          select @favamt_1522 = isnull(sum(FAVAMT),0), @FAVTYPE_1522 = max(FAVTYPE) from BUY21(nolock)
            where POSNO = @posno and FLOWNO = @flowno
              and ITEMNO = @itemno and FAVTYPE ='1522'

          if @favamt_1522 is not null and @favamt_1522 <> 0
          begin
            --declare @_usergid int, @_zbgid int
            select @_usergid = usergid, @_zbgid = zbgid from system(nolock)
            if @option_ISZBPAY = 0
            begin
              --供应商
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @vdrgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_1522, 1, @favamt_1522, 1, @cstgid)
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_1522, 0, @favamt_1522, 0, @cstgid)
              --门店
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_usergid, @_usergid, @fildate, @settleno,
                @FAVTYPE_1522, 0, @favamt_1522, 0, @cstgid)
            end else if @option_ISZBPAY = 1
            begin
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                @FAVTYPE_1522, 0, @favamt_1522, 0, @cstgid)
            end
            if @@error <> 0
            begin
              rollback transaction
              select @msg = 'FV:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@_zbgid)) + ';' +
              rtrim(convert(char,@_usergid)) + ';' +
              rtrim(convert(char,@FAVTYPE_1522)) + ';' +
              rtrim(convert(char,@favamt_1522))
              execute RTLERROR @buypool, @posno, @flowno, 32, @msg
              select @processed = 0
              break
            end
          end

          /*1503单独计算*/
          if @favamt_1503 is not null and @favamt_1503 <> 0
          begin
            --declare @_usergid int, @_zbgid int
            select @_usergid = usergid, @_zbgid = zbgid from system(nolock)
            if @option_ISZBPAY = 0
            begin
                --供应商
                insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                  FV_P, FV_L, FV_A, MODE, BCSTGID)
                values (@wrh, @gdgid, @vdrgid, @_usergid, @fildate, @settleno,
                  '1503', 1, @favamt_1503, 1, @cstgid)
                --总部
                insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                  FV_P, FV_L, FV_A, MODE, BCSTGID)
                values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                  '1503', 0, @favamt_1503, 0, @cstgid)
                --门店
                insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                  FV_P, FV_L, FV_A, MODE, BCSTGID)
                values (@wrh, @gdgid, @_usergid, @_usergid, @fildate, @settleno,
                  '1503', 0, @favamt_1503, 0, @cstgid)
            end else if @option_ISZBPAY = 1
            begin
              --总部
              insert into FV(BWRH, BGDGID, BVDRGID, ASTORE, ADATE, ASETTLENO,
                FV_P, FV_L, FV_A, MODE, BCSTGID)
              values (@wrh, @gdgid, @_zbgid, @_usergid, @fildate, @settleno,
                '1503', 0, @favamt_1503, 0, @cstgid)
            end
            if @@error <> 0
            begin
              rollback transaction
              select @msg = 'FV:' +
              rtrim(convert(char,@settleno)) + ';' +
              rtrim(convert(char,@fildate,2)) + ';' +
              rtrim(convert(char,@wrh)) + ';' +
              rtrim(convert(char,@gdgid)) + ';' +
              rtrim(convert(char,@vdrgid)) + ';' +
              rtrim(convert(char,@_zbgid)) + ';' +
              rtrim(convert(char,@_usergid)) + ';' +
              rtrim(convert(char,@FAVTYPE_15)) + ';' +
              rtrim(convert(char,@favamt_1503))
              execute RTLERROR @buypool, @posno, @flowno, 32, @msg
              select @processed = 0
              break
            end
          end

          /*end*/
        end


        /* LS3: 付款方式优惠 */
        select @favamt = isnull(sum(FAVAMT),0) from BUY21(nolock)
          where POSNO = @posno and FLOWNO = @flowno and ITEMNO = @itemno
          and (FAVTYPE in ('14', '17'))    --del by jzhu FAVTYPE like '15__' or  20100619
        if @favamt is not null and @favamt <> 0 begin
          insert into XS (ASETTLENO, ADATE, BWRH, BGDGID, BPOSNO, BSLRGID,
            BVDRGID, BCSTGID,
            LS3_Q, LS3_A, PARAM)
          values (@settleno, @fildate, @wrh, @gdgid, @posno, @slrgid,
            @vdrgid, @cstgid,
            @qty, @favamt, @PARAM)
          if @@error <> 0 begin
              rollback transaction
              select @msg = 'XS:LS3:' +
                rtrim(convert(char,@settleno)) + ';' +
                rtrim(convert(char,@fildate,2)) + ';' +
                rtrim(convert(char,@wrh)) + ';' +
                rtrim(convert(char,@gdgid)) + ';' +
                rtrim(convert(char, @posno)) + ';' +
                rtrim(convert(char,@slrgid)) + ';' +
                rtrim(convert(char,@vdrgid)) + ';' +
                rtrim(convert(char,@guest)) + ';' +
                rtrim(convert(char,@qty)) + ';' +
                rtrim(convert(char,@favamt))
              execute RTLERROR @buypool, @posno, @flowno, 28, @msg
              select @processed = 0
              break
            end
          end
        end
        /* 调价差异 */
        if @g_rtlprc <> @rtlprc begin
          insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_R )
          values (@fildate, @settleno, @wrh, @gdgid, @qty, @qty*(@rtlprc-@g_rtlprc))
          if @@error <> 0 begin
            rollback transaction
            execute RTLERROR @buypool, @posno, @flowno, 29, '零售核算售价调价差异'
            select @processed = 0
            break
          end
        end
        /* 2000-4-14 由于@inprc总是用g_inprc来更新,所以这一段代码不会被执行 NO! */
        /* 2002-06-13 移动加权平均情况下这里不应出现进价的调价差异额。
           2003-06-13 V2算法下，代销商品仍然应该计算进价的调价差异*/
        if @g_inprc <> @inprc begin
          insert into KC ( ADATE, ASETTLENO, BWRH, BGDGID, TJ_Q, TJ_I )
          values (@fildate, @settleno, @wrh, @gdgid, @qty, @qty*(@inprc-@g_inprc))
          if @@error <> 0 begin
            rollback transaction
            execute RTLERROR @buypool, @posno, @flowno, 30, '零售核算价调价差异'
            select @processed = 0
            break
          end
        end
        /* 99-6-11: 生成提单明细 */
        /*
        if (select dsp from system) = 1
        begin
          insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
            SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE )
          values ( @dsp_num, @itemno, @itemno, @gdgid, @realamt / @qty, @qty,
            @realamt, 0, 0, 0, null )
          execute IncDspQty @wrh, @gdgid, @qty
        end
        */
        /* 99-12-24 -dsp- */
        if (select dsp from system) & 8 <> 0
        begin
          if ((@wrh is not null and @wrh <> @dsp_wrh)
          or (@invnum is not null and @invnum <> @dsp_invnum)
          or (@opener is not null and @opener <> @dsp_opener)
          or @dsp_firstbuy2 = 1)
          begin
            if @dsp_reccnt <> 0
              /* then end current dsp: update dsp set total and reccnt */
              update dsp set total = @dsp_realamt, reccnt = @dsp_reccnt
              where num = @dsp_num
            /* reset control var */
            select @dsp_wrh =isnull(@wrh, @dsp_wrh),
                @dsp_invnum = isnull(@invnum, @dsp_invnum),
                @dsp_opener = isnull(@opener, @dsp_opener),
                @dsp_realamt = 0, @dsp_reccnt = 0
            /* begin new dsp: get @dsp_num, insert into dsp */
            select @dsp_num = null
            select @max_dsp_num = max(num) from dsp(nolock)
            if @max_dsp_num is null select @dsp_num = '0000000001'
            else execute nextbn @max_dsp_num, @dsp_num output
            insert into DSP (
              NUM, WRH, INVNUM, CREATETIME, TOTAL, RECCNT, FILLER, OPENER,
              LSTDSPTIME, LSTDSPEMP, CLS, POSNOCLS, FLOWNO, NOTE, SETTLENO )
            values (@dsp_num, @dsp_wrh, /*2000-2-28 @invnum*/@dsp_invnum,
              getdate(), @dsp_realamt, @dsp_reccnt, @filler, @dsp_opener,
              null, null, 'BUY1', @posno, @flowno, null, @settleno )
            select @dsp_firstbuy2 = 0
          end
          /* insert into dspdtl */
          insert into DSPDTL ( NUM, LINE, SALELINE, GDGID, SALEPRICE, SALEQTY,
            SALETOTAL, DSPQTY, BCKQTY, LSTDSPQTY, NOTE )
          values ( @dsp_num, @itemno, @itemno, @gdgid, @realamt / @qty, @qty,
            @realamt, 0, 0, 0, null )
          execute IncDspQty @wrh, @gdgid, @qty
          /* update @dsp_recnt, @dsp_realamt */
          select @dsp_reccnt = @dsp_reccnt + 1, @dsp_realamt = @dsp_realamt + @realamt
        end

        select
          @amt = @amt + @realamt,
          @total_favamt = @total_favamt + /*2000-4-11 @favamt*/ @favamt_saved,
          @total_gdcnt = @total_gdcnt + @qty

        fetch next from c_buy2 into
          @itemno, @gdgid, @qty, @inprc, @rtlprc, @realamt, @favamt,
          /* 99-12-24 */ @opener, @wrh2, @invnum
      end
  endloop:
      close c_buy2
      deallocate c_buy2

      /* 2000-7-28
      if (select REALAMT from BUY1(nolock) where POSNO = @posno and FLOWNO = @flowno) > 0
        insert into ICCARDHST( ACTION, FILDATE, STORE, CARDNUM, OLDBAL,
          OCCUR, OPER, NOTE)
          select '消费', m.FILDATE, (select USERGID from SYSTEM), d.CARDCODE, null,
          d.AMOUNT, m.CASHIER, null
          from BUY1 m(nolock) inner join BUY11 d(nolock) on m.POSNO = d.POSNO and m.FLOWNO = d.FLOWNO
          where m.POSNO = @posno and m.FLOWNO = @flowno
        and d.CARDCODE is not null and d.CARDCODE <> '' */

      /* 99-12-24 -dsp- */
      if (select dsp from system) & 8 <> 0
      begin
        if @dsp_reccnt <> 0  /* then end current dsp */
          update dsp set total = @dsp_realamt, reccnt = @dsp_reccnt
          where num = @dsp_num
      end
      /*2003.09.05 HXS 处理家政卡的过程*/
      IF @PROCESSICCARD = '1'
      BEGIN
          --EXEC('EXEC RTLFORICCARD ' + @POSNO + ',' + @fLOWNO )
          EXEC RTLFORICCARD @POSNO, @FLOWNO --Added by wang xin 2004-05-22
      END
    --end  /*@flag in (0) 2006-02-16 zengyun 任务单6181，带特殊标记交易仍然加工日报和库存*/

    if @processed = 1 begin
      /* 消费卡统计 */
      /* 99-6-11 isnull(x,0)*/
      /* 99-12-5: CARD.统计字段移到CLIENT.统计字段 */
      if @cstgid <> 1 begin

        /* 2000-4-11
        select @amt = sum(realamt),
               @favamt = sum(favamt),
               @total_gdcnt = sum(qty)
        from buy2(nolock)
        where flowno = @flowno and posno = @posno
        */

        update CLIENT set
         LASTTIME = @fildate,
          TOTAL = TOTAL + isnull(@amt,0),
          FAVAMT = FAVAMT + isnull(@total_favamt,0),
          TLCNT = TLCNT + 1,
          TLGD = TLGD + isnull(@total_gdcnt,0)
        where GID = @cstgid
      end

      /* 消费积分统计 2001-2-26 */
      exec OutScoRpt @settleno, @fildate, @cstgid, @guest, @amt, @score
      /*2017.8.29 记录本条数据处理完成的时间*/
      update BUY1 set PROCDATE = getdate()
        where POSNO = @posno and FLOWNO = @flowno

      update WORKSTATION set
        CNT = CNT + 1,
        AMT = AMT + @amt
      where NO = @posno

      if @date = @fildate
        update WORKSTATION set
          TODAYCNT = TODAYCNT + 1,
          TODAYAMT = TODAYAMT + @amt
        where NO = @posno
       else
        insert into log ( time, employeecode, workstationno, modulename, content, type )
        values ( getdate(), '零售加工', '服务器', '零售加工',
        '非本日零售数据: 收银机号' + @posno + '流水号' + @flowno, 301 )
      exec COPYTOPREORDPOOL @posno, @flowno  --added by zengyun 2006.02.14 任务单6181
      commit transaction
    end
  end

  /* processing operating records */
  if @existscashieroperate is not null
  begin
    begin transaction
    /*Added by zengyun 2006.08.30 任务单7598*/
    declare @vMaxTime datetime,@vStrTime varchar(30)
    if object_id('cursor_temp') is not null deallocate cursor_temp
    execute('declare cursor_temp cursor for ' +
    'select max(TIME) from ' + @buypool +
    '..CASHIEROPERATE_' + @posno + '(nolock)')
    open cursor_temp
    fetch next from cursor_temp into @vMaxTime
    close cursor_temp
    deallocate cursor_temp
    select @vStrTime = '''' + convert(varchar(30), isnull(@vMaxTime, getdate()), 21) + ''''
    /*end.*/
    execute(
    ' insert into CASHIEROPERATE (CASHIERCODE, CASHIERNAME, MONTHSETTLENO, ' +
    ' OPERATE, TIME, POSNO, MEMO) ' +
    ' select CASHIERCODE, CASHIERNAME, ' + @txtsettleno +
    ', OPERATE, TIME, POSNO, MEMO ' +
    ' from ' + @buypool + '..CASHIEROPERATE_' + @posno +
    --Added by zengyun 2006.08.30 任务单7598
    '(nolock) where TIME <= ' + @vStrTime)
    if @@rowcount <> 0 begin
      execute(
      ' delete from ' + @buypool + '..CASHIEROPERATE_' + @posno +
      --Added by zengyun 2006.08.30 任务单7598
      ' where TIME <= ' + @vStrTime)
      update WORKSTATION set OPCNT = OPCNT + @@rowcount where NO = @posno
      select @processed = 1
    end
    commit transaction
  end

  if @existsbuy is not null
  begin
    execute(
    ' update WORKSTATION set ' +
    ' NPCNT = (select count(*) from ' + @buypool + '..BUY1_' + @posno +') ' +
    ' where NO = ''' + @posno + '''')
  end
  if @existscashieroperate is not null
  begin
  	execute(
    ' update WORKSTATION set ' +
    ' NPOPCNT = (select count(*) from ' + @buypool + '..CASHIEROPERATE_' + @posno + '(nolock)) ' + --Modified by zengyun 2006.08.30 任务单7598
    ' where NO = ''' + @posno + '''')
  end
  /*2003.09.05 HXS 处理家政卡的过程*/
  IF @PROCESSICCARD = '1'
  BEGIN
      begin transaction
      --EXEC('EXEC POSPROCICCARDHST ' +@buypool  + ',' + @POSNO )
      EXEC POSPROCICCARDHST @buypool, @POSNO --Added by wang xin 2004-05-22
      commit transaction
  END

  /*接收预售二次消费数据*/
  IF @processed = '1'
  BEGIN
    begin transaction
    EXEC @return_status = PosProc_ProcTwiceBuy @POSNO, @flowno, @msg output
    if @return_status <> 0
    begin
      rollback transaction
      set @msg = '记录二次消费错误。' + @msg
      execute RTLERROR @buypool, @posno, @flowno, 33, @msg
      set @processed = 0
    end
    else begin
      commit transaction
    end
  END

  return(@processed)
end
GO
