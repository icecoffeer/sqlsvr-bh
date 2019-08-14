CREATE TABLE [dbo].[sgUploadLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[dataKey] [varchar] (500) COLLATE Chinese_PRC_CI_AS NOT NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[success] [int] NOT NULL,
[lastTime] [datetime] NULL,
[storeCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sgUploadLog] ADD CONSTRAINT [PK__sgUpload__7F42793067548B68] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
