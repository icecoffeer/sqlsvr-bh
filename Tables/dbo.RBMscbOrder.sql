CREATE TABLE [dbo].[RBMscbOrder]
(
[uuid] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[implementation] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[oca] [numeric] (19, 0) NOT NULL,
[lastModified] [datetime] NULL,
[domain] [varchar] (38) COLLATE Chinese_PRC_CI_AS NOT NULL,
[lastModifier] [varchar] (40) COLLATE Chinese_PRC_CI_AS NOT NULL,
[state] [int] NULL,
[subjectClass] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fevent] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[constraintContext] [text] COLLATE Chinese_PRC_CI_AS NULL,
[constraintDesc] [text] COLLATE Chinese_PRC_CI_AS NULL,
[constraintClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NULL,
[ftype] [varchar] (4) COLLATE Chinese_PRC_CI_AS NOT NULL,
[mgrClassName] [varchar] (128) COLLATE Chinese_PRC_CI_AS NOT NULL,
[fid] [varchar] (32) COLLATE Chinese_PRC_CI_AS NOT NULL,
[note] [text] COLLATE Chinese_PRC_CI_AS NULL,
[flag] [varchar] (16) COLLATE Chinese_PRC_CI_AS NULL,
[subscribeTime] [datetime] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[RBMscbOrder] ADD CONSTRAINT [PK__RBMscbOrder__2C9915E4] PRIMARY KEY CLUSTERED  ([uuid]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBMscbOrder_2] ON [dbo].[RBMscbOrder] ([ftype], [fid], [mgrClassName]) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [idx_RBMscbOrder_1] ON [dbo].[RBMscbOrder] ([subjectClass], [fevent], [domain]) ON [PRIMARY]
GO
