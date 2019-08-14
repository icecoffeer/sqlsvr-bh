CREATE TABLE [dbo].[RBMscbOrderPrompt]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[forder] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[providerClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[context] [text] COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBMscbOrderPrompt] ADD CONSTRAINT [PK__RBMscbOrderPromp__2E815E56] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
