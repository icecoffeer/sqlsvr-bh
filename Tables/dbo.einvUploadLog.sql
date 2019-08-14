CREATE TABLE [dbo].[einvUploadLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[lastTime] [datetime] NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[success] [tinyint] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[einvUploadLog] ADD CONSTRAINT [PK__einvUplo__7F42793015506042] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
