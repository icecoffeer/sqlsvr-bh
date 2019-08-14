SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[ConvertPreSaleToSale](
  @buypool varchar(30),
  @posno varchar(10),
  @flowno char(12),
  @msg varchar(255) output
)
as
begin
  declare
    @return_status smallint,
    @errmsg varchar(255)

  /*检查预售单*/
  declare @stat int
  select @stat = STAT from PREBUY1(nolock)
    where POSNO = @posno and FLOWNO = @flowno
  if @@rowcount = 0
  begin
    set @msg = '预售单不存在。POSNO:' + rtrim(@posno) + ',FLOWNO:' + rtrim(@flowno)
    set @return_status = 1
    return @return_status
  end
  else if @stat <> 200
  begin
    set @msg = '预售单不是进行中状态。POSNO:' + rtrim(@posno) + ',FLOWNO:' + rtrim(@flowno)
    set @return_status = 1
    return @return_status
  end

  /*改变状态、转销售时间*/
  update PREBUY1 set
    STAT = 300,
    TSTIME = getdate()
    where POSNO = @posno and FLOWNO = @flowno
  if @@error <> 0
  begin
    set @errmsg = '更新状态失败。'
    set @return_status = 1
    return @return_status
  end

  /*改变新收银机号、新流水号*/
  declare
    @newposno char(10),
    @maxflowno char(12),
    @newflowno char(12),
    @datestr char(8)
  /*posno*/
  exec OptReadStr 0, 'PreSalePosNo', 'yushou', @newposno output
  /*flowno*/
  set @datestr = convert(char, getdate(), 112)
  select @maxflowno = max(NEWFLOWNO)
    from PREBUY1(nolock)
    where NEWPOSNO = @newposno
    and NEWFLOWNO like @datestr + '%'
  if @maxflowno is null
  begin
    set @newflowno = @datestr + '0001'
  end
  else begin
    declare @flow char(4)
    set @flow = substring(@maxflowno, 9, 4)
    exec IncreaseASCIIString @flow output --参数最长为10位
    set @newflowno = @datestr + @flow
  end
  update PREBUY1 set
    NEWFLOWNO = @newflowno,
    NEWPOSNO = @newposno
    where POSNO = @posno and FLOWNO = @flowno
  if @@error <> 0
  begin
    set @errmsg = '更新新收银机号、新流水号状态失败。'
    set @return_status = 1
    return @return_status
  end

  /*检查目的地数据表，没有表结构，则创建之*/
  declare @existsbuy int
  /*..buy1_*/
  set @existsbuy = null
  select @existsbuy = object_id(@buypool + '..BUY1_' + @newposno)
  if @existsbuy is null
  begin
    exec('Create Table ' + @buypool + '..BUY1_' + @newposno +
      '(    FLOWNO      CHAR(12)     NOT NULL,' +
      '     POSNO       CHAR(8)      NOT NULL,' +
      '     FILDATE     DATETIME     DEFAULT GETDATE() NOT NULL,' +
      '     CASHIER     INT          DEFAULT 1 NOT NULL,' +
      '     WRH         INT          DEFAULT 1 NOT NULL,' +
      '     ASSISTANT   INT          NULL,' +
      '     TOTAL       MONEY        DEFAULT 0 NOT NULL,' +
      '     REALAMT     MONEY        DEFAULT 0 NOT NULL,' +
      '     PREVAMT     MONEY        DEFAULT 0 NOT NULL,' +
      '     GUEST       INT          NULL,' +
      '     RECCNT      INT          DEFAULT 0 NOT NULL,' +
      '     MEMO        VARCHAR(255) NULL,' +
      '     TAG         SMALLINT     DEFAULT 0 NOT NULL,' +
      '     INVNO       CHAR(10)     NULL,' +
      '     SCORE       MONEY        NULL,' +
      '     CARDCODE    CHAR(20)     NULL,' +
      '     DEALER      INT          NULL,' +
      '     FLAG        INT          NULL,' +
      '     SCOREINFO   CHAR(100)    NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO)' +
      ')')
  end
  /*..buy11_*/
  set @existsbuy = null
  select @existsbuy = object_id(@buypool + '..BUY11_' + @newposno)
  if @existsbuy is null
  begin
    exec('Create Table ' + @buypool + '..BUY11_' + @newposno +
      '(    FLOWNO      CHAR(12)     NOT NULL,' +
      '     POSNO       CHAR(8)      NOT NULL,' +
      '     ITEMNO      SMALLINT     NOT NULL,' +
      '     CURRENCY    SMALLINT     DEFAULT 0 NOT NULL,' +
      '     AMOUNT      MONEY        DEFAULT 0 NOT NULL,' +
      '     TAG         SMALLINT     DEFAULT 0 NOT NULL,' +
      '     CARDCODE    VARCHAR(128) NULL,' +
      '     FAVTYPE     VARCHAR(4)   NULL,' +
      '     FAVAMT      MONEY        NULL,' +
      '     PARVALUE    MONEY        NULL,' +
      '     ORIGINALAMT MONEY        NULL,' +
      '     CURRENCYTYPE VARCHAR(10) NULL,' +
      '     PARITIES    MONEY        NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO, ITEMNO)' +
      ')')
  end
  /*..buy2_*/
  set @existsbuy = null
  select @existsbuy = object_id(@buypool + '..BUY2_' + @newposno)
  if @existsbuy is null
  begin
    exec('Create Table ' + @buypool + '..BUY2_' + @newposno +
      '(    FLOWNO      CHAR(12)    NOT NULL,' +
      '     POSNO       CHAR(8)     NOT NULL,' +
      '     ITEMNO      SMALLINT    NOT NULL,' +
      '     GID         INT         NOT NULL,' +
      '     QTY         MONEY       DEFAULT 0 NOT NULL,' +
      '     INPRC       MONEY       DEFAULT 0 NOT NULL,' +
      '     PRICE       MONEY       DEFAULT 0 NOT NULL,' +
      '     REALAMT     MONEY       DEFAULT 0 NOT NULL,' +
      '     FAVAMT      MONEY       DEFAULT 0 NOT NULL,' +
      '     TAG         SMALLINT    DEFAULT 0 NOT NULL,' +
      '     QPCGID      INT         NULL,' +
      '     PRMTAG      CHAR(10)    NULL,' +
      '     ASSISTANT   INT         NULL,' +
      '     WRH         INT         DEFAULT 1 NULL,' +
      '     INVNO       CHAR(10)    NULL,' +
      '     DEALER      INT         NULL,' +
      '     IQTY        MONEY       NULL,' +
      '     GDCODE      CHAR(13)    NULL,' +
      '     SCRPRICE    MONEY       NULL,' +
      '     SCRFAVRATE  MONEY       NULL,' +
      '     Score       MONEY       NULL,' +
      '     ScoreInfo   CHAR(100)   NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO, ITEMNO)' +
      ')')
  end
  /*..buy21_*/
  set @existsbuy = null
  select @existsbuy = object_id(@buypool + '..BUY21_' + @newposno)
  if @existsbuy is null
  begin
    exec('Create Table ' + @buypool + '..BUY21_' + @newposno +
      '(    FLOWNO      CHAR(12)    NOT NULL,' +
      '     POSNO       CHAR(8)     NOT NULL,' +
      '     ITEMNO      SMALLINT    NOT NULL,' +
      '     FAVTYPE     CHAR(4)     NOT NULL,' +
      '     FAVAMT      MONEY       DEFAULT 0 NOT NULL,' +
      '     TAG         SMALLINT    DEFAULT 0 NOT NULL,' +
      '     PROMNUM     CHAR(14)    NULL,' +
      '     PROMCLS     CHAR(10)    NULL,' +
      '     PROMLVL     INT         NULL,' +
      '     PROMGDCNT   INT         NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO, ITEMNO, FAVTYPE)' +
      ')')
  end

  /*复制数据*/
  /*prebuy1*/
  execute (
  ' insert into ' + @buypool + '..BUY1_' + @newposno +
  ' (FLOWNO, POSNO, FILDATE, CASHIER, TOTAL,' +
  ' REALAMT, PREVAMT, GUEST, RECCNT, MEMO,' +
  ' WRH, ASSISTANT, INVNO, SCORE, CARDCODE,' +
  ' DEALER, FLAG, SCOREINFO)' +
  ' select ''' + @newflowno + ''', ''' + @newposno + ''', FILDATE, CASHIER, TOTAL,' +
  ' REALAMT, PREVAMT, GUEST, RECCNT, MEMO,' +
  ' WRH, ASSISTANT, INVNO, SCORE, CARDCODE,' +
  ' DEALER, FLAG, SCOREINFO' +
  ' from PREBUY1(nolock)' +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + ''''
  )
  if @@error <> 0
  begin
    set @errmsg = '插入失败。表名：' + @buypool + '..BUY1_' + @newposno
    set @return_status = 1
    return @return_status
  end

  /*prebuy11*/
  execute (
  ' insert into ' + @buypool + '..BUY11_' + @newposno +
  ' (FLOWNO, POSNO, ITEMNO, CURRENCY, AMOUNT,' +
  ' CARDCODE, FAVTYPE, FAVAMT, PARVALUE, CURRENCYTYPE,' +
  ' ORIGINALAMT, PARITIES)' +
  ' select ''' + @newflowno + ''', ''' + @newposno + ''', ITEMNO, CURRENCY, AMOUNT,' +
  ' CARDCODE, FAVTYPE, FAVAMT, PARVALUE, CURRENCYTYPE,' +
  ' ORIGINALAMT, PARITIES' +
  ' from PREBUY11(nolock)' +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + ''''
  )
  if @@error <> 0
  begin
    set @errmsg = '插入失败。表名：' + @buypool + '..BUY11_' + @newposno
    set @return_status = 1
    return @return_status
  end

  /*prebuy2*/
  execute(
  ' insert into ' + @buypool + '..BUY2_' + @newposno +
  ' (FLOWNO, POSNO, ITEMNO, GID, QTY,' +
  ' INPRC, PRICE, REALAMT, FAVAMT, TAG,'+
  ' QPCGID, PRMTAG, ASSISTANT, WRH, INVNO,' +
  ' DEALER, IQTY, GDCODE, SCRPRICE, SCRFAVRATE,' +
  ' SCOREINFO, SCORE)' +
  ' select ''' + @newflowno + ''', ''' + @newposno + ''', ITEMNO, GID, QTY,' +
  ' INPRC, PRICE, REALAMT, FAVAMT, TAG,'+
  ' QPCGID, PRMTAG, ASSISTANT, WRH, INVNO,' +
  ' DEALER, IQTY, GDCODE, SCRPRICE, SCRFAVRATE,' +
  ' SCOREINFO, SCORE' +
  ' from PREBUY2(nolock)' +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + ''''
  )
  if @@error <> 0
  begin
    set @errmsg = '插入失败。表名：' + @buypool + '..BUY2_' + @newposno
    set @return_status = 1
    return @return_status
  end

  /*prebuy21*/
  execute(
  ' insert into ' + @buypool + '..BUY21_' + @newposno +
  ' (FLOWNO, POSNO, ITEMNO, FAVTYPE, FAVAMT,' +
  ' TAG, PROMNUM, PROMCLS, PROMLVL, PROMGDCNT)' +
  ' select ''' + @newflowno + ''', ''' + @newposno + ''', ITEMNO, FAVTYPE, FAVAMT,' +
  ' TAG, PROMNUM, PROMCLS, PROMLVL, PROMGDCNT' +
  ' from PREBUY21(nolock)' +
  ' where POSNO = ''' + @posno + '''' +
  ' and FLOWNO = ''' + @flowno + '''')
  if @@error <> 0
  begin
    set @errmsg = '插入失败。表名：' + @buypool + '..BUY21_' + @newposno
    set @return_status = 1
    return @return_status
  end

  return 0
end
GO
