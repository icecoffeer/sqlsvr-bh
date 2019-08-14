CREATE TABLE [dbo].[VENDORH]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (100) COLLATE Chinese_PRC_CI_AS NULL,
[SHORTNAME] [char] (16) COLLATE Chinese_PRC_CI_AS NULL,
[ADDRESS] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[TAXNO] [char] (32) COLLATE Chinese_PRC_CI_AS NULL,
[ACCOUNTNO] [char] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FAX] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ZIP] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[TELE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__VENDORH__CREATED__7E3955A4] DEFAULT (getdate()),
[PROPERTY] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLEACCOUNT] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[PAYTERM] [smallint] NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[LAWREP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CONTACTOR] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRPHONE] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBP] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__VENDORH__SRC__7F2D79DD] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__VENDORH__LSTUPDT__00219E16] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__VENDORH__FILLER__0115C24F] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__VENDORH__MODIFIE__0209E688] DEFAULT (1),
[KEEPAMT] [money] NOT NULL CONSTRAINT [DF__VENDORH__KEEPAMT__02FE0AC1] DEFAULT (0),
[TAXTYPE] [smallint] NOT NULL CONSTRAINT [DF__VENDORH__TAXTYPE__03F22EFA] DEFAULT (1),
[EMAILADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[WWWADR] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[CDTRATE] [money] NULL CONSTRAINT [DF__VENDORH__CDTRATE__04E65333] DEFAULT (0),
[ADFEE] [money] NULL CONSTRAINT [DF__VENDORH__ADFEE__05DA776C] DEFAULT (0),
[PRMFEE] [money] NULL CONSTRAINT [DF__VENDORH__PRMFEE__06CE9BA5] DEFAULT (0),
[INVCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[REGFUND] [money] NULL,
[CTRIDCARD] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[VTM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[OTHERSALEAREA] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRCSTYLE] [smallint] NOT NULL CONSTRAINT [DF__VENDORH__RTLPRCS__7C06F46F] DEFAULT (0),
[RTLPRCRANGE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTER] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[COUNTERAREA] [money] NULL,
[VAREA] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[OUTTERWRHAREA] [money] NULL,
[TGTSALEAMT] [money] NULL,
[LWTSALEAMT] [money] NULL,
[DRAWRATE] [money] NULL,
[EQPUSEAMT] [money] NULL,
[ASSISTANTS] [int] NULL,
[CLOTHUSES] [int] NULL,
[ASTSALARY] [money] NULL,
[CREDITS] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CTRBEGIN] [datetime] NULL,
[CTREND] [datetime] NULL,
[SIGNDATE] [datetime] NULL,
[hizjde] [money] NULL CONSTRAINT [DF__vendorh__hizjde__2CCA275B] DEFAULT (0),
[lowzjde] [money] NULL CONSTRAINT [DF__vendorh__lowzjde__2DBE4B94] DEFAULT (0),
[days] [int] NOT NULL CONSTRAINT [DF__vendorh__days__052715AC] DEFAULT (0),
[PAYCLS] [smallint] NULL CONSTRAINT [DF__VENDORH__PAYCLS__4B4DE324] DEFAULT (2),
[MVDR] [int] NOT NULL CONSTRAINT [DF__VENDORH__MVDR__67B517A8] DEFAULT (1),
[ISUSETOKEN] [smallint] NOT NULL CONSTRAINT [DF__vendorh__ISUSETO__4B0495B8] DEFAULT (0),
[SAFEAMT] [money] NULL CONSTRAINT [DF__VENDORH__SAFEAMT__3A64199B] DEFAULT (0),
[PAYLIMITED] [char] (2) COLLATE Chinese_PRC_CI_AS NULL,
[SendArea] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PayType] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[upay] [int] NULL CONSTRAINT [DF__vendorh__upay__7783CD22] DEFAULT (0),
[UPCTRL] [int] NOT NULL CONSTRAINT [DF__VENDORH__UPCTRL__6BB2F31A] DEFAULT (0),
[SendType] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SendLocation] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[BckCycleType] [int] NULL,
[BckBgnMon] [int] NULL,
[BckBgnDays] [int] NULL,
[BckBgnAmt] [money] NULL,
[BckExpRate] [money] NULL,
[BckExpDays] [int] NULL,
[BckLmt] [int] NOT NULL CONSTRAINT [vendorhBckLmtDflt] DEFAULT (0),
[MinDlvQty] [money] NULL,
[MinDlvAmt] [money] NULL,
[OrderLmt] [decimal] (24, 2) NULL,
[ISGENEIVC] [smallint] NOT NULL CONSTRAINT [DF__VENDORH__ISGENEI__73C54F45] DEFAULT ((0))
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VENDORH] ADD CONSTRAINT [PK__VENDORH__40257DE4] PRIMARY KEY CLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
