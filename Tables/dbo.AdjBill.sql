CREATE TABLE [dbo].[AdjBill]
(
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[FILDATE] [datetime] NULL,
[GENDATE] [datetime] NULL,
[FILLER] [int] NULL CONSTRAINT [DF__AdjBill__FILLER__0C932D4A] DEFAULT (1),
[SRC] [money] NULL,
[DECTION] [money] NULL,
[ALCTIME] [datetime] NULL,
[TONUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[AdjBill] ADD CONSTRAINT [PK__ADJBILL__6E702F8B] PRIMARY KEY CLUSTERED  ([CLS], [POSNO], [NUM], [LINE], [GDGID]) ON [PRIMARY]
GO
