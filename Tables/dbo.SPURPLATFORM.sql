CREATE TABLE [dbo].[SPURPLATFORM]
(
[CODE] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ISEXTERNAL] [smallint] NOT NULL,
[INUSE] [smallint] NOT NULL,
[LSTUPDTIME] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[SPURPLATFORM] ADD CONSTRAINT [PK__SPURPLATFORM__56741829] PRIMARY KEY CLUSTERED  ([CODE]) ON [PRIMARY]
GO