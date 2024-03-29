CREATE TABLE [dbo].[PS3SPECSCOPESCORE]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PS3SPECSCO__STAT__661D42B1] DEFAULT (0),
[FILDATE] [datetime] NOT NULL CONSTRAINT [DF__PS3SPECSC__FILDA__671166EA] DEFAULT (getdate()),
[FILLER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL,
[SNDTIME] [datetime] NULL,
[PRNTIME] [datetime] NULL,
[CHKDATE] [datetime] NULL,
[CHECKER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PS3SPECSC__LSTUP__68058B23] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PS3SPECSC__LSTUP__68F9AF5C] DEFAULT ('未知[-]'),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[SETTLENO] [int] NOT NULL CONSTRAINT [DF__PS3SPECSC__SETTL__69EDD395] DEFAULT (0),
[RECCNT] [int] NOT NULL,
[ABORTDATE] [datetime] NULL,
[ABORTER] [char] (30) COLLATE Chinese_PRC_CI_AS NULL,
[modnum] [char] (14) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3SPECSCOPESCORE] ADD CONSTRAINT [PK__PS3SPECSCOPESCOR__6AE1F7CE] PRIMARY KEY CLUSTERED  ([NUM], [CLS]) ON [PRIMARY]
GO
