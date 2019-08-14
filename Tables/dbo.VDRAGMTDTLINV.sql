CREATE TABLE [dbo].[VDRAGMTDTLINV]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[GDCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[MUNIT] [char] (6) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QPCSTR] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QPC] [decimal] (24, 4) NOT NULL,
[QTYRAT] [char] (15) COLLATE Chinese_PRC_CI_AS NULL,
[ISGFT] [smallint] NOT NULL CONSTRAINT [DF__VDRAGMTDT__ISGFT__4F4D5544] DEFAULT (0),
[FROMGID] [int] NULL,
[LISTPRC] [decimal] (24, 4) NOT NULL,
[NDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__NDIS__5041797D] DEFAULT (0),
[DDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__DDIS__51359DB6] DEFAULT (0),
[EDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__EDIS__5229C1EF] DEFAULT (0),
[MDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__MDIS__531DE628] DEFAULT (0),
[REBATE] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VDRAGMTDT__REBAT__54120A61] DEFAULT (0),
[BDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__BDIS__55062E9A] DEFAULT (0),
[NPDIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDT__NPDIS__55FA52D3] DEFAULT (0),
[ODIS] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDTL__ODIS__56EE770C] DEFAULT (0),
[PRICE] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__VDRAGMTDT__PRICE__57E29B45] DEFAULT (0),
[AMTDIS] [decimal] (24, 2) NOT NULL CONSTRAINT [DF__VDRAGMTDT__AMTDI__58D6BF7E] DEFAULT (0),
[MINORDQTY] [char] (15) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRAGMTDT__MINOR__59CAE3B7] DEFAULT ('0'),
[GFTDESC] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[LACKCHGPRICE] [decimal] (24, 4) NULL,
[CALCFLAG] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__VDRAGMTDT__CALCF__5ABF07F0] DEFAULT ('0001'),
[SALE] [smallint] NOT NULL CONSTRAINT [DF__VDRAGMTDTL__SALE__5BB32C29] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[VDRAGMTDTLINV] ADD CONSTRAINT [PK__VDRAGMTDTLINV__5CA75062] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) ON [PRIMARY]
GO