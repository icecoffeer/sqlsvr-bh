CREATE TABLE [dbo].[RBOrgRole]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[type] [int] NULL,
[organization] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOrgRole] ADD CONSTRAINT [PK__RBOrgRole__02A2DC18] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOrgRole_1] ON [dbo].[RBOrgRole] ([domain]) ON [PRIMARY]
GO
