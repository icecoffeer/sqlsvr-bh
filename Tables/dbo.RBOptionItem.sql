CREATE TABLE [dbo].[RBOptionItem]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[collection] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fname] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[value] [image] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOptionItem] ADD CONSTRAINT [PK__RBOptionItem__21276338] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOptionItem_1] ON [dbo].[RBOptionItem] ([collection], [fname]) ON [PRIMARY]
GO
