CREATE TABLE [dbo].[BLPREORD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__BLPREORD__STAT__1918FFC0] DEFAULT (0),
[PREORDSET] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SRC] [int] NOT NULL,
[PSR] [int] NOT NULL CONSTRAINT [DF__BLPREORD__PSR__1A0D23F9] DEFAULT (1),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__BLPREORD__FILDAT__1B014832] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[CHKDATE] [datetime] NULL,
[DEADDATE] [datetime] NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__BLPREORD__LSTUPD__1BF56C6B] DEFAULT (getdate()),
[PRNTIME] [datetime] NULL,
[SNDTIME] [datetime] NULL,
[SETTLENO] [int] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[RECCNT] [int] NOT NULL CONSTRAINT [DF__BLPREORD__RECCNT__1CE990A4] DEFAULT (0),
[SRCNUM] [char] (20) COLLATE Chinese_PRC_CI_AS NULL,
[CLS] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__BLPREORD__CLS__618B35B9] DEFAULT ('推荐报货')
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BLPREORD] ADD CONSTRAINT [PK__BLPREORD__1824DB87] PRIMARY KEY CLUSTERED  ([NUM]) ON [PRIMARY]
GO
