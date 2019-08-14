CREATE TABLE [dbo].[RBPrompt]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[receiverUser] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[receiverRole] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[senderId] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[level_] [int] NOT NULL,
[message] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[link] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[senderClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[text_] [text] COLLATE Chinese_PRC_CI_AS NULL,
[flag] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[time_] [datetime] NULL,
[linkPerm] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBPrompt] ADD CONSTRAINT [PK__RBPrompt__791971DE] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBPrompt_2] ON [dbo].[RBPrompt] ([receiverRole]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBPrompt_1] ON [dbo].[RBPrompt] ([receiverUser]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBPrompt_3] ON [dbo].[RBPrompt] ([senderId]) ON [PRIMARY]
GO
