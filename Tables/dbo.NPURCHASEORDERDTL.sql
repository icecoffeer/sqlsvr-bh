CREATE TABLE [dbo].[NPURCHASEORDERDTL]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[ORDQTY] [decimal] (24, 4) NOT NULL,
[PRICE] [decimal] (24, 4) NOT NULL,
[TOTAL] [decimal] (24, 4) NOT NULL,
[TAX] [decimal] (24, 4) NOT NULL,
[WRH] [int] NOT NULL CONSTRAINT [DF__NPURCHASEOR__WRH__0BCB8848] DEFAULT (1),
[INVQTY] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__INVQT__0CBFAC81] DEFAULT (0),
[ARVQTY] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__ARVQT__0DB3D0BA] DEFAULT (0),
[BCKQTY] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__BCKQT__0EA7F4F3] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[RTLQTY] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__RTLQT__0F9C192C] DEFAULT (0),
[RTLBCKQTY] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__RTLBC__10903D65] DEFAULT (0),
[RTLPRC] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__RTLPR__1184619E] DEFAULT (0),
[RTLTOTAL] [decimal] (24, 4) NULL CONSTRAINT [DF__NPURCHASE__RTLTO__127885D7] DEFAULT (0),
[PRNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[ORDPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__ORDPR__136CAA10] DEFAULT (0),
[ORDAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__ORDAM__1460CE49] DEFAULT (0),
[INPRC] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__INPRC__1554F282] DEFAULT (0),
[INPRCAMT] [decimal] (24, 4) NOT NULL CONSTRAINT [DF__NPURCHASE__INPRC__164916BB] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NPURCHASEORDERDTL] ADD CONSTRAINT [PK__NPURCHASEORDERDT__173D3AF4] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
