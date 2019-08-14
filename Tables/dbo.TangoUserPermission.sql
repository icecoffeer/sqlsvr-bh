CREATE TABLE [dbo].[TangoUserPermission]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[permissionUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[userUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoUserPermission] ADD CONSTRAINT [PK__TangoUserPermiss__68E30A15] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
