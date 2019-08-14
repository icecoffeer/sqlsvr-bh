CREATE TABLE [dbo].[StoreOrd]
(
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[NUM] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[DMDDATE] [datetime] NOT NULL,
[ORDTIME] [datetime] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL,
[RCVTIME] [datetime] NULL CONSTRAINT [DF__StoreOrd__RCVTIM__2F70BE85] DEFAULT (getdate()),
[ALCTIME] [datetime] NULL,
[ToCls] [char] (10) COLLATE Chinese_PRC_CI_AS NULL,
[ToNum] [varchar] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[CLS] [varchar] (10) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [POSNOALCTIME] ON [dbo].[StoreOrd] ([POSNO], [ALCTIME]) ON [PRIMARY]
GO
