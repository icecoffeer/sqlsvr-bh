CREATE TABLE [dbo].[storeGoodsSyncLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[createTime] [datetime] NULL,
[goodsCode] [varchar] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[message] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[storeCode] [varchar] (13) COLLATE Chinese_PRC_CI_AS NOT NULL,
[platform] [varchar] (50) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[storeGoodsSyncLog] ADD CONSTRAINT [PK__storeGoo__7F42793016EE8FF1] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
