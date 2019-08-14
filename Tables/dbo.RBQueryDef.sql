CREATE TABLE [dbo].[RBQueryDef]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[location] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[filename] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[permissionUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBQueryDef] ADD CONSTRAINT [PK__RBQueryDef__2AB0CD72] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
