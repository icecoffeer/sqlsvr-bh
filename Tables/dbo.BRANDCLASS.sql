CREATE TABLE [dbo].[BRANDCLASS]
(
[GID] [int] NOT NULL,
[NAME] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[BRANDCLASS] ADD CONSTRAINT [PK__BRANDCLASS__3E645712] PRIMARY KEY CLUSTERED  ([GID]) ON [PRIMARY]
GO