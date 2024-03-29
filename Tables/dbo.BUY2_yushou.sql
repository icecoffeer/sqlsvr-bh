CREATE TABLE [dbo].[BUY2_yushou]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[GID] [int] NOT NULL,
[QTY] [money] NOT NULL CONSTRAINT [DF__BUY2_yushou__QTY__680721D1] DEFAULT (0),
[INPRC] [money] NOT NULL CONSTRAINT [DF__BUY2_yush__INPRC__68FB460A] DEFAULT (0),
[PRICE] [money] NOT NULL CONSTRAINT [DF__BUY2_yush__PRICE__69EF6A43] DEFAULT (0),
[REALAMT] [money] NOT NULL CONSTRAINT [DF__BUY2_yush__REALA__6AE38E7C] DEFAULT (0),
[FAVAMT] [money] NOT NULL CONSTRAINT [DF__BUY2_yush__FAVAM__6BD7B2B5] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__BUY2_yushou__TAG__6CCBD6EE] DEFAULT (0),
[QPCGID] [int] NULL,
[PRMTAG] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ASSISTANT] [int] NULL,
[WRH] [int] NULL CONSTRAINT [DF__BUY2_yushou__WRH__6DBFFB27] DEFAULT (1),
[INVNO] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[DEALER] [int] NULL,
[IQTY] [money] NULL,
[GDCODE] [char] (13) COLLATE Chinese_PRC_CI_AS NULL,
[SCRPRICE] [money] NULL,
[SCRFAVRATE] [money] NULL,
[Score] [money] NULL,
[ScoreInfo] [char] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUY2_yushou] ADD CONSTRAINT [PK__BUY2_yushou__6712FD98] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [ITEMNO]) ON [PRIMARY]
GO
