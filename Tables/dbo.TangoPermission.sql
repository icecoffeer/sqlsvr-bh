CREATE TABLE [dbo].[TangoPermission]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[code] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[cartFuncViewUuid] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[providerType] [int] NULL,
[providerClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[providerCaption] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[fieldCaption] [varchar] (32) COLLATE Chinese_PRC_CI_AS NULL,
[remark] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoPermission] ADD CONSTRAINT [PK__TangoPermission__085BB56E] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_TangoPermission_1] ON [dbo].[TangoPermission] ([cartFuncViewUuid], [providerClassName], [fieldCaption]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoPermission] ADD CONSTRAINT [UQ__TangoPermission__094FD9A7] UNIQUE NONCLUSTERED  ([code]) ON [PRIMARY]
GO
