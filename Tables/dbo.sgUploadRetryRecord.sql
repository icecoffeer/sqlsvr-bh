CREATE TABLE [dbo].[sgUploadRetryRecord]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (500) COLLATE Chinese_PRC_CI_AS NOT NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[lastTime] [datetime] NULL,
[retryTimes] [int] NULL CONSTRAINT [DF__sgUploadR__retry__70DDF5A2] DEFAULT ((0)),
[storeCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sgUploadRetryRecord] ADD CONSTRAINT [PK__sgUpload__7F4279306EF5AD30] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
