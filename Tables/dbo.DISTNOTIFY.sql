CREATE TABLE [dbo].[DISTNOTIFY]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DISTSTORE] [int] NOT NULL,
[ORDNUM] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL,
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__DISTNOTIF__FILDA__780C4659] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__DISTNOTIF__FILLE__79006A92] DEFAULT (1),
[CHECKER] [int] NOT NULL CONSTRAINT [DF__DISTNOTIF__CHECK__79F48ECB] DEFAULT (1),
[STAT] [smallint] NOT NULL CONSTRAINT [DF__DISTNOTIFY__STAT__7AE8B304] DEFAULT (0),
[RECCNT] [int] NOT NULL CONSTRAINT [DF__DISTNOTIF__RECCN__7BDCD73D] DEFAULT (0),
[PRNTIME] [datetime] NULL,
[WRH] [int] NULL,
[DISTDATE] [datetime] NULL,
[DISTER] [int] NOT NULL CONSTRAINT [DF__DISTNOTIF__DISTE__7CD0FB76] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DISTNOTIFY] ADD CONSTRAINT [PK__DISTNOTIFY__77182220] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [FILDATE] ON [dbo].[DISTNOTIFY] ([FILDATE]) ON [PRIMARY]
GO
