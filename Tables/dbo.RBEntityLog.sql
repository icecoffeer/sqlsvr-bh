CREATE TABLE [dbo].[RBEntityLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[managerClass] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[managerCaption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[entityUuid] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[entityCaption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[newState] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBEntityLog] ADD CONSTRAINT [PK__RBEntityLog__10F0FB6F] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBEntityLog_1] ON [dbo].[RBEntityLog] ([entityUuid], [newState]) ON [PRIMARY]
GO
