CREATE TABLE [dbo].[WRTASK3]
(
[TID] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [char] (8) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WRTASK3] ADD CONSTRAINT [PK__WRTASK3__42F95F9C] PRIMARY KEY CLUSTERED  ([TID], [CLS], [GID]) ON [PRIMARY]
GO
