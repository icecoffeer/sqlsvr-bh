CREATE TABLE [dbo].[STKOUTBCKDTL]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SETTLENO] [int] NULL,
[GDGID] [int] NULL,
[CASES] [money] NULL,
[QTY] [money] NULL,
[WSPRC] [money] NULL,
[PRICE] [money] NULL,
[TOTAL] [money] NULL,
[TAX] [money] NULL,
[WRH] [int] NULL CONSTRAINT [DF__STKOUTBCKDT__WRH__098A4168] DEFAULT (1),
[INPRC] [money] NULL,
[RTLPRC] [money] NULL,
[VALIDDATE] [datetime] NULL,
[subwrh] [int] NULL,
[RCPQTY] [money] NOT NULL CONSTRAINT [DF__STKOUTBCK__RCPQT__579489CF] DEFAULT (0),
[RCPAMT] [money] NOT NULL CONSTRAINT [DF__STKOUTBCK__RCPAM__5888AE08] DEFAULT (0),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[itemno] [smallint] NULL,
[qpcgid] [int] NULL,
[qpcqty] [money] NULL,
[COST] [money] NOT NULL CONSTRAINT [DF__STKOUTBCKD__COST__3282355A] DEFAULT (0),
[COSTPRC] [money] NOT NULL CONSTRAINT [DF__STKOUTBCK__COSTP__658DA36B] DEFAULT (0),
[GFTTOTAL] [decimal] (24, 4) NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STKOUTBCKDTL] ADD CONSTRAINT [PK__STKOUTBCKDTL__257187A8] PRIMARY KEY CLUSTERED  ([CLS], [NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stkoutbckdtl_gdgid] ON [dbo].[STKOUTBCKDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [stkoutbckdtl_ItemNo] ON [dbo].[STKOUTBCKDTL] ([itemno]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
