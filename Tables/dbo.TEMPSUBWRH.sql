CREATE TABLE [dbo].[TEMPSUBWRH]
(
[SPID] [int] NOT NULL,
[BILL] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[LINE] [int] NULL,
[SUBWRH] [int] NOT NULL,
[WRH] [int] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__TEMPSUBWRH__QTY__5833A84D] DEFAULT (0),
[COST] [money] NOT NULL CONSTRAINT [DF__TEMPSUBWRH__COST__5927CC86] DEFAULT (0),
[COSTADJ] [money] NOT NULL CONSTRAINT [DF__TEMPSUBWR__COSTA__5A1BF0BF] DEFAULT (0)
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_SPID] ON [dbo].[TEMPSUBWRH] ([SPID]) ON [PRIMARY]
GO