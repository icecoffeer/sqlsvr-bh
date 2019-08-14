CREATE TABLE [dbo].[RBRoleDomain]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[roleUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[domainUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBRoleDomain] ADD CONSTRAINT [PK__RBRoleDomain__3251EF3A] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
