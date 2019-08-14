CREATE TABLE [dbo].[sgUploadLogHistory]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (500) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastTime] [datetime] NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[success] [tinyint] NOT NULL,
[storeCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sgUploadLogHistory] ADD CONSTRAINT [PK__sgUpload__7F4279305FF360C2] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
