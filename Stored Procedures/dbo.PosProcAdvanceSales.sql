SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PosProcAdvanceSales](
  @buypool varchar(30),
  @posno varchar(10),
  @flowno varchar(12),
  @msg varchar(100) output
)
as
begin
  declare
    @return_status smallint,
    @settleno int,
    @fildate datetime,
    @presalenum char(14),
    @txtsettleno varchar(10)

  /*事务加在调用方*/
  set @return_status = 0
  select @settleno = max(NO) from MONTHSETTLE(nolock)
  set @txtsettleno = convert(varchar, @settleno)

  /*新预售单号*/
  exec @return_status = GenNextBillNumEx '', 'PREBUY1', @presalenum output
  if @return_status <> 0
  begin
    set @Msg = '取新的后台预售单号失败。'
    return @return_status
  end

  /*PREBUY1*/
  execute(
  ' insert into PREBUY1(NUM, ASNUM, TSTIME, RCVTIME, SNDTIME, STAT, FLOWNO, POSNO, SETTLENO,' +
  ' FILDATE, CASHIER, WRH, ASSISTANT, TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO,' +
  ' SCORE, CARDCODE, DEALER, FLAG, PROCDATE, SCOREINFO)' +
  ' select ''' + @presalenum + ''', ASNUM, null, getdate(), null, 200, FLOWNO, POSNO, ' + @txtsettleno + ',' +
  ' FILDATE, CASHIER, WRH, ASSISTANT, TOTAL, REALAMT, PREVAMT, GUEST, RECCNT, MEMO, TAG, INVNO,' +
  ' SCORE, CARDCODE, DEALER, FLAG, PROCDATE, SCOREINFO)' +
  ' from ' + @buypool + '..ASBUY1_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''' )
  if @@error <> 0
  begin
    execute(
    ' declare c_asrtl cursor for' +
    ' select FILDATE from ' + @buypool + '..ASBUY1_' + @posno +
    ' where POSNO = ''' + @posno + '''' +
    ' and FLOWNO = ''' + @flowno + '''' )
    open c_asrtl
    fetch next from c_asrtl into @fildate
    close c_asrtl
    deallocate c_asrtl
    if exists (select 1 from PREBUY1(nolock) where FLOWNO = @flowno and POSNO = @posno and FILDATE = @fildate)
    begin
      /* delete from buypool */
      execute(' delete from ' + @buypool + '..ASBUY1_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        set @msg = '删除ASBUY1错误'
        return 1
      end
      execute(' delete from ' + @buypool + '..ASBUY11_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        set @msg = '删除ASBUY11错误'
        return 1
      end
      execute(' delete from ' + @buypool + '..ASBUY2_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        set @msg = '删除ASBUY2错误'
        return 1
      end
      execute(' delete from ' + @buypool + '..ASBUY21_' + @posno + ' where FLOWNO = ''' + @flowno + '''' + ' and POSNO = ''' + @posno + '''' )
      if @@error <> 0
      begin
        set @msg = '删除ASBUY21错误'
        return 1
      end
     
      insert into log(TIME, MONTHSETTLENO, EMPLOYEECODE, WORKSTATIONNO, MODULENAME, TYPE, CONTENT)
        values(getdate(), @settleno, '零售加工', '服务器', '零售加工', 303, '删除重复的零售数据(预售)' + rtrim(@posno) + ' ' + rtrim(@flowno) + ' ' + rtrim(convert(char, @fildate, 109)))
     
      return 0
    end else
    begin
      set @msg = '插入PREBUY1失败。'
      return 1
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
    set @msg = '插入PREBUY11失败。'
    return 1
  end

  /*PREBUY2*/
  execute(
  ' insert into PREBUY2(FLOWNO, POSNO, ITEMNO, SETTLENO, GID, QTY, INPRC, PRICE,' +
  ' REALAMT, FAVAMT, TAG, QPCGID, PRMTAG, ASSISTANT, WRH, INVNO, COST, DEALER,' +
  ' IQTY, GDCODE, SCRPRICE, SCRFAVRATE, LSTUPDTIME, PDTDATE, SCOREINFO)' +
  ' select FLOWNO, POSNO, ITEMNO, ' + @txtsettleno + ', GID, QTY, INPRC, PRICE,' +
  ' REALAMT, FAVAMT, TAG, QPCGID, PRMTAG, ASSISTANT, WRH, INVNO, COST, DEALER,' +
  ' IQTY, GDCODE, null, null, getdate(), null, SCOREINFO' +
  ' from ' + @buypool + '..ASBUY2_' + @posno +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''')
  if @@error <> 0
  begin
    set @msg = '插入PREBUY2失败。'
    return 1
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
    set @msg = '插入PREBUY21失败。'
    return 1
  end

  /* test prebuy1<->prebuy11 */
  if not exists (select 1 from PREBUY11(nolock) where POSNO = @posno and FLOWNO = @flowno)
  begin
    set @msg = 'PREBUY1和PREBUY11不平。'
    return 1
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
  select @prebuy11_amount_sum = sum(AMOUNT) from PREBUY11(nolock)
    where POSNO = @posno and FLOWNO = @flowno
    and CURRENCY not in (-1, -2)
  select @prebuy11_amount2_sum = sum(AMOUNT) from PREBUY11(nolock)
    where POSNO = @posno and FLOWNO = @flowno
    and CURRENCY in (-1, -2)

  if abs(@prebuy1_prevamt - @prebuy11_amount_sum) > 0.001
    or abs(@prebuy1_realamt - @prebuy11_amount_sum - @prebuy11_amount2_sum) > 0.001
  begin
    set @msg = 'PREBUY1和PREBUY11不平。'
    return 1
  end

  /* test prebuy1<->prebuy2 */
  if not exists (select 1 from PREBUY2(nolock) where POSNO = @posno and FLOWNO = @flowno)
  begin
    set @msg = 'PREBUY1和PREBUY2不平。'
    return 1
  end
  
  declare
    @prebuy1_total decimal(24,4),
    @prebuy2_total_sum decimal(24,4)
  select @prebuy1_total = TOTAL from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy2_total_sum = sum(QTY * PRICE) from PREBUY2(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if abs(@prebuy1_total - @prebuy2_total_sum) <= 0.001
  begin
    update PREBUY1 set TOTAL = @prebuy2_total_sum
      where POSNO = @posno and FLOWNO = @flowno
  end
  else begin
    set @msg = 'PREBUY1和PREBUY2不平。'
    return 1
  end

  declare
    @prebuy2_realamt_sum decimal(24,4)
  select @prebuy1_realamt = REALAMT from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  select @prebuy2_realamt_sum = sum(REALAMT) from PREBUY2(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if abs(@prebuy1_realamt - @prebuy2_realamt_sum) > 0.0001
  begin
    set @msg = 'PREBUY1和PREBUY2不平。'
    return 1
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
    set @msg = 'BUY2和BUY21不平'
    return 1
  end

  /* delete from buypool */
  execute(
  ' delete from ' + @buypool + '..ASBUY1_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    set @msg = '删除ASBUY1错误'
    return 1
  end

  execute(
  ' delete from ' + @buypool + '..ASBUY11_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    set @msg = '删除ASBUY11错误'
    return 1
  end

  execute(
  ' delete from ' + @buypool + '..ASBUY2_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    set @msg = '删除ASBUY2错误'
    return 1
  end

  execute(
  ' delete from ' + @buypool + '..ASBUY21_' + @posno +
  ' where FLOWNO = ''' + @flowno + '''' +
  ' and POSNO = ''' + @posno + ''''
  )
  if @@error <> 0
  begin
    set @msg = '删除ASBUY21错误'
    return 1
  end

  return 0
end
GO
