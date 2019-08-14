CREATE TABLE [dbo].[TQrd]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[qdName] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[qdTime] [datetime] NULL,
[startTime] [datetime] NULL,
[timeUsed] [numeric] (19, 0) NULL,
[resultCount] [int] NULL,
[threadId] [numeric] (19, 0) NULL,
[userUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[queryCriteria] [varbinary] (1000) NULL,
[displayCriteria] [varbinary] (1000) NULL,
[message] [varchar] (1000) COLLATE Chinese_PRC_CI_AS NULL,
[qdUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NULL,
[queryCriteriaInfo] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[TQrd] ADD CONSTRAINT [PK__TQrd__19864170] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
