CREATE TABLE [dbo].[WRTASK2]
(
[TID] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CID] [int] NOT NULL,
[COND] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WRTASK2] ADD CONSTRAINT [PK__WRTASK2__4111172A] PRIMARY KEY CLUSTERED  ([TID], [CID]) ON [PRIMARY]
GO
