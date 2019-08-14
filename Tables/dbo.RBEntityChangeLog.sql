CREATE TABLE [dbo].[RBEntityChangeLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fieldName] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fieldCaption] [varchar] (64) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oldValue] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[newValue] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBEntityChangeLog] ADD CONSTRAINT [PK__RBEntityChangeLo__0D206A8B] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBEntityChangeLog_1] ON [dbo].[RBEntityChangeLog] ([fieldName]) ON [PRIMARY]
GO
