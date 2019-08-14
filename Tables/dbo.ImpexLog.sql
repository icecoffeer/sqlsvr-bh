CREATE TABLE [dbo].[ImpexLog]
(
[uuid] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[indicator] [varchar] (255) COLLATE Chinese_PRC_CI_AS NOT NULL,
[curCondTime] [datetime] NULL,
[curCondId] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[newCondTime] [datetime] NULL,
[newCondId] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[state] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[startTime] [datetime] NULL,
[endTime] [datetime] NULL,
[commitTime] [datetime] NULL,
[description] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[fileName] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[userFullLogin] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[total] [int] NULL,
[inserted] [int] NULL,
[updated] [int] NULL,
[deleted] [int] NULL,
[success] [int] NULL,
[fail] [int] NULL,
[fsize] [int] NULL,
[available] [int] NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[ImpexLog] ADD CONSTRAINT [PK__ImpexLog__1B6E89E2] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
