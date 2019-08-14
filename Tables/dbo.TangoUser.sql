CREATE TABLE [dbo].[TangoUser]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastModifier] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[FLogin] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (20) COLLATE Chinese_PRC_CI_AS NULL,
[FPassword] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[FOnline] [tinyint] NULL,
[validFrom] [datetime] NULL,
[validTo] [datetime] NULL,
[remark] [varchar] (200) COLLATE Chinese_PRC_CI_AS NULL,
[profileUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[departmentUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoUser] ADD CONSTRAINT [PK__TangoUser__06736CFC] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
