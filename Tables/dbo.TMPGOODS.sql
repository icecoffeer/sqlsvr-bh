CREATE TABLE [dbo].[TMPGOODS]
(
[spid] [int] NOT NULL,
[ID] [int] NOT NULL IDENTITY(1, 1),
[GDNAME] [char] (50) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTOGID] [int] NULL,
[BILLTOCODE] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BILLTONAME] [char] (80) COLLATE Chinese_PRC_CI_AS NULL,
[GDSALE] [smallint] NULL,
[DEPT] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[BRAND] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[BRANDNAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[SORT] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[TAXRATE] [decimal] (24, 4) NULL,
[RTLPRC] [decimal] (24, 4) NULL,
[CNTINPRC] [decimal] (24, 4) NULL,
[PAYRATE] [decimal] (24, 4) NULL,
[DXPRC] [decimal] (24, 4) NULL,
[PRCTYPE] [smallint] NULL,
[MCODE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[SPEC] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NULL,
[CODE2] [char] (40) COLLATE Chinese_PRC_CI_AS NULL,
[ALC] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PSR] [int] NULL,
[QPC] [decimal] (24, 4) NULL,
[ALCQTY] [decimal] (24, 4) NULL,
[MBRPRC] [decimal] (24, 4) NULL,
[TJCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ORIGIN] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[ISNEWSJCODE] [smallint] NULL,
[ISNEWBRAND] [smallint] NULL,
[NEWBRANDNAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[WRH] [int] NULL,
[GRADE] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[F2] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SALETAX] [decimal] (24, 4) NULL,
[VALIDPERIOD] [smallint] NULL,
[ORDERQTY] [decimal] (24, 4) NULL,
[LENGTH] [decimal] (24, 4) NULL,
[WIDTH] [decimal] (24, 4) NULL,
[HEIGHT] [decimal] (24, 4) NULL,
[MEMO] [char] (255) COLLATE Chinese_PRC_CI_AS NULL,
[ISDISP] [int] NULL,
[CustomCode] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[SHORTNAME] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[GPR] [decimal] (24, 4) NULL,
[KEEPTYPE] [int] NULL,
[NEndTime] [datetime] NULL,
[SSStart] [datetime] NULL,
[SSEnd] [datetime] NULL,
[Season] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[F3] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[SHOPNO] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[NCanPay] [smallint] NULL,
[MANGBYPIECE] [smallint] NULL,
[LOWINV] [decimal] (24, 4) NULL,
[HIGHINV] [decimal] (24, 4) NULL,
[TAXSORTCODE] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[TAXSORTPROVINCE] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPGOODS_spid] ON [dbo].[TMPGOODS] ([spid]) ON [PRIMARY]
GO