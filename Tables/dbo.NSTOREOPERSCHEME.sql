CREATE TABLE [dbo].[NSTOREOPERSCHEME]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NSTOREOPER__STAT__1DF78780] DEFAULT (0),
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__NSTOREOPE__SETTL__1EEBABB9] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NSTOREOPE__FILDA__1FDFCFF2] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SNDTIME] [datetime] NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NSTOREOPE__LSTUP__20D3F42B] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__NSTOREOPE__LSTUP__21C81864] DEFAULT ('未知[-]'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL,
[RCV] [int] NOT NULL,
[RCVTIME] [datetime] NULL,
[TYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NSTOREOPERSCHEME] ADD CONSTRAINT [PK__NSTOREOPERSCHEME__22BC3C9D] PRIMARY KEY CLUSTERED  ([SRC], [ID]) ON [PRIMARY]
GO