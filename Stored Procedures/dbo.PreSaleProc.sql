SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PreSaleProc](
  @buypool varchar(30),
  @posno varchar(10)
)
as
begin
  declare
    @return_status smallint,
    /*@processed：过程返回值。
    0-处理数据失败，并写了错误日志；
    1-成功处理了数据，或者不需要处理数据，没有写错误日志。
    在该过程中，凡是记录了日志的，外围调用者需要等待10毫秒才能再次调用该过程。*/
    @processed smallint,
    @settleno int,
    @existsbuy int, /*asbuy表是否存在*/
    @fildate datetime,
    @presalenum char(14),
    @txtsettleno varchar(10),
    @flowno varchar(12),
    @errmsg varchar(100)

  /*传入参数处理*/
  set @buypool = isnull(@buypool, '')
  set @posno = isnull(@posno, '')

  set @buypool = ltrim(rtrim(@buypool))
  set @posno = ltrim(rtrim(@posno))

  /*公共变量*/
  set @return_status = 0
  set @processed = 0
  set @errmsg = ''
  select @settleno = max(NO) from MONTHSETTLE(nolock)
  set @txtsettleno = convert(varchar, @settleno)

  /*检查预售数据暂存库asbuy表是否存在，不存在则创建之*/
  exec @return_status = PreSaleProc_GenASBuyTables @buypool, @posno, @errmsg output
  if @return_status <> 0
  begin
    set @errmsg = 'asbuy表不存在。' + isnull(@errmsg, '')
    exec PreSaleProc_ErrLog @buypool, @posno, null, 1, @errmsg
    set @processed = 0
    return @processed
  end

  /*取得一个交易流水号*/
  set @flowno = null
  execute(
  'declare c_asrtl cursor for ' +
  '  select min(FLOWNO) ' +
  '  from ' + @buypool + '..ASBUY1_' + @posno +
  ' where POSNO = ''' + @posno + ''' and TAG = 0')
  open c_asrtl
  fetch next from c_asrtl into @flowno
  close c_asrtl
  deallocate c_asrtl
  if @flowno is null
  begin
    set @processed = 1
    return @processed
  end

  /*新预售单号，一个pos+flowno确定一个新单号*/
  exec @return_status = GenNextBillNumEx '', 'PREBUY1', @presalenum output
  if @return_status <> 0
  begin
    exec PreSaleProc_ErrLog @buypool, @posno, @flowno, 2, '取新的后台预售单号失败。'
    set @processed = 0
    return @processed
  end

  /*PREBUY1*/
  begin transaction
  execute(
  ' insert into PREBUY1(NUM, ASNUM, TSTIME, RCVTIME, SNDTIME, STAT, FLOWNO, POSNO, SETTLENO,' +
  ' FILDATE, CASHIER, WRH, ASSISTANT, TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO,' +
  ' SCORE, CARDCODE, DEALER, FLAG, PROCDATE, SCOREINFO)' +
  ' select ''' + @presalenum + ''', ASNUM, null, getdate(), null, 200, FLOWNO, POSNO, ' + @txtsettleno + ',' +
  ' FILDATE, CASHIER, WRH, ASSISTANT, TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO,' +
  ' SCORE, CARDCODE, DEALER, FLAG, null, SCOREINFO' +
  ' from ' + @buypool + '..ASBUY1_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''' )
  if @@error <> 0
  begin
    /*消费日期*/
    execute(
    ' declare c_asrtl cursor for' +
    ' select FILDATE from ' + @buypool + '..ASBUY1_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''' )
    open c_asrtl
    fetch next from c_asrtl into @fildate
    close c_asrtl
    deallocate c_asrtl

    /*错误原因之一：数据重复*/
    if exists (select 1 from PREBUY1(nolock) where FLOWNO = @flowno and POSNO = @posno and FILDATE = @fildate)
    begin
      /* delete from buypool..asbuy1_posno */
      execute(' delete from ' + @buypool + '..ASBUY1_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        rollback transaction
        exec PreSaleProc_ErrLog @buypool, @posno, @flowno, 19, '删除ASBUY1时发生错误。'
        set @processed = 0
        return @processed
      end

      /* delete from buypool..asbuy11_posno */
      execute(' delete from ' + @buypool + '..ASBUY11_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        rollback transaction
        execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 20, '删除ASBUY11时发生错误。'
        set @processed = 0
        return @processed
      end

      /* delete from buypool..asbuy2_posno */
      execute(' delete from ' + @buypool + '..ASBUY2_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        rollback transaction
        execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 21, '删除ASBUY2时发生错误。'
        set @processed = 0
        return @processed
      end

      /* delete from buypool..asbuy21_posno */
      execute(' delete from ' + @buypool + '..ASBUY21_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        rollback transaction
        execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 22, '删除ASBUY21时发生错误。'
        set @processed = 0
        return @processed
      end

      /*日志*/
      set @errmsg = '删除零售数据暂存库中重复的预售数据'
        + rtrim(@posno) + ' ' + rtrim(@flowno) + ' ' + rtrim(convert(char, @fildate, 109))
      insert into log(TIME, MONTHSETTLENO, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values(getdate(), @settleno, '零售加工', '服务器', '预售加工', 303, @errmsg)

      commit transaction
      set @processed = 0
      return @processed
    end else
    begin
      rollback transaction
      execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 11, '插入PREBUY1失败。'
      set @processed = 0
      return @processed
    end
  end

  /*PREBUY11*/
  execute(
  ' insert into PREBUY11(FLOWNO, POSNO, ITEMNO, SETTLENO, CURRENCY, AMOUNT, TAG, CARDCODE,' +
  ' FAVTYPE, FAVAMT, PARVALUE, CURRENCYTYPE, ORIGINALAMT, PARITIES, LSTUPDTIME)' +
  ' select FLOWNO, POSNO, ITEMNO, ' + @txtsettleno + ', CURRENCY, AMOUNT, TAG, CARDCODE,' +
  ' FAVTYPE, isnull(FAVAMT,0), isnull(PARVALUE,0), CURRENCYTYPE, ORIGINALAMT, PARITIES, getdate()' +
  ' from ' + @buypool + '..ASBUY11_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''')
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 12, '插入PREBUY11失败。'
    set @processed = 0
    return @processed
  end

  /*PREBUY2*/
  execute(
  ' insert into PREBUY2(FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE,' +
  ' REALAMT, FAVAMT, TAG, QPCGID, PRMTAG, ASSISTANT, WRH, INVNO, COST, DEALER,' +
  ' IQTY, GDCODE, SCRPRICE, SCRFAVRATE, LSTUPDTIME, PDTDATE, SCOREINFO, SCORE)' +
  ' select FLOWNO, POSNO, ITEMNO, ' + @txtsettleno + ', GID, QTY, INPRC, PRICE,' +
  ' REALAMT, FAVAMT, TAG, QPCGID, PRMTAG, ASSISTANT, WRH, INVNO, 0 COST, DEALER,' +
  ' IQTY, GDCODE, null, null, getdate(), null, SCOREINFO, SCORE' +
  ' from ' + @buypool + '..ASBUY2_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''')
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 13, '插入PREBUY2失败。'
    set @processed = 0
    return @processed
  end

  /*PREBUY21*/
  execute(
  ' insert into PREBUY21(FLOWNO, POSNO, ITEMNO, FAVTYPE, SETTLENO, FAVAMT,' +
  ' TAG, PROMNUM, PROMCLS, PROMLVL, PROMGDCNT, LSTUPDTIME, PROMQTY, PROMAMT)' +
  ' select FLOWNO, POSNO, ITEMNO, FAVTYPE, ' + @txtsettleno + ', FAVAMT,' +
  ' TAG, PROMNUM, PROMCLS, PROMLVL, PROMGDCNT, getdate(), null, null' +
  ' from ' + @buypool + '..ASBUY21_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''')
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 14, '插入PREBUY21失败。'
    set @processed = 0
    return @processed
  end

  /* test prebuy1<->prebuy11 */
  if not exists (select 1 from PREBUY11(nolock) where POSNO = @posno and FLOWNO = @flowno)
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 15, 'PREBUY1和PREBUY11不平。'
    set @processed = 0
    return @processed
  end

  declare
    @prebuy1_prevamt decimal(24,4),
    @prebuy1_realamt decimal(24,4),
    @prebuy11_amount_sum decimal(24,4),
    @prebuy11_amount2_sum decimal(24,4)
  select @prebuy1_prevamt = PREVAMT from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy1_realamt = REALAMT from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy11_amount_sum = isnull(sum(AMOUNT), 0)
    from PREBUY11(nolock)
    where POSNO = @posno and FLOWNO = @flowno
    and CURRENCY not in (-1, -2)
  select @prebuy11_amount2_sum = isnull(sum(AMOUNT), 0)
    from PREBUY11(nolock)
    where POSNO = @posno and FLOWNO = @flowno
    and CURRENCY in (-1, -2)

  if abs(@prebuy1_prevamt - @prebuy11_amount_sum) > 0.001
    or abs(@prebuy1_realamt - @prebuy11_amount_sum + @prebuy11_amount2_sum) > 0.001
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 15, 'PREBUY1和PREBUY11不平。'
    set @processed = 0
    return @processed
  end

  /* test prebuy1<->prebuy2 */
  if not exists (select 1 from PREBUY2(nolock) where POSNO = @posno and FLOWNO = @flowno)
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 17, 'PREBUY1和PREBUY2不平。'
    set @processed = 0
    return @processed
  end

  declare
    @prebuy1_total decimal(24,4),
    @prebuy2_total_sum decimal(24,4)
  select @prebuy1_total = TOTAL from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy2_total_sum = isnull(sum(QTY * PRICE), 0)
    from PREBUY2(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if abs(@prebuy1_total - @prebuy2_total_sum) <= 0.001
  begin
    update PREBUY1 set TOTAL = @prebuy2_total_sum
      where POSNO = @posno and FLOWNO = @flowno
  end
  else begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 16, 'PREBUY1和PREBUY2不平(TOTAL)。'
    set @processed = 0
    return @processed
  end

  declare
    @prebuy2_realamt_sum decimal(24,4)
  select @prebuy1_realamt = REALAMT from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy2_realamt_sum = isnull(sum(REALAMT), 0)
    from PREBUY2(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if abs(@prebuy1_realamt - @prebuy2_realamt_sum) > 0.0001
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 17, 'PREBUY1和PREBUY2不平。'
    set @processed = 0
    return @processed
  end

  /* test prebuy2<->prebuy21 */
  if exists (
    select 1
    from PREBUY2(nolock), PREBUY21(nolock)
    where PREBUY2.POSNO = @posno and PREBUY2.FLOWNO = @flowno
    and PREBUY21.POSNO = @posno and PREBUY21.FLOWNO = @flowno
    and PREBUY2.ITEMNO = PREBUY21.ITEMNO
    group by PREBUY2.ITEMNO, PREBUY2.FAVAMT
    having abs(PREBUY2.FAVAMT - SUM(CONVERT(DECIMAL(20,4),PREBUY21.FAVAMT))) > 0.001
  )
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 18, 'PREBUY2和PREBUY21不平'
    set @processed = 0
    return @processed
  end

  /* delete from buypool..asbuy1_posno */
  execute(
  ' delete from ' + @buypool + '..ASBUY1_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 19, '删除ASBUY1错误'
    set @processed = 0
    return @processed
  end

  /* delete from buypool..asbuy11_posno */
  execute(
  ' delete from ' + @buypool + '..ASBUY11_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 20, '删除ASBUY11错误'
    set @processed = 0
    return @processed
  end

  /* delete from buypool..asbuy2_posno */
  execute(
  ' delete from ' + @buypool + '..ASBUY2_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 21, '删除ASBUY2错误'
    set @processed = 0
    return @processed
  end

  /* delete from buypool..asbuy21_posno */
  execute(
  ' delete from ' + @buypool + '..ASBUY21_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    rollback transaction
    execute PreSaleProc_ErrLog @buypool, @posno, @flowno, 22, '删除ASBUY21错误'
    set @processed = 0
    return @processed
  end

  /*回写WORKSTATION*/
  update WORKSTATION set
    CNT = CNT + 1,
    AMT = AMT + @prebuy1_realamt
  where NO = @posno

  if convert(datetime, convert(char, getdate(), 102)) = convert(datetime, convert(char, @fildate, 102))
    update WORKSTATION set
      TODAYCNT = TODAYCNT + 1,
      TODAYAMT = TODAYAMT + @prebuy1_realamt
    where NO = @posno
  else
    insert into log ( time, employeecode, workstationno, modulename, content, type )
    values ( getdate(), 'PreSale', 'HDSVC', '预售处理',
    '非本日预售数据: 收银机号' + @posno + '流水号' + @flowno, 301 )

  commit transaction

  set @processed = 1
  return @processed
end
GO
