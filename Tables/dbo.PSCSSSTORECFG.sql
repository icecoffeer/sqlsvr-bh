CREATE TABLE [dbo].[PSCSSSTORECFG]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[STOREGID] [int] NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSCSSSTOR__CREAT__54E567B2] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__PSCSSSTOR__CREAT__55D98BEB] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSCSSSTOR__LSTUP__56CDB024] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PSCSSSTOR__LSTUP__57C1D45D] DEFAULT (getdate()),
[SENDTIME] [datetime] NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSSTORECFG] ADD CONSTRAINT [PK__PSCSSSTORECFG__58B5F896] PRIMARY KEY CLUSTERED  ([UUID], [STOREGID]) ON [PRIMARY]
GO
