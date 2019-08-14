CREATE TABLE [dbo].[PS3_Shelf]
(
[shelfId] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[shelfCode] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[gdArea] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[createTime] [datetime] NOT NULL CONSTRAINT [DF__PS3_Shelf__creat__644E018B] DEFAULT (getdate()),
[modifyTime] [datetime] NOT NULL CONSTRAINT [DF__PS3_Shelf__modif__654225C4] DEFAULT (getdate())
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[PS3_Shelf] ADD CONSTRAINT [PK__PS3_Shel__DDAA8816672A6E36] PRIMARY KEY CLUSTERED  ([shelfId]) ON [PRIMARY]
GO
