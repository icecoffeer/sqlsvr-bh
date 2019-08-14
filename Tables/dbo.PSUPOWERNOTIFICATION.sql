CREATE TABLE [dbo].[PSUPOWERNOTIFICATION]
(
[ID] [varchar] (60) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NGROUP] [varchar] (80) COLLATE Chinese_PRC_CI_AS NULL,
[TOPIC] [varchar] (150) COLLATE Chinese_PRC_CI_AS NULL,
[OPERATION] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[CONTENT] [varchar] (1024) COLLATE Chinese_PRC_CI_AS NULL,
[SCOPE] [varchar] (80) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESSKEY] [varchar] (80) COLLATE Chinese_PRC_CI_AS NULL,
[BUSINESSKEY2] [varchar] (80) COLLATE Chinese_PRC_CI_AS NULL,
[NTIME] [datetime] NULL,
[STAT] [smallint] NOT NULL CONSTRAINT [DF__PSUPOWERNO__STAT__79884A3C] DEFAULT (0),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PSUPOWERN__LSTUP__7A7C6E75] DEFAULT (getdate()),
[REMARK] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[recvMode] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSUPOWERNOTIFICATION] ADD CONSTRAINT [PK__PSUPOWERNOTIFICA__7B7092AE] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [IDX_PSUPOWERNOTIFICATION_TOPIC] ON [dbo].[PSUPOWERNOTIFICATION] ([TOPIC]) ON [PRIMARY]
GO