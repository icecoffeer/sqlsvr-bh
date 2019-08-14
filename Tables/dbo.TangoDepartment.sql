CREATE TABLE [dbo].[TangoDepartment]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[lastModifier] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[state] [int] NULL,
[code] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[remark] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoDepartment] ADD CONSTRAINT [PK__TangoDepartment__16A9D4C5] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TangoDepartment] ADD CONSTRAINT [UQ__TangoDepartment__179DF8FE] UNIQUE NONCLUSTERED  ([code]) ON [PRIMARY]
GO
