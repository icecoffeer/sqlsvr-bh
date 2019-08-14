SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO
create procedure [dbo].[PreSaleProc_GenASBuyTables](
  @buypool varchar(30),
  @posno varchar(10),
  @msg varchar(255) output
)
as
begin
  declare
    @tablename_asbuy1 sysname,
    @tablename_asbuy11 sysname,
    @tablename_asbuy2 sysname,
    @tablename_asbuy21 sysname

  select
    @tablename_asbuy1 = @buypool + '..ASBUY1_' + @posno,
    @tablename_asbuy11 = @buypool + '..ASBUY11_' + @posno,
    @tablename_asbuy2 = @buypool + '..ASBUY2_' + @posno,
    @tablename_asbuy21 = @buypool + '..ASBUY21_' + @posno

  if object_id(@tablename_asbuy1) is null
  begin
    exec('Create Table ' + @tablename_asbuy1 +
      '(    FLOWNO      CHAR(12)     NOT NULL,' +
      '     POSNO       CHAR(8)      NOT NULL,' +
      '     SETTLENO    INT          NOT NULL,' +
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
      '     ASNUM       CHAR(14)     NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO)' +
      ')')
  end

  if object_id(@tablename_asbuy11) is null
  begin
    exec('Create Table ' + @tablename_asbuy11 +
      '(    FLOWNO      CHAR(12)     NOT NULL,' +
      '     POSNO       CHAR(8)      NOT NULL,' +
      '     ITEMNO      SMALLINT     NOT NULL,' +
      '     SETTLENO    INT          NOT NULL,' +
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

  if object_id(@tablename_asbuy2) is null
  begin
    exec('Create Table ' + @tablename_asbuy2 +
      '(    FLOWNO      CHAR(12)      NOT NULL,' +
      '     POSNO       CHAR(8)       NOT NULL,' +
      '     ITEMNO      SMALLINT      NOT NULL,' +
      '     SETTLENO    INT           NOT NULL,' +
      '     GID         INT           NOT NULL,' +
      '     QTY         MONEY         DEFAULT 0 NOT NULL,' +
      '     INPRC       MONEY         DEFAULT 0 NOT NULL,' +
      '     PRICE       MONEY         DEFAULT 0 NOT NULL,' +
      '     REALAMT     MONEY         DEFAULT 0 NOT NULL,' +
      '     FAVAMT      MONEY         DEFAULT 0 NOT NULL,' +
      '     TAG         SMALLINT      DEFAULT 0 NOT NULL,' +
      '     QPCGID      INT           NULL,' +
      '     PRMTAG      CHAR(10)      NULL,' +
      '     ASSISTANT   INT           NULL,' +
      '     WRH         INT           DEFAULT 1 NULL,' +
      '     INVNO       CHAR(10)      NULL,' +
      '     COST        DECIMAL(24,4) DEFAULT 0 NOT NULL,' +
      '     DEALER      INT           NULL,' +
      '     IQTY        MONEY         NULL,' +
      '     GDCODE      CHAR(13)      NULL,' +
      '     SCRPRICE    MONEY         NULL,' +
      '     SCRFAVRATE  MONEY         NULL,' +
      '     Score       MONEY         NULL,' +
      '     ScoreInfo   CHAR(100)     NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO, ITEMNO)' +
      ')')
  end

  if object_id(@tablename_asbuy21) is null
  begin
    exec('Create Table ' + @tablename_asbuy21 +
      '(    FLOWNO      CHAR(12)    NOT NULL,' +
      '     POSNO       CHAR(8)     NOT NULL,' +
      '     ITEMNO      SMALLINT    NOT NULL,' +
      '     FAVTYPE     CHAR(4)     NOT NULL,' +
      '     SETTLENO    INT          NOT NULL,' +
      '     FAVAMT      MONEY       DEFAULT 0 NOT NULL,' +
      '     TAG         SMALLINT    DEFAULT 0 NOT NULL,' +
      '     PROMNUM     CHAR(14)    NULL,' +
      '     PROMCLS     CHAR(10)    NULL,' +
      '     PROMLVL     INT         NULL,' +
      '     PROMGDCNT   INT         NULL,' +
      ' PRIMARY KEY (POSNO, FLOWNO, ITEMNO, FAVTYPE)' +
      ')')
  end

  set @msg = ''
  return(0)
end
GO
