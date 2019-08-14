CREATE TABLE [dbo].[NBLPREORD]
(
[ID] [int] NOT NULL,
[RCV] [int] NOT NULL,
[SNDTIME] [datetime] NOT NULL,
[RCVTIME] [datetime] NULL,
[FRCCHK] [smallint] NOT NULL,
[NTYPE] [smallint] NOT NULL,
[NSTAT] [smallint] NOT NULL,
[NNOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL,
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__NBLPREORD__STAT__2C0D6F51] DEFAULT (0),
[PREORDSET] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__NBLPREORD__PSR__2D01938A] DEFAULT (1),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__NBLPREORD__FILDA__2DF5B7C3] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[DEADDATE] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__NBLPREORD__LSTUP__2EE9DBFC] DEFAULT (getdate()),
[PRNTIME] [datetime] NULL,
[SETTLENO] [int] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NBLPREORD] ADD CONSTRAINT [PK__NBLPREORD__2FDE0035] PRIMARY KEY CLUSTERED  ([ID], [SRC]) ON [PRIMARY]
GO