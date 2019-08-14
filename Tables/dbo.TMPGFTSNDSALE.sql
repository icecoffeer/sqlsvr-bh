CREATE TABLE [dbo].[TMPGFTSNDSALE]
(
[spid] [int] NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[FLOWNO] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[SALETIME] [datetime] NULL,
[GDGID] [int] NULL,
[QTY] [decimal] (24, 2) NULL,
[AMT] [decimal] (24, 2) NULL,
[TAG] [smallint] NULL,
[DEDUCTAMT] [decimal] (24, 2) NULL,
[PRMTAG] [char] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TMPGFTSNDSALE_spid] ON [dbo].[TMPGFTSNDSALE] ([spid]) ON [PRIMARY]
GO
