CREATE TABLE [dbo].[TangoUserRole]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[roleUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[userUUID] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoUserRole] ADD CONSTRAINT [PK__TangoUserRole__6E9BE36B] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
