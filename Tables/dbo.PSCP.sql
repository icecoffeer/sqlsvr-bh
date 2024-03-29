CREATE TABLE [dbo].[PSCP]
(
[GID] [int] NOT NULL,
[CODE] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [char] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATEDATE] [datetime] NOT NULL CONSTRAINT [DF__PSCP__CREATEDATE__09B6C09F] DEFAULT (getdate()),
[FILLER] [int] NOT NULL CONSTRAINT [DF__PSCP__FILLER__0AAAE4D8] DEFAULT (1),
[MODIFIER] [int] NOT NULL CONSTRAINT [DF__PSCP__MODIFIER__0B9F0911] DEFAULT (1),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PSCP__LSTUPDTIME__0C932D4A] DEFAULT (getdate()),
[RAWRECCNT] [int] NOT NULL,
[PDTRECCNT] [int] NOT NULL,
[SndTime] [datetime] NULL,
[SRC] [int] NOT NULL CONSTRAINT [DF__PSCP__SRC__0D875183] DEFAULT (1),
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[PSCPTYPE] [smallint] NOT NULL CONSTRAINT [DF__PSCP__PSCPTYPE__421CAC01] DEFAULT (0),
[STAT] [int] NOT NULL CONSTRAINT [DF__PSCP__STAT__7824824E] DEFAULT (1),
[CYCLE] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCP] ADD CONSTRAINT [PK__PSCP__39044A60] PRIMARY KEY NONCLUSTERED  ([GID]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCP] ADD CONSTRAINT [UQ__PSCP__004002F9] UNIQUE CLUSTERED  ([CODE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
