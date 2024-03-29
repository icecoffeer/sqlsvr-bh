CREATE TABLE [dbo].[STKOUTBCKDTL2]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__STKOUTBCKDT__CLS__24B40447] DEFAULT ('自营'),
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__STKOUTBCKDT__QTY__25A82880] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__STKOUTBCKD__COST__269C4CB9] DEFAULT (0),
[COSTADJ] [money] NOT NULL CONSTRAINT [DF__STKOUTBCK__COSTA__279070F2] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[STKOUTBCKDTL2] ADD CONSTRAINT [PK__STKOUTBCKDTL2__23BFE00E] PRIMARY KEY CLUSTERED  ([SUBWRH], [CLS], [NUM], [LINE]) ON [PRIMARY]
GO
