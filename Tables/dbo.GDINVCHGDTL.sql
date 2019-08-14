CREATE TABLE [dbo].[GDINVCHGDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[GDGID2] [int] NOT NULL,
[WRH] [int] NOT NULL,
[WRH2] [int] NOT NULL,
[CASES] [money] NULL,
[QTY] [money] NOT NULL,
[PRICE] [money] NOT NULL,
[TOTAL] [money] NOT NULL,
[TAX] [money] NOT NULL,
[INPRC] [money] NOT NULL,
[RTLPRC] [money] NOT NULL,
[INPRC2] [money] NOT NULL,
[RTLPRC2] [money] NOT NULL,
[RELQTY] [money] NOT NULL CONSTRAINT [DF__GDINVCHGD__RELQT__30F08951] DEFAULT (1),
[QTY2] [money] NOT NULL CONSTRAINT [DF__GDINVCHGDT__QTY2__31E4AD8A] DEFAULT (0),
[CASES2] [money] NOT NULL CONSTRAINT [DF__GDINVCHGD__CASES__32D8D1C3] DEFAULT (0),
[Price2] [money] NOT NULL CONSTRAINT [DF__GDINVCHGD__Price__33CCF5FC] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[GDINVCHGDTL] ADD CONSTRAINT [PK__GDINVCHGDTL__072DC301] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [GDINVCHGdtl_gdgid] ON [dbo].[GDINVCHGDTL] ([GDGID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO