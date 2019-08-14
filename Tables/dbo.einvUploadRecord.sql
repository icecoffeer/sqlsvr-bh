CREATE TABLE [dbo].[einvUploadRecord]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastTime] [datetime] NULL,
[name] [varchar] (100) COLLATE Chinese_PRC_CI_AS NOT NULL,
[orderKey] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[einvUploadRecord] ADD CONSTRAINT [PK__einvUplo__7F4279300DAF3E7A] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
