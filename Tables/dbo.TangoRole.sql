CREATE TABLE [dbo].[TangoRole]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[code] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[roleType] [int] NULL,
[remark] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoRole] ADD CONSTRAINT [PK__TangoRole__048B248A] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
