CREATE TABLE [dbo].[RBMscbCancelOrder]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[state] [int] NULL,
[cancelledOrder] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ftype] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[mgrClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fid] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[cancelTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBMscbCancelOrder] ADD CONSTRAINT [PK__RBMscbCancelOrde__3069A6C8] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBMscbCancelOrder_1] ON [dbo].[RBMscbCancelOrder] ([cancelledOrder], [domain]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBMscbCancelOrder_2] ON [dbo].[RBMscbCancelOrder] ([fid], [mgrClassName]) ON [PRIMARY]
GO
