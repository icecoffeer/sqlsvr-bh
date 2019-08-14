CREATE TABLE [dbo].[RBOrganization]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[code] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[organizationDomain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[upperOrganization] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[levelId] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[remark] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOrganization] ADD CONSTRAINT [PK__RBOrganization__66FAC1A3] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOrganization_2] ON [dbo].[RBOrganization] ([code]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOrganization_1] ON [dbo].[RBOrganization] ([domain]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOrganization_3] ON [dbo].[RBOrganization] ([organizationDomain]) ON [PRIMARY]
GO
