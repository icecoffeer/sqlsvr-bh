CREATE TABLE [dbo].[PGFBOOK]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VENDOR] [int] NOT NULL,
[CNTRNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PGFCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CalcTotal] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PGFBOOK__CalcTot__6A6C2B2B] DEFAULT (0),
[CalcRate] [decimal] (24, 2) NULL CONSTRAINT [DF__PGFBOOK__CalcRat__6B604F64] DEFAULT (0),
[SHOULDAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PGFBOOK__SHOULDA__6C54739D] DEFAULT (0),
[REALAMT] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PGFBOOK__REALAMT__6D4897D6] DEFAULT (0),
[OCRDATE] [datetime] NULL,
[SIGNDATE] [datetime] NULL,
[SIGNER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PGFBOOK__FILDATE__6E3CBC0F] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PGFBOOK__STAT__6F30E048] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CALCBEGIN] [datetime] NULL,
[CALCEND] [datetime] NULL,
[FIXNOTE] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[BTYPE] [int] NOT NULL,
[SRCNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SRCCLS] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[PRNTIME] [datetime] NULL,
[MODNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PGFBOOK__LSTUPDT__70250481] DEFAULT (getdate()),
[BILLTO] [int] NOT NULL,
[GATHERINGMODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PGFBOOK__GATHERI__711928BA] DEFAULT ('抵扣货款'),
[ACCOUNTTERM] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PGFBOOK__ACCOUNT__720D4CF3] DEFAULT ('签约前'),
[PAYTOTAL] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PGFBOOK__PAYTOTA__7301712C] DEFAULT (0),
[DEPT] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PAYDIRECT] [smallint] NOT NULL CONSTRAINT [DF__PGFBOOK__PAYDIRE__73F59565] DEFAULT (1),
[PAYDATE] [datetime] NULL,
[PSR] [int] NULL,
[CNTRVERSION] [int] NULL,
[GENDATE] [datetime] NOT NULL CONSTRAINT [DF__PGFBOOK__GENDATE__74E9B99E] DEFAULT (getdate()),
[STORE] [int] NOT NULL CONSTRAINT [DF__PGFBOOK__STORE__75DDDDD7] DEFAULT (1),
[ABOLISHRESON] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[TAXRATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__PGFBOOK__TAXRATE__76D20210] DEFAULT (17),
[PAYUNIT] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PGFBOOK__PAYUNIT__77C62649] DEFAULT ('总部'),
[STSTORE] [int] NULL,
[SNDTIME] [datetime] NULL,
[SRC] [int] NULL,
[CASHCENTER] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PGFBOOK] ADD CONSTRAINT [PK__PGFBOOK__78BA4A82] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
