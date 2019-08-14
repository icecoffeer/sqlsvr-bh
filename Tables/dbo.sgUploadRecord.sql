CREATE TABLE [dbo].[sgUploadRecord]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[orderKey] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[lastTime] [datetime] NULL,
[storeCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[sgUploadRecord] ADD CONSTRAINT [PK__sgUpload__7F4279306B251C4C] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
