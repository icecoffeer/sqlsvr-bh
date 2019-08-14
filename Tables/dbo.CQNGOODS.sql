CREATE TABLE [dbo].[CQNGOODS]
(
[GROUPID] [int] NOT NULL,
[RHQUUID] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[NTYPE] [int] NOT NULL,
[NSTAT] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__NSTAT__7077A837] DEFAULT (0),
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODS__EXTIME__716BCC70] DEFAULT (getdate()),
[GID] [int] NOT NULL,
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[INPRC] [decimal] (24, 4) NULL,
[TAXRATE] [decimal] (24, 4) NULL,
[PROMOTE] [smallint] NULL,
[PRCTYPE] [smallint] NULL,
[SALE] [smallint] NULL,
[LSTINPRC] [decimal] (24, 4) NULL,
[INVPRC] [decimal] (24, 4) NULL,
[OLDINVPRC] [decimal] (24, 4) NULL,
[LWTRTLPRC] [decimal] (24, 4) NULL,
[WHSPRC] [decimal] (24, 4) NOT NULL,
[WRH] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__WRH__725FF0A9] DEFAULT (1),
[ACNT] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__ACNT__735414E2] DEFAULT (1),
[PAYTODTL] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__PAYTOD__7448391B] DEFAULT (0),
[PAYRATE] [decimal] (24, 4) NULL CONSTRAINT [DF__CQNGOODS__PAYRAT__753C5D54] DEFAULT (75),
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__CQNGOODS__MUNIT__7630818D] DEFAULT (''),
[ISPKG] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__ISPKG__7724A5C6] DEFAULT (0),
[GFT] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__GFT__7818C9FF] DEFAULT (0),
[QPC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNGOODS__QPC__790CEE38] DEFAULT (1),
[TM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MANUFACTOR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[MCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GPR] [decimal] (24, 4) NULL,
[LOWINV] [decimal] (24, 4) NULL,
[HIGHINV] [decimal] (24, 4) NULL,
[VALIDPERIOD] [smallint] NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODS__CREATE__7A011271] DEFAULT (getdate()),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CHKVD] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__CHKVD__7AF536AA] DEFAULT (0),
[SRC] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__SRC__7BE95AE3] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__CQNGOODS__LSTUPD__7CDD7F1C] DEFAULT (getdate()),
[DXPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNGOODS__DXPRC__7DD1A355] DEFAULT (0),
[BILLTO] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__BILLTO__7EC5C78E] DEFAULT (1),
[AUTOORD] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__AUTOOR__7FB9EBC7] DEFAULT (0),
[ORIGIN] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[SALETAX] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__CQNGOODS__SALETA__00AE1000] DEFAULT (17),
[PSR] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__PSR__01A23439] DEFAULT (1),
[F1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F2] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F3] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__FILLER__02965872] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__MODIFI__038A7CAB] DEFAULT (1),
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CODE2] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[MKTINPRC] [decimal] (24, 4) NULL,
[MKTRTLPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NULL,
[ALCQTY] [decimal] (24, 4) NULL CONSTRAINT [DF__CQNGOODS__ALCQTY__047EA0E4] DEFAULT (1),
[ISBIND] [smallint] NULL CONSTRAINT [DF__CQNGOODS__ISBIND__0572C51D] DEFAULT (0),
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL CONSTRAINT [DF__CQNGOODS__BRAND__0666E956] DEFAULT ('-'),
[ISLTD] [smallint] NULL CONSTRAINT [DF__CQNGOODS__ISLTD__075B0D8F] DEFAULT (0),
[INVCOST] [decimal] (24, 4) NULL CONSTRAINT [DF__CQNGOODS__INVCOS__084F31C8] DEFAULT (0),
[BQTYPRC] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[KEEPTYPE] [int] NOT NULL CONSTRAINT [DF__CQNGOODS__KEEPTY__09435601] DEFAULT (0),
[NEndTime] [datetime] NULL,
[NCanPay] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__NCanPa__0A377A3A] DEFAULT (0),
[SSStart] [datetime] NULL,
[SSEnd] [datetime] NULL,
[Season] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[HQControl] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__HQCont__0B2B9E73] DEFAULT (0),
[ORDCYCLE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ALCCTR] [int] NULL,
[isdisp] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__isdisp__0C1FC2AC] DEFAULT (1),
[TOPRTLPRC] [decimal] (24, 4) NULL,
[LSTUPDTIME2] [datetime] NULL,
[UPCTRL] [smallint] NOT NULL CONSTRAINT [DF__CQNGOODS__UPCTRL__0D13E6E5] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CQNGOODS] ADD CONSTRAINT [PK__CQNGOODS__0E080B1E] PRIMARY KEY CLUSTERED  ([NTYPE], [GROUPID]) ON [PRIMARY]
GO