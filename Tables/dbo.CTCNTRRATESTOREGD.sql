CREATE TABLE [dbo].[CTCNTRRATESTOREGD]
(
[NUM] [char] (14) COLLATE Chinese_PRC_CI_AS NOT NULL,
[VERSION] [smallint] NOT NULL,
[LINE] [smallint] NOT NULL,
[ITEMNO] [smallint] NOT NULL,
[STORESCOPE] [varchar] (50) COLLATE Chinese_PRC_CI_AS NOT NULL,
[GDSCOPESQL] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[GDSCOPETEXT] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL,
[NOTE] [varchar] (255) COLLATE Chinese_PRC_CI_AS NULL
) ON [PRIMARY]
GO
ALTER TABLE [dbo].[CTCNTRRATESTOREGD] ADD CONSTRAINT [PK__CTCNTRRATESTOREG__3E97CA8E] PRIMARY KEY CLUSTERED  ([NUM], [VERSION], [LINE], [ITEMNO]) ON [PRIMARY]
GO
