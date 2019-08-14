CREATE TABLE [dbo].[CTCNTRRATEDISC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[RATE] [decimal] (24, 2) NOT NULL,
[LOWAMT] [decimal] (24, 2) NOT NULL,
[HIGHAMT] [decimal] (24, 2) NOT NULL,
[QBASE] [decimal] (24, 2) NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRRATEDISC] ADD CONSTRAINT [PK__CTCNTRRATEDISC__42F00952] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE], [ITEMNO]) ON [PRIMARY]
GO
