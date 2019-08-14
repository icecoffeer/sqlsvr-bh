CREATE TABLE [dbo].[GOODSH]
(
[GID] [int] NOT NULL,
[CODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[RTLPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__RTLPRC__37A6DD2A] DEFAULT (0),
[INPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__INPRC__389B0163] DEFAULT (0),
[TAXRATE] [money] NOT NULL CONSTRAINT [DF__GOODSH__TAXRATE__398F259C] DEFAULT (17),
[PROMOTE] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__PROMOTE__3A8349D5] DEFAULT ((-1)),
[PRCTYPE] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__PRCTYPE__3B776E0E] DEFAULT (0),
[SALE] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__SALE__3C6B9247] DEFAULT (1),
[LSTINPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__LSTINPRC__3D5FB680] DEFAULT (0),
[INVPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__INVPRC__3E53DAB9] DEFAULT (0),
[OLDINVPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__OLDINVPR__3F47FEF2] DEFAULT (0),
[LWTRTLPRC] [money] NULL,
[WHSPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__WHSPRC__403C232B] DEFAULT (0),
[WRH] [int] NOT NULL CONSTRAINT [DF__GOODSH__WRH__41304764] DEFAULT (1),
[ACNT] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__ACNT__42246B9D] DEFAULT (1),
[PAYTODTL] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__PAYTODTL__43188FD6] DEFAULT (0),
[PAYRATE] [money] NULL CONSTRAINT [DF__GOODSH__PAYRATE__440CB40F] DEFAULT (75),
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__GOODSH__MUNIT__4500D848] DEFAULT (''),
[ISPKG] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__ISPKG__45F4FC81] DEFAULT (0),
[GFT] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__GFT__46E920BA] DEFAULT (0),
[QPC] [money] NOT NULL CONSTRAINT [DF__GOODSH__QPC__47DD44F3] DEFAULT (1),
[TM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MANUFACTOR] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[MCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GPR] [money] NULL,
[LOWINV] [money] NULL,
[HIGHINV] [money] NULL,
[VALIDPERIOD] [smallint] NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__GOODSH__CREATEDA__48D1692C] DEFAULT (getdate()),
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[CHKVD] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__CHKVD__49C58D65] DEFAULT (0),
[SRC] [int] NOT NULL CONSTRAINT [DF__GOODSH__SRC__4AB9B19E] DEFAULT (1),
[SNDTIME] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__GOODSH__LSTUPDTI__4BADD5D7] DEFAULT (getdate()),
[DXPRC] [money] NOT NULL CONSTRAINT [DF__GOODSH__DXPRC__4CA1FA10] DEFAULT (0),
[BILLTO] [int] NOT NULL CONSTRAINT [DF__GOODSH__BILLTO__4D961E49] DEFAULT (1),
[AUTOORD] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__AUTOORD__4E8A4282] DEFAULT (0),
[ORIGIN] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[GRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[MBRPRC] [money] NULL,
[SALETAX] [money] NOT NULL CONSTRAINT [DF__GOODSH__SALETAX__4F7E66BB] DEFAULT (17),
[PSR] [int] NOT NULL CONSTRAINT [DF__GOODSH__PSR__50728AF4] DEFAULT (1),
[F1] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F2] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[F3] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[FILLER] [int] NOT NULL CONSTRAINT [DF__GOODSH__FILLER__5166AF2D] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__GOODSH__MODIFIER__525AD366] DEFAULT (1),
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CODE2] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[MKTINPRC] [money] NULL,
[MKTRTLPRC] [money] NULL,
[CNTINPRC] [money] NULL,
[ALCQTY] [money] NULL CONSTRAINT [DF__GOODSH__ALCQTY__534EF79F] DEFAULT (1),
[ISBIND] [smallint] NULL CONSTRAINT [DF__GOODSH__ISBIND__54431BD8] DEFAULT (0),
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ISLTD] [smallint] NULL CONSTRAINT [DF__GOODSH__ISLTD__7D85F3E4] DEFAULT (0),
[INVCOST] [money] NULL CONSTRAINT [DF__GOODSH__INVCOST__2FA5C8AF] DEFAULT (0),
[BQtyPrc] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[KEEPTYPE] [int] NOT NULL CONSTRAINT [DF__GOODSH__KEEPTYPE__3CCAB9A3] DEFAULT (0),
[NEndTime] [datetime] NULL,
[NCanPay] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__NCanPay__57A99868] DEFAULT (0),
[SSStart] [datetime] NULL,
[SSEnd] [datetime] NULL,
[Season] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[HQControl] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__HQContro__5A860513] DEFAULT (0),
[ORDCYCLE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ALCCTR] [int] NULL,
[isdisp] [smallint] NOT NULL CONSTRAINT [DF__goodsh__isdisp__53CEE5E3] DEFAULT (1),
[TOPRTLPRC] [money] NULL,
[LSTUPDTIME2] [datetime] NULL,
[UPCTRL] [int] NOT NULL CONSTRAINT [DF__GOODSH__UPCTRL__68D6866F] DEFAULT (0),
[MINLOWQTY] [money] NULL,
[F4] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL,
[SubmitType] [smallint] NULL,
[ORDERQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__GOODSH__ORDERQTY] DEFAULT (1),
[ELIREASON] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[NOAUTOORDREASON] [varchar] (4) COLLATE Chinese_PRC_CI_AS NULL,
[SALCQTY] [int] NULL,
[SALCQSTART] [int] NULL,
[TJCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__goodsh__TJCODE__262C0F77] DEFAULT ('-'),
[ISOFFSETGOODS] [smallint] NOT NULL CONSTRAINT [DF__GOODSH__ISOFFSET__01FB32A7] DEFAULT (0),
[ZJSORT] [varchar] (13) COLLATE Chinese_PRC_CI_AS NULL,
[SHOPNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[Length] [money] NULL,
[Width] [money] NULL,
[Height] [money] NULL,
[SHORTNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[TAXSORT] [int] NULL,
[TAXSORTCODE] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GOODSH] ADD CONSTRAINT [PK__GOODSH__66B53B20] PRIMARY KEY CLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [goodsh_f1_idx] ON [dbo].[GOODSH] ([F1]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
EXEC sp_bindefault N'[dbo].[DF_GOODSH_BRAND]', N'[dbo].[GOODSH].[BRAND]'
GO