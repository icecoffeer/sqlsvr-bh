CREATE TABLE [dbo].[WRTASK]
(
[ID] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CATEGORY] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TITLE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QFILE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[EXPIREDATE] [datetime] NULL,
[ROOTPATH] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXPIRE] [smallint] NOT NULL CONSTRAINT [DF__WRTASK__EXPIRE__3E34AA7F] DEFAULT (0),
[DIVRESULT] [smallint] NOT NULL CONSTRAINT [DF__WRTASK__DIVRESUL__3F28CEB8] DEFAULT (0),
[updcls] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__wrtask__updcls__6721B179] DEFAULT ('更新'),
[QFILEEXT] [int] NOT NULL CONSTRAINT [DF__WRTASK__QFILEEXT__1DA01FC0] DEFAULT (1)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[WRTASK] ADD CONSTRAINT [PK__WRTASK__3D408646] PRIMARY KEY CLUSTERED  ([ID]) ON [PRIMARY]
GO
