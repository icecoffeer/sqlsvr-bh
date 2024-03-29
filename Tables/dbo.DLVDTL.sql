CREATE TABLE [dbo].[DLVDTL]
(
[NUM] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[LINE] [smallint] NOT NULL,
[GDGID] [int] NOT NULL,
[QTY] [money] NOT NULL,
[POSNO] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL,
[FLOWNO] [char] (12) COLLATE Chinese_PRC_CI_AS NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[QPCGID] [int] NULL,
[QPCQTY] [money] NULL,
[cls] [char] (10) COLLATE Chinese_PRC_CI_AS NOT NULL CONSTRAINT [DF__dlvdtl__cls__55C14FF6] DEFAULT ('-'),
[ISCUT] [smallint] NULL CONSTRAINT [DF__dlvdtl__ISCUT__13E96AF8] DEFAULT (0)
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[DLVDTL] ADD CONSTRAINT [PK__DLVDTL__473C8FC7] PRIMARY KEY CLUSTERED  ([NUM], [LINE]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
CREATE NONCLUSTERED INDEX [DLVDTL_BUY] ON [dbo].[DLVDTL] ([POSNO], [FLOWNO], [ITEMNO]) WITH (FILLFACTOR=90) ON [PRIMARY]
GO
