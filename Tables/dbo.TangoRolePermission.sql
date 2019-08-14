CREATE TABLE [dbo].[TangoRolePermission]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[permissionUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[roleUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoRolePermission] ADD CONSTRAINT [PK__TangoRolePermiss__7ED24B34] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
