CREATE TABLE [dbo].[WRTASKss]
(
[ID] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CATEGORY] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NAME] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[TITLE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[QFILE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[BEGINDATE] [datetime] NOT NULL,
[EXPIREDATE] [datetime] NULL,
[ROOTPATH] [varchar] (100) COLLATE Chinese_PRC_CI_AS NULL,
[EXPIRE] [smallint] NOT NULL,
[DIVRESULT] [smallint] NOT NULL,
[updcls] [varchar] (20) COLLATE Chinese_PRC_CI_AS NOT NULL
) ON [PRIMARY]
GO
