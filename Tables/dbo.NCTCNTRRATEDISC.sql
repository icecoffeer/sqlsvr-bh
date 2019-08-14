CREATE TABLE [dbo].[NCTCNTRRATEDISC]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[RATE] [decimal] (24, 2) NOT NULL,
[LOWAMT] [decimal] (24, 2) NOT NULL,
[HIGHAMT] [decimal] (24, 2) NOT NULL,
[QBASE] [decimal] (24, 2) NOT NULL,
[SRC] [int] NOT NULL,
[ID] [int] NOT NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[NCTCNTRRATEDISC] ADD CONSTRAINT [PK__NCTCNTRRATEDISC__368C9472] PRIMARY KEY CLUSTERED  ([SRC], [ID], [LINE], [ITEMNO]) ON [PRIMARY]
GO