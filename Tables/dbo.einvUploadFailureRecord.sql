CREATE TABLE [dbo].[einvUploadFailureRecord]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[lastTime] [datetime] NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[einvUploadFailureRecord] ADD CONSTRAINT [PK__einvUplo__7F4279301920F126] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
