CREATE TABLE [dbo].[RBDomainStoppedPermission]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[permission] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBDomainStoppedPermission] ADD CONSTRAINT [PK__RBDomainStoppedP__7CEA02C2] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBDomainSP_1] ON [dbo].[RBDomainStoppedPermission] ([domain]) ON [PRIMARY]
GO
