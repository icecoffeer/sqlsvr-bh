CREATE TABLE [dbo].[BUY21_yushou]
(
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[FAVTYPE] [char] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FAVAMT] [money] NOT NULL CONSTRAINT [DF__BUY21_yus__FAVAM__709C67D2] DEFAULT (0),
[TAG] [smallint] NOT NULL CONSTRAINT [DF__BUY21_yusho__TAG__71908C0B] DEFAULT (0),
[PROMNUM] [char] (14) COLLATE Chinese_PRC_CI_AS NULL,
[PROMCLS] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[PROMLVL] [int] NULL,
[PROMGDCNT] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BUY21_yushou] ADD CONSTRAINT [PK__BUY21_yushou__6FA84399] PRIMARY KEY CLUSTERED  ([POSNO], [FLOWNO], [ITEMNO], [FAVTYPE]) ON [PRIMARY]
GO
