CREATE TABLE [dbo].[einvUploadRetryRecord]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[lastTime] [datetime] NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[retryTimes] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[einvUploadRetryRecord] ADD CONSTRAINT [PK__einvUplo__7F427930117FCF5E] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
