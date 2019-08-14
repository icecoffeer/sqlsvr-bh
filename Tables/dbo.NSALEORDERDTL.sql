CREATE TABLE [dbo].[NSALEORDERDTL]
(
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[CASES] [money] NULL,
[QTY] [money] NOT NULL,
[PRICE] [money] NOT NULL,
[TOTAL] [money] NOT NULL,
[TAX] [money] NOT NULL,
[VALIDDATE] [datetime] NULL,
[WRH] [int] NOT NULL CONSTRAINT [DF__NSALEORDERD__WRH__7BE6F8DE] DEFAULT (1),
[INVQTY] [money] NOT NULL CONSTRAINT [DF__NSALEORDE__INVQT__7CDB1D17] DEFAULT (0),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSALEORDERDTL] ADD CONSTRAINT [PK__NSALEORDERDTL__7AF2D4A5] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE]) ON [PRIMARY]
GO
