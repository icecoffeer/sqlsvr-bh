CREATE TABLE [dbo].[RBOperateLog]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[operator] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[time] [datetime] NOT NULL,
[settleNo] [varchar] (6) COLLATE Chinese_PRC_CI_AS NULL,
[event] [varchar] (64) COLLATE Chinese_PRC_CI_AS NULL,
[message] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBOperateLog] ADD CONSTRAINT [PK__RBOperateLog__0F08B2FD] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOperateLog_1] ON [dbo].[RBOperateLog] ([domain]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOperateLog_3] ON [dbo].[RBOperateLog] ([settleNo]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBOperateLog_2] ON [dbo].[RBOperateLog] ([time]) ON [PRIMARY]
GO
