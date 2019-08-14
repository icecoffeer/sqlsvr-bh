CREATE TABLE [dbo].[RBProcessLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[processClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ownerKey1] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[ownerKey2] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[ownerKey3] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[ownerKey4] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[processUuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[itemNo] [int] NOT NULL,
[processCaption] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[startTime] [datetime] NOT NULL,
[operator] [varchar] (40) COLLATE Chinese_PRC_CI_AS NULL,
[time] [datetime] NOT NULL,
[type] [int] NOT NULL,
[loggerName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[message] [varchar] (4000) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBProcessLog] ADD CONSTRAINT [PK__RBProcessLog__24F7F41C] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBProcessLog_1] ON [dbo].[RBProcessLog] ([domain], [processClassName], [ownerKey1], [ownerKey2], [ownerKey3], [ownerKey4], [processUuid], [itemNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBProcessLog_A] ON [dbo].[RBProcessLog] ([processUuid], [itemNo]) ON [PRIMARY]
GO
