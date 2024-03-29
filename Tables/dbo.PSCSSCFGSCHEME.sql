CREATE TABLE [dbo].[PSCSSCFGSCHEME]
(
[UUID] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CREATOR] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSCSSCFGS__CREAT__4D4445EA] DEFAULT ('未知[-]'),
[CREATETIME] [datetime] NOT NULL CONSTRAINT [DF__PSCSSCFGS__CREAT__4E386A23] DEFAULT (getdate()),
[LSTUPDOPER] [char] (30) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__PSCSSCFGS__LSTUP__4F2C8E5C] DEFAULT ('未知[-]'),
[LSTUPDTIME] [datetime] NOT NULL CONSTRAINT [DF__PSCSSCFGS__LSTUP__5020B295] DEFAULT (getdate()),
[NOTE] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PSCSSCFGSCHEME] ADD CONSTRAINT [PK__PSCSSCFGSCHEME__5114D6CE] PRIMARY KEY CLUSTERED  ([UUID]) ON [PRIMARY]
GO
