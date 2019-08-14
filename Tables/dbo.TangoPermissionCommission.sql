CREATE TABLE [dbo].[TangoPermissionCommission]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[permissionUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fromUserUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[toUserUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[validFrom] [datetime] NULL,
[validTo] [datetime] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoPermissionCommission] ADD CONSTRAINT [PK__TangoPermissionC__6ACB5287] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
